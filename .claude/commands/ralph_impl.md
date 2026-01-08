---
description: Autonomous implementation mode - implements plan phases iteratively until complete
---

# Ralph Impl

You are running in **AUTONOMOUS IMPLEMENTATION MODE**. Keep iterating through phases until the plan is fully implemented and verified.

## The Ralph Philosophy

Ralph Wiggum doesn't give up. Neither do you. Each phase might require multiple attempts. Errors are learning opportunities. Keep pushing forward until the code works.

## Inputs

- Plan: `@<PATH_TO_PLAN_MD>` (required)
- Start Phase: `<OPTIONAL: phase number to start from, default 0>`

## Autonomous Implementation Process

### Pre-Flight Check

1. **Read the entire plan** — Understand the full scope
2. **Verify environment**:
   ```bash
   git status          # Clean working directory?
   npm test            # Tests passing?
   git branch          # Correct branch?
   ```
3. **Create implementation branch** if not exists
4. **Set up todo tracking** for phases

### Phase Loop

For each phase:

```
┌─────────────────────────────────────────────┐
│ PHASE N                                     │
├─────────────────────────────────────────────┤
│ 1. Read phase requirements                  │
│ 2. Implement changes                        │
│ 3. Run automated verification               │
│    ├─ PASS → Mark complete, next phase      │
│    └─ FAIL → Debug and retry (up to 3x)     │
│ 4. If 3 failures → Stop and report          │
└─────────────────────────────────────────────┘
```

### Iteration Strategy

**On Success:**
- Mark phase checkbox in plan
- Commit changes with descriptive message
- Proceed to next phase

**On Failure (Attempt 1-2):**
- Read error message carefully
- Identify root cause
- Fix the minimal issue
- Retry verification

**On Failure (Attempt 3):**
- Document the failure
- Create handoff document
- Stop and report to user

## Implementation Rules

### Do:
- Make the smallest change that satisfies the phase
- Run verification after each phase
- Commit after each successful phase
- Update plan checkboxes as you complete
- Follow patterns from the codebase

### Don't:
- Skip phases or reorder without updating plan
- Make "improvements" beyond the plan
- Continue past failing verification
- Batch multiple phases before committing
- Guess at implementations — check the plan

## Progress Tracking

Use TodoWrite extensively:

```
Implementation: Feature X
━━━━━━━━━━━━━━━━━━━━━━━━

Phase 0: Setup
├─ [x] Create feature branch
├─ [x] Verify tests pass
└─ Status: COMPLETE

Phase 1: Core Changes
├─ [x] Modify handler.js
├─ [x] Add validation
├─ [ ] Run tests ← CURRENT (Attempt 2)
└─ Status: IN PROGRESS

Phase 2: Tests
├─ [ ] Add unit tests
├─ [ ] Add integration test
└─ Status: PENDING

Phase 3: Cleanup
├─ [ ] Remove debug logs
├─ [ ] Update comments
└─ Status: PENDING
```

## Commit Strategy

After each successful phase:

```bash
# Stage specific files from this phase
git add path/to/changed/files

# Commit with phase reference
git commit -m "feat: [phase description]

Phase N of implementation plan.
See: thoughts/shared/plans/YYYY-MM-DD_feature_plan.md"
```

**No Claude attribution** — commits should look human-authored.

## Verification Protocol

After each phase:

1. **Run automated checks**:
   ```bash
   npm run lint      # Linting
   npm test          # Tests
   npm run build     # Build (if applicable)
   ```

2. **Check for regressions**:
   - Did existing tests break?
   - Are there new lint errors?
   - Does the build succeed?

3. **Verify phase objectives**:
   - Does the change match the plan?
   - Is the expected behavior present?

## Failure Handling

### Lint Failures
```
Attempt 1: Auto-fix
  npm run lint -- --fix

Attempt 2: Manual fix
  Read error, fix specific issue

Attempt 3: Document and stop
  May need plan revision
```

### Test Failures
```
Attempt 1: Read test output
  Understand what's expected vs actual
  Fix implementation to match

Attempt 2: Check test correctness
  Is the test testing the right thing?
  Fix test OR implementation

Attempt 3: Document and stop
  Complex issue needs human review
```

### Build Failures
```
Attempt 1: Read error message
  Usually type errors or missing imports
  Fix the specific issue

Attempt 2: Check dependencies
  Missing packages? Wrong versions?

Attempt 3: Document and stop
  May need environment investigation
```

## Autonomous Session Setup

For true autonomous operation, launch in a worktree:

```bash
# Create isolated worktree
git worktree add ~/worktrees/feature-name feature/branch

# Launch autonomous Claude session
cd ~/worktrees/feature-name
claude --dangerously-skip-permissions \
       --model opus \
       "/ralph_impl @thoughts/shared/plans/YYYY-MM-DD_feature_plan.md"
```

**Warning**: `--dangerously-skip-permissions` allows autonomous file edits. Use with caution and always in a worktree!

## Completion Criteria

Implementation is complete when:
- [ ] All phase checkboxes are marked in plan
- [ ] All automated verification passes
- [ ] All commits are made
- [ ] No debug code or TODOs remain
- [ ] Ready for validation

## Output

When complete:

```
## Implementation Complete

Plan: `thoughts/shared/plans/2024-01-15_feature_plan.md`
Branch: `feature/dark-mode`
Commits: 5
Phases completed: 5/5

**Verification Summary:**
- Lint: ✓ Pass
- Tests: ✓ 47 passing, 0 failing
- Build: ✓ Success

**Ready for validation?**
Run: `/validate_plan @thoughts/shared/plans/2024-01-15_feature_plan.md`

**Ready to commit/PR?**
Run: `/commit` then `/describe_pr`
```

When stopped (failure):

```
## Implementation Paused

Plan: `thoughts/shared/plans/2024-01-15_feature_plan.md`
Stopped at: Phase 2, Attempt 3

**Failure:**
```
[Error message]
```

**What was tried:**
1. [Attempt 1 description]
2. [Attempt 2 description]
3. [Attempt 3 description]

**Diagnosis:**
[Best guess at root cause]

**Recommended next steps:**
1. [Specific action]
2. [Specific action]

**Handoff created:**
`thoughts/shared/handoffs/2024-01-15_feature_handoff.md`

Resume with: `/resume_handoff @thoughts/shared/handoffs/...`
```

## The Ralph Mindset

> "I bent my implementation!"

Errors happen. Tests fail. Builds break. That's normal. What matters is persistence. Each failure teaches you something. Keep iterating until it works.

## Safety Limits

- **Max 3 attempts per phase** before stopping
- **Max 10 phases** before requiring human check-in
- **Always commit working code** before moving on
- **Never force-push** or destructive git operations
- **Create handoff** if stopping mid-implementation
