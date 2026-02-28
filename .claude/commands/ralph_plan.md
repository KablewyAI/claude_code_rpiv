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

## Pre-Flight: Worktree Thoughts Symlink

If you are running in a worktree (check: `git rev-parse --git-common-dir` differs from `git rev-parse --git-dir`), ensure `thoughts/shared/` is symlinked to the main repo:

```bash
bash scripts/setup-worktree-thoughts.sh "$(pwd)" "$(git rev-parse --git-common-dir | sed 's|/\.git$||')"
```

This ensures all plan docs are written to the shared canonical location, not siloed in the worktree.

## Definition of Ready (DoR) — Can Planning Start?

Before planning, verify ALL of the following:

- [ ] **Research doc exists and is committed to `main`** — The `@<path>` reference resolves to a real file
- [ ] **Research DoD is met** — All entry points identified, data flow traced, behavior described in user-observable terms, error modes cataloged, test infrastructure documented, open questions resolved or scoped out
- [ ] **User has reviewed research findings** — Or at minimum, no unresolved blockers were flagged in the research doc
- [ ] **Goal is clear** — You can state the desired end state in concrete, measurable terms

If any DoR item fails, **STOP**. Report the gap:
- Missing research doc → suggest `/ralph_research` first
- Research incomplete → suggest another iteration of research
- Goal unclear → ask the user to clarify

**The plan's DoR IS the research's DoD.** These gates are designed to chain — if research was done properly, planning can start immediately.

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
- What are the edge cases?
- What are we missing?
- What's the rollback strategy?
- Are the file:line references accurate?
- Do the acceptance criteria meet the Gherkin Quality Checklist (see below)?
- For each major design decision, has at least one alternative approach been identified with an explicit tradeoff?
- If the research identified viable packages/libraries, has a Build vs. Buy decision been made with explicit rationale? Are we building custom code that a well-maintained package already handles?
- For any API change: is it classified as growth (accretion/relaxation/fixation) or breakage?
- For any phase that calls external services, databases, or APIs: what happens when the dependency is down/slow? Does the error response differentiate "service unavailable" from "bad input"? Could failure trigger a retry storm?

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

## Definition of Done (DoD) — Is the Plan Ready for Implementation?

A plan is **Done** (and therefore meets `ralph_impl`'s DoR) when ALL of the following are met:

- [ ] Every phase has a clear, concise description of what changes
- [ ] Every behavior-changing phase has Given/When/Then acceptance criteria
- [ ] Acceptance criteria cover happy path, error cases, and edge cases
- [ ] Phases touching external dependencies have failure scenarios (dependency down/slow/degraded)
- [ ] Every phase is small enough to verify in isolation
- [ ] Every phase has automated AND manual verification
- [ ] Every phase has a complexity estimate (S/M/L)
- [ ] File paths and symbols are verified to exist
- [ ] Dependencies between phases are explicit
- [ ] Rollback strategy is defined for each phase
- [ ] No "TBD" or "figure out later" items remain
- [ ] Someone else (or an autonomous agent) could implement this without asking questions
- [ ] Every major design decision has at least one documented alternative with explicit tradeoffs
- [ ] If research identified viable packages, a Build vs. Buy decision is documented with rationale
- [ ] Any API changes are classified as growth or breakage
- [ ] Glossary updated: new terms added, renamed terms updated, deprecated terms removed (`thoughts/shared/glossary.md`)

**If the plan does not meet DoD, it should NOT be passed to `ralph_impl`.**
The plan's DoD IS `ralph_impl`'s DoR. These gates chain — no artifact crosses a phase boundary until its DoD is met.
Iterate until it does.

## Output Document

Write to: `thoughts/shared/plans/YYYY-MM-DD_<topic>_plan.md`

Use enhanced plan format:

```markdown
---
date: <ISO8601>
topic: <topic>
status: draft
branch: <branch>
worktree: <worktree name if in a worktree, otherwise omit>
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

## Alternatives Considered

For each major design decision, document at least one alternative.
**REQUIRED**: If the research doc identified viable packages/libraries, include a Build vs. Buy decision here.

### Decision: Build vs. Use Package (if research identified candidates)
- **Chosen approach**: [Use package X / Build custom / Hybrid]
- **Compliance cleared**: [Yes — passed all compliance gate checks / No — rejected on compliance grounds / N/A — doesn't touch PII/PHI or external data flows]
- **Alternative**: [The other option]
  - Makes easy: [what]
  - Makes hard: [what]
  - Why not chosen: [specific reason — maintenance burden, bundle size, runtime compat, lock-in, compliance risk, etc.]

### Decision: [what was decided]
- **Chosen approach**: [what and why]
- **Alternative**: [different approach]
  - Makes easy: [what]
  - Makes hard: [what]
  - Why not chosen: [specific reason]

## API Change Classification (if applicable)

| Endpoint / Interface | Change | Type | Safe? |
|---|---|---|---|
| [endpoint] | [what changes] | Accretion / Relaxation / Fixation / Requires-more / Provides-less | Yes / No |

Growth (accretion, relaxation, fixation) = safe. Breakage = needs migration plan.
Delete this section if no API changes.

## Phase 0: Safety Setup
- [ ] Verify tests pass: `npm test`
- [ ] Create feature branch: `git checkout -b feature/...`
- [ ] Note baseline metrics (if applicable)

## Phase 1: [Name]

### Objective
[What this phase accomplishes]

### Complexity: S / M / L

### Changes
| File | Change | Lines |
|------|--------|-------|
| `path/to/file.js` | [Description] | 45-67 |
| `path/to/other.js` | [Description] | 12 |

### Acceptance Criteria (Given/When/Then)

Write acceptance criteria for any phase that adds or modifies behavior.
These become the failing tests in TDD during implementation.

```gherkin
Scenario: [Happy path description]
  Given [precondition / setup state]
  When [action the code performs]
  Then [expected outcome / assertion]

Scenario: [Error / edge case description]
  Given [precondition / setup state]
  When [action that should fail or hit edge case]
  Then [expected error behavior / graceful handling]

Scenario: [Dependency failure — REQUIRED for any phase calling DB/API/external service]
  Given [the external dependency is unavailable or degraded]
  When [the action that depends on it is triggered]
  Then [error response differentiates from user error, e.g., 503 not 401]
    And [response includes appropriate retry guidance if applicable]
```

**Dependency failure scenarios are REQUIRED** for any phase that calls a database,
external API, cache, or other service. The scenario must verify that:
1. The error response differentiates "service unavailable" from "bad user input"
2. The failure doesn't trigger retry storms (e.g., returning 401 for a DB outage causes users to retry credentials)
3. Appropriate status codes are used (503 for service issues, not 500 or 401)

Skip acceptance criteria ONLY for phases that are purely setup/config/refactor
with no new behavior (e.g., "create feature branch", "update wrangler.toml").

### Implementation Notes
[Specific guidance, patterns to follow, gotchas to avoid]

### Verification

**Automated:**
```bash
npm run lint
npm test -- --grep "feature"
```
Expected: All pass, including new tests from acceptance criteria above

**Manual:**
- [ ] [Specific manual check]
- [ ] [Specific manual check]

### Rollback
```bash
git revert HEAD
```
Or: [specific manual steps]

## Phase 2: [Name]
[Same structure — include Acceptance Criteria for behavior-changing phases]

## Gherkin Quality Checklist

During Iteration 2 (Stress Test), validate every Given/When/Then scenario against these rules.
If a scenario fails any rule, rewrite it before the plan is considered Ready.

### Quality Rules

For each scenario, verify:

1. **Given** specifies WHO (user type, permissions, org context) and WHAT STATE exists (data, config)
   - Bad: `Given a user`
   - Good: `Given an authenticated user with MLS access in org "mls-org"`

2. **When** describes ONE user action or system event — not implementation details
   - Bad: `When a POST request is sent to /api/v1/search with body {...}`
   - Good: `When they search for properties with filters city="Phoenix", maxPrice=500000`

3. **Then** uses specific, assertable values — never "it works" or "results are returned"
   - Bad: `Then results are returned`
   - Good: `Then results contain only properties where city="Phoenix" AND price < 500000`

4. **Error scenarios** specify the error type AND code/message
   - Bad: `Then an error is returned`
   - Good: `Then a 401 error is returned with message "Authentication required"`

5. **Each scenario tests ONE behavior** — not a chain of unrelated assertions
   - Bad: `Then search returns results AND the cache is updated AND a log entry is created`
   - Good: Three separate scenarios, one for each behavior

6. **No implementation leaking** — describe behavior, not database operations or internal APIs
   - Bad: `Given a row exists in the properties table with id=123`
   - Good: `Given a property listing exists in Phoenix priced at $450,000`

7. **Dependency failure scenarios exist** for any phase calling external services
   - Bad: Only happy path + "invalid input" scenarios
   - Good: Includes "Given the database is unavailable / When user authenticates / Then 503 'Service temporarily unavailable' is returned (not 401)"
   - The error response must be distinguishable from user error (DB down ≠ bad password)

### Anti-Patterns to Reject

| Anti-Pattern | Problem | Fix |
|---|---|---|
| `Then it works` | Not assertable | Specify what "works" means concretely |
| `Given the system is set up` | What setup? | List specific preconditions |
| `When the function is called` | Implementation detail | Describe the user action or trigger |
| `Then results are returned successfully` | "Successfully" is meaningless | Specify shape, count, or content of results |
| `Given valid input` | Valid how? | Specify the actual input values |

### Quick Self-Test

For each Then clause, ask: **"Could I write an assert statement from this?"**
- `Then results are returned` → `assert(results)` — too weak, proves nothing
- `Then results contain 3 properties all in Phoenix` → `assert(results.length === 3); results.forEach(r => assert(r.city === 'Phoenix'))` — specific, falsifiable

If you can't write a concrete assertion, the scenario is too vague. Rewrite it.

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

1. **Clarity**: Could a junior dev (or autonomous agent) follow this plan?
2. **Completeness**: Are there any "and then..." moments?
3. **Testability**: Does every behavior-changing phase have Given/When/Then acceptance criteria?
4. **Verifiability**: Can each phase be proven correct via automated tests?
5. **Reversibility**: Can we undo any phase safely?
6. **Independence**: Does each phase stand alone?
7. **Definition of Ready**: Does the plan meet ALL DoR criteria above?
8. **Alternatives**: Does every significant decision have at least one documented alternative?
9. **API Safety**: Are all API changes classified as growth or breakage?
10. **Production Failure Modes**: For every phase that calls a DB/API/service, is there a scenario for when that dependency is down? Does the error differentiate from user error?
11. **Build vs. Buy**: If the research found viable packages, is there a documented decision on whether to use them or build custom? Is the rationale specific (not just "we prefer custom")?

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

When plan is complete, **commit to main immediately** so it's available to worktrees:

```bash
git add thoughts/shared/plans/YYYY-MM-DD_<topic>_plan.md
git commit -m "docs: Add <topic> plan"
git push
```

**CRITICAL**: The plan MUST be committed to main BEFORE creating a worktree. Claude Code resolves `@<path>` file references at invocation time — before any pre-flight script runs. If the plan isn't in the worktree's checkout, `/ralph_impl @thoughts/shared/plans/...` won't find it.

Then suggest next steps:

```
## Plan Complete

Plan document: `thoughts/shared/plans/2024-01-15_feature_plan.md`
Iterations: 4
Phases: 5
Estimated files: 8
Committed to main: ✓

**Ready for implementation?**

1. Create a worktree named after the plan slug:
   claude --worktree <plan-slug>

2. Inside the worktree, create feature branches in sub-repos:
   cd <project>-backend && git checkout -b bugfix/<plan-slug>
   cd <project>-frontend && git checkout -b feature/<plan-slug>  # if needed

3. Run implementation:
   /ralph_impl @thoughts/shared/plans/2024-01-15_feature_plan.md
```
