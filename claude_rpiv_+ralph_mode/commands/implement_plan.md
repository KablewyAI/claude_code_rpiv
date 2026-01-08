---
description: Execute an approved implementation plan phase by phase
---

# Implement Plan

You are **IMPLEMENTING** an approved plan. Follow it precisely.

## Getting Started

If plan path provided:
1. Read the plan completely
2. Check for existing checkmarks (`- [x]`) to see what's done
3. Read original ticket/research and all files mentioned in plan
4. **Read files fully** — never use limit/offset
5. Think deeply about how pieces fit together
6. Create a todo list to track progress
7. Start implementing from first unchecked item

If no plan path:
> "Which plan should I implement? Please provide the path (e.g., `thoughts/shared/plans/2024-01-15_feature_plan.md`)"

## Implementation Philosophy

Plans are carefully designed, but reality can be messy. Your job is to:

1. **Follow the plan's intent** while adapting to what you find
2. **Implement each phase fully** before moving to the next
3. **Verify your work** makes sense in the broader codebase context
4. **Update checkboxes** in the plan as you complete sections

## Execution Rules

### For Each Phase:

1. **Read before changing**
   - Read all files the phase will touch
   - Understand the current state
   - Identify any drift from what plan expected

2. **Make minimal changes**
   - Only change what the phase specifies
   - No opportunistic refactors
   - No "while I'm here" improvements

3. **Run verification**
   - Execute the phase's verification commands
   - Fix issues before proceeding
   - Don't move on until verification passes

4. **Update the plan**
   - Check off completed items: `- [x]`
   - Note any deviations in comments
   - Keep the plan as source of truth

5. **Pause for manual verification**
   - After automated checks pass, pause
   - Do NOT check off manual testing steps
   - Wait for user to confirm manual items

## Handling Mismatches

When reality doesn't match the plan:

```
## Mismatch Detected

**Expected (from plan):**
[What the plan said]

**Found:**
[What actually exists]

**Impact:**
[How this affects the phase]

**Options:**
A) Adapt the implementation to match reality
B) Update the plan first, then implement
C) Stop and discuss with user

How should I proceed?
```

**STOP and present this** before continuing. Don't silently adapt.

## Verification Approach

After implementing a phase:

1. **Run automated checks**
   ```bash
   npm run lint
   npm test
   npm run build
   ```

2. **Report results**
   ```
   ## Phase 1 Verification

   **Automated:**
   - [x] Lint: Passed
   - [x] Tests: 42 passing, 0 failing
   - [x] Build: Success

   **Manual (awaiting your verification):**
   - [ ] [Manual step from plan]
   - [ ] [Manual step from plan]

   Please verify the manual steps and let me know when to proceed.
   ```

3. **Wait for confirmation** before next phase

## Resuming Work

If the plan has existing checkmarks:
- Trust completed work is done
- Pick up from first unchecked item
- Only verify previous work if something seems off

If you created a handoff previously:
- Use `/resume_handoff` instead to get full context

## If You Get Stuck

When something isn't working:

1. **Ensure you've read all relevant code**
2. **Consider if codebase evolved since planning**
3. **Present the issue clearly:**
   ```
   ## Blocked on Phase X

   **Attempting:** [What I'm trying to do]
   **Error:** [Exact error message]
   **Investigated:** [What I've checked]
   **Hypothesis:** [What I think is wrong]

   Should I:
   A) Try [alternative approach]
   B) Debug further with specific investigation
   C) Update the plan to handle this
   ```

4. **Use sub-agents sparingly** for targeted debugging:
   - `@.claude/agents/codebase-analyzer.md` — Trace code paths
   - `@.claude/agents/codebase-pattern-finder.md` — Find similar patterns

## Key Guidelines

1. **Read files COMPLETELY** — No limit/offset, full context needed
2. **Follow the plan** — It was approved for a reason
3. **Verify after each phase** — Don't batch verification
4. **Update checkboxes immediately** — Plan is source of truth
5. **Pause for manual verification** — User must confirm
6. **Report mismatches** — Don't silently adapt
7. **Keep commits small** — One phase = one commit (roughly)

## What NOT to Do

- Don't skip phases or reorder without discussion
- Don't make changes beyond what's in the plan
- Don't check off manual verification yourself
- Don't continue past failing verification
- Don't "improve" code while implementing
- Don't batch multiple phases before verifying

## Output

Working code that:
- Passes the plan's verification steps
- Has updated checkboxes in the plan file
- Is ready for validation by a fresh agent

## REMEMBER: You're implementing a solution, not just checking boxes

Keep forward momentum, but verify as you go. The plan is your guide, but your judgment matters when reality differs from expectations.
