# Bug Fix Skill

## Step 0: State Your Assumptions (BEFORE investigating)

Before reading any code, write down:

1. **What layer do you believe the bug is in?** (frontend / API / middleware / DB / config / deployment)
2. **What data flow are you assuming?** (e.g., "user action -> API -> service -> DB -> response")
3. **What do you think the root cause is?** (gut instinct — write it down)
4. **What else could it be?** (at least one alternative hypothesis)

Writing down assumptions before investigating makes them visible and challengeable.
See also: `/debug` Step 2 (State Your Hypothesis First).

---

## Steps
1. Research: Spawn a sub-agent to trace the full data flow. Compare actual flow against Step 0 assumptions.
2. Identify: List ALL layers where the bug manifests, not just the first symptom
3. Plan: Write a fix plan covering every layer before editing any code
4. Implement: Apply fixes across all identified layers
5. Verify: Run full test suite and confirm end-to-end
6. Commit: Focused commit with descriptive message

## Anti-patterns to avoid
- Do NOT fix only one layer and assume the bug is resolved
- Do NOT skip checking if the DB update matches what the frontend reads
- Do NOT bundle this fix into another session's commit
- Do NOT skip Step 0 — unexamined assumptions are the #1 source of wrong-path investigation
