# NEDLAME RCT Patterns — MCP Server

## What is MCP, and why does this exist?

**MCP (Model Context Protocol)** is a standard way for an AI assistant (like Claude Code) to connect to external "servers" that expose extra capabilities — specifically **tools** (functions the assistant can call) and **resources** (documents/files the assistant can read on demand). It's the same mechanism behind things like the GitHub or Gmail integrations you may have seen elsewhere — except this one isn't a public integration, it's a small custom server built *from this project*, for this project.

The problem it solves: building `report_nedlame_treatment_comparison.qmd` (the 2-arm pilot report) took several rounds of debugging — 4 real bugs were found, several were subtle (silent data-dropping joins, a bugged external function), and a handful of methodology decisions were made deliberately (lactation-scoping rules, rolling lookback windows, first-occurrence-only counting, etc.). None of that is written down anywhere a future AI session would automatically see. Without this server, a future Claude session building the 3-arm follow-up would have to re-discover all of it from scratch — including, most likely, re-introducing at least one of the same bugs.

This server packages that knowledge as **tools and resources a future Claude session can call directly**, instead of relying on it remembering (or re-deriving) this conversation.

## What's in it

**Resources** (documents Claude can read):
- `nedlame-rct://lessons-learned` — the 4 bugs, their root causes, and design choices that intentionally look like bugs but aren't.
- `nedlame-rct://methodology-patterns` — 10 reusable analysis patterns, generalized for an N-arm study.
- `nedlame-rct://functions/{fxn_code_lesions,fxn_collapse_lesions,fxn_read_milk_folder}` — the actual validated/fixed R source for the trickiest reusable functions.

**Tools** (functions Claude can call):
- `list_reusable_functions` — quick index of the functions above.
- `get_function_source(name)` — full R source for one of them.
- `get_lessons_learned()` / `get_methodology_patterns()` — same content as the resources, callable as tools too (some MCP clients discover tools more readily than resources).
- `get_pitfall_checklist()` — a short structured checklist to run through before trusting a new join/metric.
- `generate_treatment_group_r_code({trigger_event_name, group_code_field, arm_labels})` — generates ready-to-paste R code for the "derive treatment/arm group from the first qualifying alert" pattern, generalized to however many arms you give it (e.g. 3 for the follow-up study).

## Setup

```bash
cd mcp_server
npm install
```

## Registering with Claude Code

From this project's root:

```bash
claude mcp add nedlame-rct-patterns -- node mcp_server/index.js
```

This tells Claude Code to launch `node mcp_server/index.js` as a local MCP server (communicating over stdio) whenever it works in this project. After adding it, restart Claude Code (or start a new session) and the tools/resources above become available automatically — no need to re-explain any of this history to a fresh session.

To verify it's registered: `claude mcp list`. To remove it: `claude mcp remove nedlame-rct-patterns`.

## Testing it standalone

`test_client.js` spins up a real MCP client, connects to the server as a subprocess, and calls every tool/resource once — useful for checking the server still works after editing it:

```bash
node test_client.js
```

## Extending this for the 3-arm study

As the 3-arm analysis surfaces its own bugs and methodology decisions, add them to `knowledge/lessons-learned.md` and `knowledge/methodology-patterns.md` (plain markdown, no server restart logic needed beyond re-running `claude mcp` if you change the file paths) — a future session (or the next phase of this one) then has an even more complete picture of what's already been figured out.
