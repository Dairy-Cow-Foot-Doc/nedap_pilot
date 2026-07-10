#!/usr/bin/env node
// MCP server exposing validated analysis patterns from the NEDLAME 2-arm
// pilot report, for reuse when building the 3-arm follow-up RCT analysis.
// See README.md for what MCP is and how to register this server.

const fs = require("fs");
const path = require("path");
const { McpServer } = require("@modelcontextprotocol/sdk/server/mcp.js");
const { StdioServerTransport } = require("@modelcontextprotocol/sdk/server/stdio.js");
const { z } = require("zod");

const REPO_ROOT = path.resolve(__dirname, "..");
const KNOWLEDGE_DIR = path.join(__dirname, "knowledge");
const FUNCTIONS_DIR = path.join(REPO_ROOT, "functions");

// Registry of the specific validated/fixed R functions worth reusing,
// with a short note on what each does and why it looks the way it does.
const REUSABLE_FUNCTIONS = {
  fxn_code_lesions: {
    file: "fxn_code_lesions.R",
    note: "Classifies LAME/TRIM/FOOTRIM remark+protocol text into lesion-type flags (trimonly, dd, wld, sole_ulcer, ...). This is a LOCAL OVERRIDE of a same-named function fetched live from GitHub - the GitHub version only checks the protocols field for \"NONE\"; this farm's routine trims are coded \"NONE\" in the remark field. Must be sourced AFTER the GitHub fetch to win.",
  },
  fxn_collapse_lesions: {
    file: "fxn_collapse_lesions.R",
    note: "Collapses multiple event rows on the same (farm, animal, date) to one row, keeping the UNION of lesion-type flags across those rows. Also a LOCAL OVERRIDE - the GitHub version computes its max() union AFTER an early row-reduction, silently losing lesion types coded on the same day as a trim-only row. Must be sourced AFTER the GitHub fetch to win.",
  },
  fxn_read_milk_folder: {
    file: "fxn_read_milk_folder.R",
    note: "Loads a folder of per-file milk production CSVs (date only in the filename) and resolves each row's raw animal ID to a specific animal-lactation by nearest-preceding freshening date - NOT by trusting an open-ended dry-date window, which can let a stale record from an earlier animal with the same reused tag silently swallow a later animal's milk rows.",
  },
};

function readKnowledgeFile(filename) {
  return fs.readFileSync(path.join(KNOWLEDGE_DIR, filename), "utf8");
}

function readFunctionSource(key) {
  const entry = REUSABLE_FUNCTIONS[key];
  if (!entry) return null;
  return fs.readFileSync(path.join(FUNCTIONS_DIR, entry.file), "utf8");
}

const server = new McpServer({
  name: "nedlame-rct-patterns",
  version: "1.0.0",
});

// ---- Resources ----

server.registerResource(
  "lessons-learned",
  "nedlame-rct://lessons-learned",
  {
    title: "Lessons Learned: NEDLAME 2-Arm Pilot Report",
    description: "The 4 real bugs found while building the 2-arm report, their root causes, and design choices that look like bugs but aren't.",
    mimeType: "text/markdown",
  },
  async (uri) => ({
    contents: [{ uri: uri.href, mimeType: "text/markdown", text: readKnowledgeFile("lessons-learned.md") }],
  })
);

server.registerResource(
  "methodology-patterns",
  "nedlame-rct://methodology-patterns",
  {
    title: "Reusable Methodology Patterns",
    description: "10 generalizable analysis patterns (treatment-group derivation, lactation-safe joins, milk normalization, KM-by-subgroup workaround, rolling lookback windows, etc.) written to carry over to an N-arm version of this RCT.",
    mimeType: "text/markdown",
  },
  async (uri) => ({
    contents: [{ uri: uri.href, mimeType: "text/markdown", text: readKnowledgeFile("methodology-patterns.md") }],
  })
);

for (const [key, entry] of Object.entries(REUSABLE_FUNCTIONS)) {
  server.registerResource(
    `r-function-${key}`,
    `nedlame-rct://functions/${key}`,
    {
      title: `R function: ${key}()`,
      description: entry.note,
      mimeType: "text/x-r-source",
    },
    async (uri) => ({
      contents: [{ uri: uri.href, mimeType: "text/x-r-source", text: readFunctionSource(key) }],
    })
  );
}

// ---- Tools ----

server.registerTool(
  "list_reusable_functions",
  {
    title: "List reusable validated R functions",
    description: "Lists the R functions from the 2-arm pilot that are validated/bug-fixed and worth reusing as-is in the 3-arm analysis, with a short note on what each does.",
    inputSchema: {},
  },
  async () => ({
    content: [{
      type: "text",
      text: JSON.stringify(
        Object.fromEntries(Object.entries(REUSABLE_FUNCTIONS).map(([k, v]) => [k, v.note])),
        null,
        2
      ),
    }],
  })
);

server.registerTool(
  "get_function_source",
  {
    title: "Get R function source",
    description: "Returns the full R source code for one of the validated functions (see list_reusable_functions for names).",
    inputSchema: { name: z.enum(Object.keys(REUSABLE_FUNCTIONS)) },
  },
  async ({ name }) => {
    const source = readFunctionSource(name);
    if (source === null) {
      return { content: [{ type: "text", text: `Unknown function: ${name}` }], isError: true };
    }
    return { content: [{ type: "text", text: source }] };
  }
);

server.registerTool(
  "get_lessons_learned",
  {
    title: "Get lessons learned",
    description: "Returns the full lessons-learned document: the 4 real bugs found in the 2-arm pilot, their root causes and fixes, and design choices that intentionally look like bugs but aren't.",
    inputSchema: {},
  },
  async () => ({ content: [{ type: "text", text: readKnowledgeFile("lessons-learned.md") }] })
);

server.registerTool(
  "get_methodology_patterns",
  {
    title: "Get methodology patterns",
    description: "Returns the full methodology-patterns document: 10 reusable analysis patterns generalized for an N-arm RCT.",
    inputSchema: {},
  },
  async () => ({ content: [{ type: "text", text: readKnowledgeFile("methodology-patterns.md") }] })
);

server.registerTool(
  "get_pitfall_checklist",
  {
    title: "Get a pre-flight pitfall checklist",
    description: "Returns a short, structured checklist to run through before trusting a new join or a new derived metric in the N-arm analysis - distilled from the lessons-learned document.",
    inputSchema: {},
  },
  async () => ({
    content: [{
      type: "text",
      text: JSON.stringify(
        [
          {
            check: "For every left_join() followed by filter(): if a row has zero valid matches, does it still produce exactly one output row (correctly labeled/censored), or does it vanish?",
            why: "The single most common bug found in the 2-arm report (3 separate instances) - filtering the joined result instead of pre-filtering the candidate table before joining.",
          },
          {
            check: "For any externally-fetched function you rely on: have you verified its actual behavior against a known real example, not just assumed it does what its name suggests?",
            why: "Two bugs in the 2-arm report were in a live-fetched external GitHub function whose logic didn't match this farm's data conventions.",
          },
          {
            check: "For each new join: does it need to be scoped to id_animal + lactation, or to the animal's full lifetime? Did you decide this deliberately, or copy the nearest existing join?",
            why: "Mixing up lactation-scoped vs. lifetime scoping silently produces plausible-looking wrong numbers.",
          },
          {
            check: "Does the total row count of the shared cohort table stay the same after every enrichment join (unless you're deliberately filtering the cohort itself)?",
            why: "A join bug in a shared base table corrupts every downstream section, not just the one you're editing.",
          },
          {
            check: "For any %, is the denominator exactly what the surrounding text claims it is - same population, same first-occurrence-only rule, same date window?",
            why: "Denominator drift between the prose and the code is easy to introduce silently when refactoring.",
          },
          {
            check: "For a monitor 'miss rate' or similar time-window comparison: does the lookback/window need to be rolling because the monitoring system has a go-live date within the data?",
            why: "A fixed lookback unfairly penalizes early cases if the system hadn't been running long enough yet.",
          },
          {
            check: "Are you reporting p-values/significance tests at a stage where the study intends descriptive/discussion-only results?",
            why: "The 2-arm report deliberately removed p-values at the discussion stage to avoid over-interpreting a small, early sample.",
          },
        ],
        null,
        2
      ),
    }],
  })
);

server.registerTool(
  "generate_treatment_group_r_code",
  {
    title: "Generate N-arm treatment-group derivation R code",
    description: "Generates ready-to-paste R code implementing the validated 'derive treatment group from the first qualifying alert' pattern, generalized to any number of arms.",
    inputSchema: {
      trigger_event_name: z.string().describe("The DairyComp Event value that identifies the triggering alert, e.g. \"NEDLAME\""),
      group_code_field: z.string().describe("The raw field that encodes arm membership, e.g. \"MNFRS\""),
      arm_labels: z.record(z.string(), z.string()).describe("Map of raw code value -> arm label, e.g. {\"1\": \"Arm A\", \"2\": \"Arm B\", \"3\": \"Arm C\"}"),
    },
  },
  async ({ trigger_event_name, group_code_field, arm_labels }) => {
    const cases = Object.entries(arm_labels)
      .map(([code, label]) => `      ${group_code_field} == "${code}" ~ "${label}",`)
      .join("\n");
    const code = `# Generated by nedlame-rct-patterns MCP server - generalized N-arm version
# of the cohort/treatment-group derivation pattern from the 2-arm report.
first_alert <- events_all |>
  filter(Event == "${trigger_event_name}") |>
  group_by(id_animal) |>
  slice_min(date_event, n = 1, with_ties = FALSE) |>
  ungroup() |>
  transmute(
    id_animal, id, lact_number,
    first_alert_date = date_event,
    alert_type = Remark,
    arm_group = case_when(
${cases}
      TRUE ~ NA_character_
    )
  ) |>
  filter(!is.na(arm_group))

# BEFORE trusting this, empirically verify ${group_code_field} is stable
# across all of a cow's ${trigger_event_name} rows even if it drifts
# elsewhere in her history - see lessons-learned.md.
stopifnot(
  events_all |>
    filter(Event == "${trigger_event_name}", !is.na(${group_code_field})) |>
    group_by(id_animal) |>
    summarize(n_distinct_codes = n_distinct(${group_code_field}), .groups = "drop") |>
    pull(n_distinct_codes) |>
    (\\(x) all(x == 1))()
)
`;
    return { content: [{ type: "text", text: code }] };
  }
);

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
}

main().catch((err) => {
  console.error("Fatal error starting nedlame-rct-patterns MCP server:", err);
  process.exit(1);
});
