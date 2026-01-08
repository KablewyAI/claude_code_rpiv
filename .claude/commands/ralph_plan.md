---
description: Autonomous planning mode - iterates until plan is comprehensive and actionable
---

# Ralph Plan

You are running in **AUTONOMOUS PLANNING MODE**. Keep iterating until the plan is bulletproof.

## The Ralph Philosophy

Like Ralph Wiggum, you are relentlessly optimistic. A good plan might take multiple iterations. You will keep refining, questioning, and improving until the plan is truly ready for implementation.

## Inputs

- Research: `@<PATH_TO_RESEARCH_MD>` (required)
- Goal: `<WHAT_TO_BUILD or change>`
- Constraints: `<OPTIONAL: time, scope, compatibility requirements>`

## Autonomous Planning Process

### Iteration 1: Draft Structure

1. **Read research thoroughly** — Full document, no skimming
2. **Identify the core changes** needed
3. **Draft initial phases** — Keep them small and verifiable
4. **List unknowns** — What would you need to verify during implementation?

### Iteration 2: Stress Test

For each phase, ask:
- Is this independently verifiable?
- What could go wrong?
- What's the rollback strategy?
- Are the file:line references accurate?

Refine phases based on answers.

### Iteration 3: Verification Design

For each phase, define:
- Exact commands to run
- Expected outputs
- Manual verification steps
- Edge cases to test

### Iteration 4+: Polish

- Remove ambiguity
- Add missing details
- Ensure backwards compatibility is addressed
- Verify all file paths still exist
- Check that test commands are correct

## Completion Criteria

Plan is complete when:
- [ ] Every phase is small enough to verify in isolation
- [ ] Every phase has automated AND manual verification
- [ ] File paths and symbols are verified to exist
- [ ] Rollback strategy is defined for each phase
- [ ] No "TBD" or "figure out later" items remain
- [ ] Someone else could implement this without asking questions

## Output Document

Write to: `thoughts/shared/plans/YYYY-MM-DD_<topic>_plan.md`

Use enhanced plan format:

```markdown
---
date: <ISO8601>
topic: <topic>
status: draft
branch: <branch>
git_commit: <hash>
research: <path to research doc>
tags: [plan, ralph, <components>]
iterations: <number of iterations>
---

# Plan: <topic>

## Goal
[Clear, measurable objective]

## Research Reference
[Link to research doc with key findings summary]

## Success Criteria
- [ ] [Measurable outcome 1]
- [ ] [Measurable outcome 2]
- [ ] [Measurable outcome 3]

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| [Risk 1] | Low/Med/High | Low/Med/High | [Strategy] |
| [Risk 2] | Low/Med/High | Low/Med/High | [Strategy] |

## Phase 0: Safety Setup
- [ ] Verify tests pass: `npm test`
- [ ] Create feature branch: `git checkout -b feature/...`
- [ ] Note baseline metrics (if applicable)

## Phase 1: [Name]

### Objective
[What this phase accomplishes]

### Changes
| File | Change | Lines |
|------|--------|-------|
| `path/to/file.js` | [Description] | 45-67 |
| `path/to/other.js` | [Description] | 12 |

### Implementation Notes
[Specific guidance, patterns to follow, gotchas to avoid]

### Verification

**Automated:**
```bash
npm run lint
npm test -- --grep "feature"
```
Expected: All pass

**Manual:**
- [ ] [Specific manual check]
- [ ] [Specific manual check]

### Rollback
```bash
git revert HEAD
```
Or: [specific manual steps]

## Phase 2: [Name]
[Same structure]

## Phase N: Integration & Cleanup

### Final Verification
```bash
npm run lint
npm test
npm run build
```

### Manual Acceptance
- [ ] [End-to-end user flow]
- [ ] [Edge case verification]
- [ ] [Performance check if relevant]

## Implementation Order

```
Phase 0 (setup)
    ↓
Phase 1 ──verify──→ Phase 2 ──verify──→ Phase 3
    ↓ (if fail)         ↓ (if fail)
  rollback            rollback
```

## Estimated Scope
- Files to modify: X
- New files: Y
- Tests to add: Z
- Complexity: Low/Medium/High
```

## Iteration Tracking

```
Iteration 1: Draft
- [x] Created 4 phases
- [ ] Gap: Phase 2 verification unclear

Iteration 2: Stress test
- [x] Identified rollback issue in Phase 3
- [x] Added missing error handling phase
- [ ] Gap: Test coverage unclear

Iteration 3: Verification
- [x] Added specific test commands
- [x] Defined manual verification
- [x] All phases independently verifiable

Iteration 4: Polish
- [x] Verified all file paths exist
- [x] Removed ambiguous language
- [x] Plan ready for implementation
```

## Self-Assessment

After each iteration:

1. **Clarity**: Could a junior dev follow this plan?
2. **Completeness**: Are there any "and then..." moments?
3. **Verifiability**: Can each phase be proven correct?
4. **Reversibility**: Can we undo any phase safely?
5. **Independence**: Does each phase stand alone?

If any answer is "no" → **iterate again**.

## When to Stop

Stop iterating when:
- All self-assessment questions pass
- You've verified file paths exist
- Test commands are correct
- No ambiguity remains

Do NOT stop because:
- The plan "looks good enough"
- You've written a lot already
- The first draft seemed complete

## The Ralph Mindset

> "I'm planning! I'm planning!"

A thorough plan prevents implementation pain. Each iteration makes the plan stronger. Trust the process.

## Chaining to Next Phase

When plan is complete:

```
## Plan Complete

Plan document: `thoughts/shared/plans/2024-01-15_feature_plan.md`
Iterations: 4
Phases: 5
Estimated files: 8

**Ready for implementation?**
Run: `/ralph_impl @thoughts/shared/plans/2024-01-15_feature_plan.md`

Or for autonomous implementation in a worktree:
```bash
# Create isolated worktree
git worktree add ../feature-worktree feature/branch-name

# Launch autonomous implementation
cd ../feature-worktree
claude --model opus "/ralph_impl @thoughts/shared/plans/..."
```
```
