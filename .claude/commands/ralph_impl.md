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

0. **Worktree thoughts symlink** — If in a worktree, ensure `thoughts/shared/` is symlinked:
   ```bash
   bash scripts/setup-worktree-thoughts.sh "$(pwd)" "$(git rev-parse --git-common-dir | sed 's|/\.git$||')"
   ```

0b. **Plan file existence check** — Verify the plan file is accessible. If the `@<path>` input didn't resolve (empty or missing), the plan was likely not committed to main before the worktree was created.
   - Run the symlink script above first
   - If the file still doesn't exist: **STOP**. Report:
     ```
     ⚠️ PLAN FILE NOT FOUND

     The plan file could not be resolved. This usually means the plan wasn't
     committed to main before this worktree was created.

     Fix: In your main session (not this worktree):
       1. git add thoughts/shared/plans/<plan-file>.md
       2. git commit -m "docs: Add <plan> plan"
       3. git push

     Then recreate this worktree from the updated HEAD.
     ```
   - Do NOT proceed with implementation without the plan file.

1. **Read the entire plan** — Understand the full scope
2. **Definition of Ready gate** — Verify the plan meets DoR before starting:
   - [ ] Every behavior-changing phase has Given/When/Then acceptance criteria
   - [ ] Acceptance criteria cover happy path, error, and edge cases
   - [ ] Every phase has a complexity estimate (S/M/L)
   - [ ] Dependencies between phases are explicit
   - [ ] File paths and symbols are verified to exist
   - [ ] No "TBD" or "figure out later" items remain

   **If the plan fails DoR: STOP. Do not implement.** Report the gaps and suggest
   running `/ralph_plan` or `/iterate_plan` to fix the plan first.
2b. **Detect worktree context**:
   ```bash
   cat .worktree-info 2>/dev/null
   ```
   If `.worktree-info` exists, parse `slug`, `prefix`, `repos`, and `main_repo`. All git operations (status, diff, branch, add, commit) and test runs must target **each sub-repo**:
   ```bash
   # For each repo in .worktree-info repos list:
   cd <worktree-dir>/<project>-<repo>
   ```
   If `.worktree-info` does NOT exist, you are on main — run all commands in the current directory as normal.

3. **Verify environment** (per sub-repo if in worktree, otherwise current directory):
   ```bash
   git status          # Clean working directory?
   npm test            # Tests passing?
   git branch          # Correct branch?
   ```
4. **Create implementation branch** if not exists
5. **Set up todo tracking** for phases

### Phase Loop (TDD-Integrated)

For each phase:

```
┌──────────────────────────────────────────────────────┐
│ PHASE N                                              │
├──────────────────────────────────────────────────────┤
│ 1. Read phase requirements + acceptance criteria     │
│                                                      │
│ 2. IF phase has Given/When/Then acceptance criteria: │
│    a. Write failing tests from criteria (RED)        │
│    b. Run tests — new tests FAIL, existing PASS     │
│    c. Implement minimum code to pass (GREEN)         │
│    d. Run full test suite — all pass                 │
│    e. Refactor if needed (keep tests green)          │
│                                                      │
│ 3. ELSE (setup/config/refactor — no new behavior):  │
│    a. Implement changes                              │
│    b. Run full test suite — all pass                 │
│                                                      │
│ 4. Definition of Done gate (see below)               │
│    ├─ PASS → Mark complete, commit, next phase       │
│    └─ FAIL → Debug and retry (up to 3x)              │
│ 5. If 3 failures → Stop and report                   │
└──────────────────────────────────────────────────────┘
```

### TDD Discipline

When a phase has acceptance criteria (Given/When/Then):

**RED — Write Failing Tests First:**
- Translate each Given/When/Then scenario into a test function
- Each scenario = at least one test case
- Run tests — new tests MUST fail (confirms they test real behavior, not a tautology)
- Existing tests MUST still pass (no regressions from test setup)

**GREEN — Minimum Implementation:**
- Write the smallest amount of code that makes each failing test pass
- Do NOT add behavior beyond what the tests require
- Run tests after each change — stop as soon as all pass

**REFACTOR — Clean Up (Optional):**
- Only if the green code has obvious duplication or unclear structure
- Run tests after any refactor — must stay green
- Do NOT add new behavior during refactor

### Iteration Strategy

**On Success (DoD passed):**
- Mark phase checkbox in plan
- Commit changes with descriptive message (tests + implementation together)
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

DoR Gate: PASSED ✓

Phase 0: Setup (no tests needed)
├─ [x] Create feature branch
├─ [x] Verify tests pass
├─ DoD: PASSED ✓
└─ Status: COMPLETE

Phase 1: Core Changes [M]
├─ [x] Write failing tests from acceptance criteria (RED)
├─ [x] Confirm new tests fail, existing pass
├─ [x] Implement handler changes (GREEN)
├─ [ ] Run full suite ← CURRENT (Attempt 2)
├─ DoD: PENDING
└─ Status: IN PROGRESS

Phase 2: Search Feature [L]
├─ [ ] Write failing tests from acceptance criteria (RED)
├─ [ ] Implement search logic (GREEN)
├─ [ ] Refactor if needed
├─ DoD: PENDING
└─ Status: PENDING

Phase 3: Cleanup (no tests needed)
├─ [ ] Remove debug logs
├─ DoD: PENDING
└─ Status: PENDING
```

## Commit Strategy

After each successful phase, commit in each affected sub-repo (if in a worktree) or in the current directory (if on main):

```bash
# If in a worktree, cd to the sub-repo first:
# cd <worktree-dir>/<project>-<repo>

# Stage specific files from this phase
git add path/to/changed/files

# Commit with phase reference
git commit -m "feat: [phase description]

Phase N of implementation plan.
See: thoughts/shared/plans/YYYY-MM-DD_feature_plan.md"
```

If in a worktree with multiple sub-repos, commit separately in each sub-repo that has changes for this phase.

**No Claude attribution** — commits should look human-authored.

## Definition of Done (Per Phase)

A phase is **Done** when ALL of the following are met:

| DoD Criteria | Verification |
|---|---|
| Code is written | Implementation complete per plan |
| New tests written (if behavior-changing phase) | Failing tests written BEFORE implementation, now passing |
| All acceptance criteria fulfilled | Every Given/When/Then scenario has a passing test |
| No regressions | Full test suite passes (existing + new) |
| Build succeeds | `npm run build` (if applicable) |
| No known blocking bugs | No failing tests, no skipped assertions |
| Committed to branch | `git commit` after DoD passes |

**Do NOT mark a phase complete if any DoD criterion is unmet.**

### Verification Commands

After each phase:

1. **Run automated checks**:
   ```bash
   npm run lint      # Linting
   npm test          # Tests (existing + new)
   npm run build     # Build (if applicable)
   ```

2. **Check for regressions**:
   - Did existing tests break?
   - Are there new lint errors?
   - Does the build succeed?

3. **Verify acceptance criteria**:
   - Does every Given/When/Then scenario from the plan have a passing test?
   - Does the change match the plan?
   - Flag anything requiring manual browser testing (don't silently skip it)

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

## Completion Criteria (Definition of Done — Full Implementation)

Implementation is complete when:
- [ ] All phase checkboxes are marked in plan
- [ ] Every phase passed its DoD gate
- [ ] Every behavior-changing phase has new tests covering its acceptance criteria
- [ ] Full test suite passes (existing + all new tests)
- [ ] All commits are made
- [ ] No debug code or TODOs remain
- [ ] Branch builds and is deployable
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
