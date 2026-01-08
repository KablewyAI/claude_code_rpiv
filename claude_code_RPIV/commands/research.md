You are doing **RESEARCH ONLY**. Do NOT implement. Do NOT write a plan.

## Goal
Create a concise research document explaining how the codebase works *today* for the requested change.

## Inputs
- Spec: @<PATH_TO_SPEC_MD>
- (Optional) issue/ticket text: <PASTE OR LINK>
- (Optional) constraints: <PASTE>

## Output (single markdown file)
Write to: `thoughts/shared/research/<YYYY-MM-DD>_<short-topic>.md`

### Required structure
---
date: <ISO8601 with timezone>
topic: <short topic>
status: complete
branch: <current branch name>
git_commit: <current commit hash>
repository: <repo name>
tags: [research, <feature-area>, <key-components>]
---

# Research: <topic>

## Research Question
<verbatim user goal>

## Summary (5–12 bullets)
- What exists today
- What must change
- Where to change it
- How to test it

## Relevant Components (grouped by area)
For each area:
- What it does today
- Key files + functions
- Data flow / call flow (brief)
- What constraints exist (e.g. WASM, streaming-only, composite-only)
- Risks / footguns

## Code References
List the most relevant references only:
- path:line[-line] — why it matters

## How to run tests (only commands that exist)
- Fast checks
- Targeted tests relevant to this change
- How to update golden/expected outputs (if applicable)

## Open Questions / Ambiguities
Only real ambiguities that affect implementation.

## Non-goals
Explicitly call out what is NOT part of this change.

## Instructions (critical)
- Prefer file paths + function names + brief explanations over long excerpts
- If you aren’t sure about something, mark it as uncertain and point to the exact file to verify
- Use sub-agents to avoid bloating the main context:
  - @.claude/agents/codebase-locator.md
  - @.claude/agents/codebase-analyzer.md
  - @.claude/agents/codebase-pattern-finder.md