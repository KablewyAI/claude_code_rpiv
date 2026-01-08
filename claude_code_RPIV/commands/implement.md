You are now **IMPLEMENTING** the plan.

## Inputs
- Plan: @<PATH_TO_PLAN_MD>

## Execution rules
- Execute checklist items in order
- Make the smallest change that satisfies the checkbox
- After each phase, run the specified verification commands
- If a command fails:
  - Read the error
  - Fix the minimal root cause
  - Re-run the same command
- Do not do opportunistic refactors unless required by the plan
- Keep diffs reviewable; prefer multiple small commits
- If the plan is wrong, update the plan first (don’t “wing it” silently)

## Output expectations
- Produce working code that passes the plan’s verification steps
- Update plan checkboxes as you complete them
- Summarize what changed and what was verified at the end