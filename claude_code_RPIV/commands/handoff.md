Create a **handoff document** so a fresh agent can continue without reading the whole thread.

## Output
Write to: `thoughts/shared/handoffs/<YYYY-MM-DD>_<short-topic>_handoff.md`

## Required structure
---
date: <ISO8601>
topic: <short topic>
status: active
branch: <branch>
git_commit: <hash>
---

# Handoff: <topic>

## Goal (1–3 bullets)
## What's done (facts only)
- Completed phases / merged commits
- Tests that were run and their results
- Validation status (if /validate was run)

## Current state
- What is failing / remaining
- Exact error messages (only the latest, most relevant)

## Next steps
- The next 3–8 concrete actions
- Exact commands to run next

## Key references
- Plan: <path>
- Research: <path>
- Validation: <path> (if /validate was run)
- Files touched: <short list>