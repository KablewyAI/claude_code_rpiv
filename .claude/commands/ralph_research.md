---
description: Autonomous research mode - keeps iterating until research is complete
---

# Ralph Research

You are running in **AUTONOMOUS RESEARCH MODE**. Keep iterating until research is thorough and complete.

## The Ralph Philosophy

Named after Ralph Wiggum - "dim-witted but relentlessly optimistic and undeterred." You will keep researching, exploring, and documenting until the codebase is fully understood for the given topic. Don't give up. Iterate.

## Inputs

- Topic: `<RESEARCH_TOPIC or question>`
- Scope: `<OPTIONAL: specific directories or components to focus on>`

## Pre-Flight: Worktree Thoughts Symlink

If you are running in a worktree (check: `git rev-parse --git-common-dir` differs from `git rev-parse --git-dir`), ensure `thoughts/shared/` is symlinked to the main repo:

```bash
bash scripts/setup-worktree-thoughts.sh "$(pwd)" "$(git rev-parse --git-common-dir | sed 's|/\.git$||')"
```

This ensures all research docs are written to the shared canonical location, not siloed in the worktree.

## Definition of Ready (DoR) — Can Research Start?

Before proceeding, verify ALL of the following:

- [ ] **Problem frame writable**: You can articulate WHO/WHEN/STATUS QUO/WHY (next section)
- [ ] **Complexity tier assessed**: `/ralph` has been run OR user has described the task with enough detail to frame it
- [ ] **Scope is clear**: You know what topic/area to research (not "look at the whole codebase")
- [ ] **Access confirmed**: You can read the relevant directories and files

If any DoR item fails, ask the user to clarify before proceeding. Don't start researching a vague question.

## Problem Frame (BEFORE Research Begins)

Before spawning any agents, force clarity on what you're investigating.

### One-Sentence Problem Statement

Write a single sentence answering all four elements:

| Element | Question |
|---------|----------|
| **WHO** | Who experiences this problem? |
| **WHEN** | Under what conditions? |
| **STATUS QUO** | What happens today? |
| **WHY UNACCEPTABLE** | Why is the current state insufficient? |

**Format**: "[WHO] experiences [STATUS QUO] when [WHEN], which is unacceptable because [WHY]."

If you cannot fill all four elements, ask the user to clarify before proceeding.

### Assumptions Carried In

Write down what you ALREADY BELIEVE before investigating. These are your priors — research should confirm or refute them, not just confirm.

- What do you assume is the root cause or core issue?
- What layer/component do you assume is involved?
- What do you assume about how the system currently works here?

### What We Don't Know

List at least 3 things you do NOT know. These become explicit research targets for the agents.

## Autonomous Research Process

### Iteration 0: Blocker Check (BEFORE deep research)

Before investing time in deep research, quickly assess: **can this work be validated?**

Flag blockers IMMEDIATELY if the topic involves:
- **Browser/UI behavior** you can't test (auth flows, visual rendering, real-time updates)
- **Production-only state** that can't be reproduced locally (specific org data, deployed config)
- **External service dependencies** you can't call (third-party APIs, auth tokens you don't have)
- **Hardware/environment constraints** (mobile-specific, OS-specific, network conditions)

If blockers exist, report them FIRST before any deep dive:

```
⚠️ VALIDATION BLOCKER

This research topic involves [browser auth flows / production data / etc.] which I cannot
test or validate directly.

**What I CAN research:** [code paths, configuration, architecture, test infrastructure]
**What I CANNOT validate:** [actual UI behavior, real auth flow, production state]
**What the user will need to verify manually:** [specific items]

Proceeding with code-level research. Findings will be flagged where manual validation is needed.
```

Don't let 3 iterations pass before surfacing this. Flag it at iteration 0.

### Iteration 1: Initial Exploration

1. **Decompose the research question** into sub-questions
2. **Search directly first** — Use Grep, Glob, and Read in the main thread. You already know this codebase. Most topics can be located with 3-5 targeted searches without spawning any agents.
3. **Spawn ONE sub-agent only if needed** — If the search space is genuinely broad or unfamiliar, spawn a single `codebase-analyzer` or `codebase-locator` agent for the hardest sub-question. Do NOT default to 3 parallel agents.
4. **Search for existing packages/libraries** — Before assuming we need to build custom, search npm/PyPI/crates.io/etc. for well-maintained packages that already solve the problem (see Package Evaluation section below)
5. **Run ast-grep structural queries** if relevant (see Structural Analysis section below)
6. **Assess coverage**: What do we know? What's still unclear?

**When to escalate to multiple agents** (rare — justify it):
- Completely unfamiliar subsystem with no obvious entry points
- Cross-cutting concern spanning 3+ independent components
- Time-critical research where parallelism matters more than token cost

### Iteration 2+: Fill Gaps

For each gap identified:
1. **Read files directly** — Trace code paths yourself before spawning agents
2. **Spawn a targeted agent** only for specific unknowns you can't resolve with direct reads
3. **Run targeted ast-grep queries** for anti-patterns, missing error handling, or structural issues discovered in earlier iterations
4. **Document findings** incrementally

### Definition of Done (DoD) — Is Research Complete?

Research is complete when:
- [ ] All entry points are identified with file:line references
- [ ] Data flow is traced from input to output
- [ ] Key patterns and conventions are documented
- [ ] Configuration and dependencies are noted
- [ ] Test locations and commands are identified
- [ ] Existing behavior is described in user-observable terms (inputs → outputs), not just implementation
- [ ] Error modes and boundary conditions are cataloged
- [ ] Infrastructure failure modes are documented (what happens when each dependency is down/slow/degraded)
- [ ] Test infrastructure is documented (framework, patterns, helpers, mocking conventions)
- [ ] Existing packages/libraries evaluated — viable candidates listed with health metrics, or explicitly documented that none exist
- [ ] Open questions are either answered or explicitly documented as unknowns

**The research DoD feeds directly into the plan's DoR.** If research is incomplete, planning starts on a shaky foundation. The planning phase (`ralph_plan`) requires Given/When/Then acceptance criteria per phase. The planner can only write specific, assertable Gherkin if the research provides:
- **Behavior descriptions** → become Given/When/Then scenarios
- **Error modes & boundaries** → become error and edge-case scenarios
- **Test infrastructure** → ensures the TDD red phase writes tests that fit the codebase

## Output Document

Write to: `thoughts/shared/research/YYYY-MM-DD_<topic>.md`

Use standard research format from `/research_codebase`, but be MORE thorough:

```markdown
---
date: <ISO8601>
topic: <topic>
status: complete
branch: <branch>
worktree: <worktree name if in a worktree, otherwise omit>
git_commit: <hash>
tags: [research, ralph, <components>]
iterations: <number of iterations taken>
---

# Research: <topic>

## Problem Frame

### Problem Statement
[One-sentence from pre-research framing]

### Assumptions Carried In
- [Assumption 1] — CONFIRMED / REFUTED / UNRESOLVED
- [Assumption 2] — CONFIRMED / REFUTED / UNRESOLVED

### What We Didn't Know (Pre-Research)
- [Unknown 1] — resolved / unresolved
- [Unknown 2] — resolved / unresolved

## Research Question
<original question>

## Validation Blockers (if any)
[⚠️ Flag anything that prevents full validation — browser needed, production-only, external API, etc.]
[If none, delete this section]

## Executive Summary
[Comprehensive summary - more detailed than standard research]

## Deep Dive

### Component 1: [Name]
[Exhaustive analysis with file:line references]

### Component 2: [Name]
[Exhaustive analysis with file:line references]

## Code Flow Diagrams
[ASCII diagrams of data/control flow]

## All Relevant Files
[Complete list, not just highlights]

## Configuration & Environment
[All config that affects this area]

## Existing Behavior (User-Observable)

Describe what the system does TODAY in terms a planner can turn into Given/When/Then.
Focus on observable inputs and outputs, not internal implementation.

### Current Behavior Map
| User Action / Trigger | Preconditions | Observable Outcome |
|---|---|---|
| [What the user does] | [What state must exist] | [What they see / what the system returns] |
| [Example: Search for properties] | [Authenticated, MLS access, listings exist] | [Filtered results with photos, paginated] |

### Input/Output Contracts
For each key operation in scope:
- **Input**: What parameters, what types, what's required vs optional
- **Output**: Response shape, status codes, error format
- **Side effects**: What state changes (DB writes, cache updates, events emitted)

### Auth & Permission Boundaries
- Who can do what? Which org types, roles, permission levels?
- What happens when unauthorized? (Error code, message, redirect)

## Error Modes & Boundary Conditions

### Known Error States
| Error Condition | How It's Handled Today | Error Code/Message |
|---|---|---|
| [e.g., Invalid input] | [e.g., Returns 400 with validation details] | [e.g., `400: "Missing required field: city"`] |
| [e.g., Unauthorized access] | [e.g., Returns 401] | [e.g., `401: "Authentication required"`] |
| [e.g., Resource not found] | [e.g., Returns 404] | [e.g., `404: "Property not found"`] |

### Boundary Conditions
- **Empty states**: What happens with zero results, empty input, null values?
- **Limits**: Max page size, rate limits, timeout thresholds, payload size limits
- **Concurrent access**: Any race conditions, optimistic locking, idempotency?
- **Data edges**: Unicode, special characters, very long strings, negative numbers

### Infrastructure Failure Modes
For each external dependency (database, API, cache, queue, auth service, etc.), document:

| Dependency | What Happens If Down | Current Handling | Error Differentiation |
|---|---|---|---|
| [e.g., Turso DB] | [e.g., User.findById throws] | [e.g., Generic catch returns 401] | [e.g., None — DB down looks like auth failure] |
| [e.g., External API] | [e.g., fetch times out] | [e.g., Unhandled — throws to caller] | [e.g., No retry-after, no circuit breaker] |

For each dependency, answer:
- Does the code differentiate "dependency unavailable" from "bad user input"?
- What retry behavior do callers exhibit on failure? Could this cause a retry storm?
- Is there a circuit breaker, fallback, or graceful degradation path?
- What does the end user see when this dependency fails?

**Why this matters:** Code that returns 401 ("auth failed") when the DB is down causes users to retry aggressively, hammering the DB during the exact moment it's struggling. The planner needs these failure modes to write proper Given/When/Then scenarios.

### Unhandled Error Paths
[Errors discovered during research that are NOT currently handled — these become high-priority edge-case scenarios in the plan]

## Test Infrastructure

### Framework & Tools
- Test runner: [e.g., Vitest, Jest, Playwright]
- Assertion library: [e.g., built-in, Chai]
- Mocking approach: [e.g., vi.mock, manual stubs, MSW]

### Existing Test Files (In Scope)
| Test File | What It Covers | Pattern |
|---|---|---|
| `path/to/test.ts` | [Description] | [unit / integration / contract / e2e] |

### Test Conventions to Follow
- How are tests organized? (describe/it nesting, file naming)
- How is test data set up? (fixtures, factories, inline)
- How are external services mocked? (specific mock patterns used)
- How are auth/permissions tested? (mock user setup pattern)
- Run command: `[exact command to run relevant tests]`

### Test Gaps (Currently Untested)
[Areas in scope that have NO existing test coverage — these become mandatory test targets in the plan]

## Existing Packages & Libraries

Evaluate whether existing packages solve (or partially solve) the problem before planning custom code.

### Search Performed
- [What was searched: npm, PyPI, GitHub, etc.]
- [Search terms used]

### Candidates Evaluated

| Package | Weekly Downloads | Last Published | License | Bundle Size | Verdict |
|---------|-----------------|----------------|---------|-------------|---------|
| [package-name] | [number] | [date] | [MIT/etc] | [size] | VIABLE / REJECTED / PARTIAL |

### Evaluation Notes

For each VIABLE or PARTIAL candidate:
- **What it solves**: [which parts of our problem]
- **What it doesn't**: [gaps we'd still need to fill]
- **API compatibility**: [works with our stack? Cloudflare Workers compatible? ESM?]
- **Maintenance signals**: [active maintainer? Open issues? Breaking changes?]
- **Lock-in risk**: [easy to replace later if it goes unmaintained?]
- **Compliance risk**: [see Compliance Gate below]

For REJECTED candidates:
- **Why rejected**: [too heavy, unmaintained, wrong runtime, license, compliance risk, etc.]

### Compliance Gate (HIPAA / SOC 2 / GDPR)

**Every candidate package MUST be evaluated through these lenses before being marked VIABLE.**

| Question | Answer | Risk |
|----------|--------|------|
| Does it process, store, or transmit PII/PHI? | Yes/No | If yes: does it send data to external servers, third-party APIs, or telemetry endpoints? |
| Does it phone home (analytics, telemetry, crash reporting)? | Yes/No | Any outbound data flow is a compliance surface — must be documented and controllable |
| Does it have sub-dependencies that phone home? | Yes/No/Unknown | Check transitive deps for telemetry, analytics SDKs |
| Is the data flow auditable? | Yes/No | Can we trace exactly what data goes where? Required for SOC 2 audit trail |
| Does it handle encryption/auth/tokens? | Yes/No | If yes: does it follow current best practices? Has it had security advisories? |
| License compatible with commercial use? | Yes/No | MIT, Apache 2.0, BSD = fine. GPL, AGPL, SSPL = flag for review |
| Can we self-host / run entirely within our infra? | Yes/No | Packages that require external SaaS calls add compliance scope |

**Auto-REJECT if any of these are true:**
- Sends PII/PHI to third-party servers we don't control
- Has telemetry that can't be disabled
- Requires a SaaS dependency that isn't covered by a BAA (HIPAA) or DPA (GDPR)
- Has known unpatched security vulnerabilities (check `npm audit` / Snyk / GitHub advisories)

**Flag for review (not auto-reject):**
- Handles encryption or auth (needs deeper security review)
- GPL/AGPL licensed (legal review needed)
- Large dependency tree (increases supply chain attack surface — relevant for SOC 2)

### Recommendation
- [ ] **Use package**: [name] — covers [X%] of the need, well-maintained, low lock-in
- [ ] **Build custom**: No viable packages found because [reason]
- [ ] **Hybrid**: Use [package] for [core functionality], build custom [specific piece]

[If no packages are relevant to this research topic, write "N/A — this topic is about internal architecture/debugging/refactoring, not a problem solvable by external packages" and delete the table above.]

## ast-grep Structural Analysis
[Queries run, patterns found, anti-patterns discovered]

## Risks & Gotchas
[Everything that could go wrong]

## Remaining Unknowns
[Anything that couldn't be determined - be honest]
```

## Iteration Tracking

Use TodoWrite to track your iterations:

```
Iteration 1: Initial exploration
- [x] Spawn locator agents
- [x] Identify 12 relevant files
- [ ] Gaps: auth flow unclear, config loading unknown

Iteration 2: Fill gaps
- [x] Trace auth flow from login to session
- [x] Found config in env.js and wrangler.toml
- [ ] Gap: error handling path still unclear

Iteration 3: Final gaps
- [x] Traced error handling through middleware
- [x] All major paths documented
- [x] Research complete
```

## Structural Analysis with ast-grep

ast-grep finds patterns that text grep CANNOT — it understands code structure via AST.

**When to use it**: Every research iteration. Text grep finds keywords; ast-grep finds how code is structured.

**How to run**: Use the Bash tool with `sg` commands. Always scope to relevant directories.

### Standard Queries to Run

Pick queries relevant to your research topic. These are starting points — write custom patterns for your specific investigation.

**Error handling gaps:**
```bash
# Fetch calls without try-catch (TypeScript)
sg -p 'await fetch($$$)' -l ts --no-ignore <directory>
sg -p 'try { $$$ await fetch($$$) $$$ } catch ($$$) { $$$ }' -l ts --no-ignore <directory>
# Compare: fetches outside try-catch are unprotected

# Async functions with no error handling
sg -p 'async function $NAME($$$) { $$$ }' -l ts <directory>
```

**Performance anti-patterns:**
```bash
# Await inside loops (potential N+1)
sg -p 'for ($$$) { $$$ await $$$; $$$ }' -l ts <directory>
sg -p 'while ($$$) { $$$ await $$$; $$$ }' -l ts <directory>

# Sequential awaits that could be parallel
sg -p 'await $A; await $B;' -l ts <directory>
```

**Security patterns:**
```bash
# SQL without parameterized queries
sg -p 'execute(`$$$${$$$}$$$`)' -l ts <directory>

# Unvalidated external input
sg -p '$REQ.query.$PARAM' -l ts <directory>
```

**Architecture patterns:**
```bash
# All exported functions in a module
sg -p 'export function $NAME($$$) { $$$ }' -l ts <directory>
sg -p 'export async function $NAME($$$) { $$$ }' -l ts <directory>

# Class method signatures
sg -p 'async $METHOD($$$): Promise<$RET> { $$$ }' -l ts <directory>
```

### Writing Custom ast-grep Patterns

For your specific research topic, craft patterns that reveal structural truths:

1. **Identify what you're looking for** — "all places X happens without Y"
2. **Write the positive pattern** — find where X happens
3. **Write the negative pattern** — find where X happens WITH Y
4. **Diff the results** — what's unprotected?

Use the `/ast-grep` skill reference if you need help with advanced YAML rules or pattern syntax.

### Documenting ast-grep Findings

In your research output, include an **ast-grep Findings** subsection:
```markdown
## ast-grep Structural Analysis

### Queries Run
| Pattern | Purpose | Matches |
|---------|---------|---------|
| `await fetch($$$)` not in try-catch | Unprotected network calls | 14 files |
| `for ($$$) { $$$ await $$$ }` | N+1 query patterns | 3 files |

### Key Structural Findings
- [Finding with file:line references]
- [Anti-pattern discovered]
```

## Self-Assessment Checkpoints

After each iteration, ask yourself:

1. **Problem Clarity**: Is the problem statement specific enough that someone with zero context would understand what is being investigated and why?
2. **Coverage**: Have I found all relevant files? (Use glob patterns to verify)
3. **Depth**: Do I understand HOW each component works, not just WHERE it is?
4. **Connections**: Do I understand how components interact?
5. **Completeness**: Could someone implement a change based on this research alone?
6. **Behavior**: Can I describe what the system does in user-observable terms (not just implementation)?
7. **Error Modes**: Have I cataloged how the system fails, not just how it succeeds?
7b. **Infrastructure Failures**: For every external dependency (DB, API, cache), have I documented what happens when it's down/slow? Does the code differentiate dependency failure from user error?
8. **Test Readiness**: Do I know the test framework, patterns, helpers, and conventions well enough to write tests that fit?
9. **Plannable**: Could a planner write specific Given/When/Then acceptance criteria from this research alone?
10. **Structure**: Did I use ast-grep to find patterns that text search would miss? (Anti-patterns, missing error handling, architectural violations)
11. **Build vs. Buy**: Have I searched for existing packages/libraries that solve this problem? Are candidates evaluated with health metrics, or is it explicitly documented that none exist or none are relevant?

If any answer is "no" → **iterate again**.

## When to Stop

Stop iterating when:
- All checkpoints pass
- You've hit 5+ iterations without new discoveries
- The same files keep appearing in searches

Do NOT stop just because:
- You found "some" information
- The first search returned results
- You're tired of searching

## Key Guidelines

1. **Exhaust all angles** — Search multiple ways for the same thing
2. **Read files fully** — No limit/offset, complete context
3. **Document as you go** — Don't wait until the end
4. **Be honest about gaps** — Unknown is better than guessed
5. **Always answer "so what?"** — end with concrete recommendations
6. **Iterate until done** — Ralph doesn't give up
7. **Use ast-grep for structural truth** — Text grep finds strings; ast-grep finds code structure. Use it to find anti-patterns, missing error handling, N+1 loops, unprotected fetches, and architectural violations that string matching will miss

## The Ralph Mindset

> "Me fail research? That's unpossible!"

Keep going. The codebase will yield its secrets eventually. Each iteration gets you closer. Trust the process.

## Chaining to Next Phase

When research is complete, **commit to main immediately** so it's available to worktrees:

```bash
git add thoughts/shared/research/YYYY-MM-DD_<topic>.md
git commit -m "docs: Add <topic> research"
git push
```

Then suggest next steps:

```
## Research Complete

Research document: `thoughts/shared/research/2024-01-15_feature.md`
Iterations: 3
Files analyzed: 24
Components documented: 6
Committed to main: ✓

**Ready for planning?**
Run: `/ralph_plan @thoughts/shared/research/2024-01-15_feature.md`
```
