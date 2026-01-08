You are creating an **IMPLEMENTATION PLAN**. Do NOT implement yet.

## Inputs
- Spec: @<PATH_TO_SPEC_MD>
- Research: @<PATH_TO_RESEARCH_MD>

## Output (single markdown file)
Write to: `thoughts/shared/plans/<YYYY-MM-DD>_<short-topic>_plan.md`

## Planning rules
- Keep phases small and independently verifiable
- After every phase: specify the exact command(s) to validate
- Prefer targeted tests over “run everything” (but include final full/CI-equivalent step if available)
- Include file paths and the exact symbols you’ll touch
- Call out error-handling and user-facing messages explicitly
- Call out any backwards-compat concerns
- DO NOT add new dependencies unless explicitly required (and if you do, document why)

## Required plan format
---
date: <ISO8601>
topic: <short topic>
status: draft
branch: <branch>
git_commit: <hash>
---

# Plan: <topic>

## Desired end state (copy from spec)
- …

## Phase 0 — Safety / setup (checkboxes)
- [ ] Identify current tests to run
- [ ] Identify golden files / snapshots (if any)

## Phase 1 — <name>
- [ ] Change: <what>
  - Files: <paths>
  - Symbols: <functions/types>
- [ ] Add/Update tests: <what>
- [ ] Verify:
  - Command(s): `<exact commands>`
  - Expected result: <what success looks like>

## Phase 2 — <name>
…

## Rollback plan
- What to revert if something goes wrong

## PR checklist
- [ ] Tests pass
- [ ] Lints/formatting pass
- [ ] Docs updated (if user-facing)
- [ ] No leftover debug logs
- [ ] No “TODO” placeholders introduced