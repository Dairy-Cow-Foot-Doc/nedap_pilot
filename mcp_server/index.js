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
          {
            check: "For any comparison against a category NAME (== \"Some Label\", filter on a level, a case_when arm): if that string stopped matching tomorrow, would anything fail? Assert the category is PRESENT, not just that the parts sum to the whole.",
            why: "Four silent failures in the 2-arm project, every one rendering a clean page with wrong numbers. A partition assertion is necessary and not sufficient - it is trivially satisfied by an empty set, since 0 + 0 + 0 == 0, which is exactly the state a mismatched label produces.",
          },
          {
            check: "When renaming a category, did you search the BARE label text rather than the quoted literal, and check both quote styles?",
            why: "R treats 'Label' and \"Label\" identically but a find-and-replace does not. A rename that matched the double-quoted spelling left a single-quoted site behind and blanked a set of percentages.",
          },
          {
            check: "Is any outcome you are comparing across arms dependent on how often each arm gets INSPECTED?",
            why: "The 2-arm pilot's headline benefit - 58 more cows with a lesion found - was entirely ascertainment: 90.4% of one arm was trimmed against 49.8% of the other, and randomisation makes true incidence equal by construction. Confirmed by the trim-level rates running the other way.",
          },
          {
            check: "Before believing a pattern in a hand-picked set of cases, have you computed the same rate herd-wide?",
            why: "Two convincing leads died to this in one round. A 38.5% rate in the problem cases looked like proof until the herd rate came back 30.4%.",
          },
          {
            check: "To size the effect of a change that can only push cases one way across a boundary, are you measuring on the population that could CROSS it, rather than on the group already sitting on one side?",
            why: "A gate fix was quantified as changing 0 of 43 flags, measured on the set defined by nothing having blocked them. Measured on the population that could actually move, it changed 18 cases.",
          },
          {
            check: "Does a timestamp in this data mean when the thing was OBSERVED or when it was LOADED?",
            why: "The Nedap import runs ~05:00 and stamps the load date, so an attention after 05:00 on day D appears as D+1. This decides whether a same-day alert counts as advance warning, and it moved several headline numbers.",
          },
          {
            check: "Does every number in the prose come from a computed object, and does any number appearing in two documents come from ONE shared function?",
            why: "Hand-typed figures in prose, table titles and code comments went stale repeatedly, including a table title that contradicted the table beneath it.",
          },
          {
            check: "Have you read the RENDERED output, not just the code and the fact that it rendered?",
            why: "Two defects shipped as valid code producing prose that was false about the data - a sentence explaining an empty category, and percentages rendering as blanks. Neither a static check nor a successful render catches this class.",
          },
          {
            check: "Are the sample sizes you are comparing all expressed in the SAME unit - enrolled animals, not a mix of enrolled, affected, and assessed?",
            why: "Three different denominators were quoted as comparable while designing the follow-up; converting them properly moved one outcome's requirement from 3,330 to 9,321 enrolled.",
          },
          {
            check: "If randomisation happens WITHIN herd, have you resisted applying a cluster design effect?",
            why: "Herd is then a blocking factor and blocking REMOVES between-herd variance. The 1 + (m-1)*ICC inflation is for designs that randomise whole herds; applying it here would inflate the study several-fold for nothing. What does inflate is treatment-effect heterogeneity, tau^2/k, which more herds fix more cheaply than more cows.",
          },
          {
            check: "Does the primary model carry a treatment x covariate interaction? If so, is the doubled sample size a deliberate purchase?",
            why: "An interaction makes the reported treatment coefficient a within-stratum effect estimated from half the cows. Verified at exactly 2x on a linear model (SE ratio sqrt(2)) but 1.59x on a logistic one - simulate the penalty for the model you are fitting rather than carrying it across.",
          },
          {
            check: "For a design with immediate and delayed treatment arms: have you chosen the measurement window PER CONTRAST rather than one window for the study?",
            why: "The delayed-arm contrast is ten times cheaper at 28 days than at 90, because the delayed arm spends the rest of the window catching up. The ordering of the three contrasts flips at about 90 days, and at 28 days the delayed arm looks worse than doing nothing - an artifact that will alarm anyone reading an early interim.",
          },
          {
            check: "Before reporting a null: is the measurement window shorter than the process being measured?",
            why: "A three-month culling window showed lame cows culled LESS than non-lame. Over a year the association reverses and grows to 7.3 points. A cow diagnosed and treated in week one is not culled in week eight.",
          },
          {
            check: "If pooling outcomes into a composite: does any component have a large variance relative to its effect?",
            why: "A composite is not automatically cheaper. Adding a $1,500 event at 46% prevalence (SD $748/cow) to a milk signal worth $76 raised the requirement from 5,800 to 43,000 cows. A composite is often the right thing to report and the wrong thing to power on.",
          },
          {
            check: "In dplyr summarize(), have you avoided naming an output column after the column it summarises?",
            why: "summarize(trimmed = sum(trimmed), pct = mean(trimmed)) makes mean() see the sum. Evaluation is sequential. Hit three times in this project; one instance produced an obviously absurd 35,900% and two produced plausible wrong numbers.",
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
