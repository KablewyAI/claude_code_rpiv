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

## Autonomous Research Process

### Iteration 1: Initial Exploration

1. **Decompose the research question** into sub-questions
2. **Spawn parallel research agents**:
   - `@.claude/agents/codebase-locator.md` — Find relevant files
   - `@.claude/agents/codebase-analyzer.md` — Understand implementations
   - `@.claude/agents/codebase-pattern-finder.md` — Find patterns
3. **Wait for all agents** to complete
4. **Assess coverage**: What do we know? What's still unclear?

### Iteration 2+: Fill Gaps

For each gap identified:
1. **Spawn targeted agents** to investigate specific unknowns
2. **Read files directly** that agents identified as important
3. **Trace code paths** that weren't fully understood
4. **Document findings** incrementally

### Completion Criteria

Research is complete when:
- [ ] All entry points are identified with file:line references
- [ ] Data flow is traced from input to output
- [ ] Key patterns and conventions are documented
- [ ] Configuration and dependencies are noted
- [ ] Test locations and commands are identified
- [ ] Open questions are either answered or explicitly documented as unknowns

## Output Document

Write to: `thoughts/shared/research/YYYY-MM-DD_<topic>.md`

Use standard research format from `/research_codebase`, but be MORE thorough:

```markdown
---
date: <ISO8601>
topic: <topic>
status: complete
branch: <branch>
git_commit: <hash>
tags: [research, ralph, <components>]
iterations: <number of iterations taken>
---

# Research: <topic>

## Research Question
<original question>

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

## Testing Strategy
[How to test changes in this area]

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

## Self-Assessment Checkpoints

After each iteration, ask yourself:

1. **Coverage**: Have I found all relevant files? (Use glob patterns to verify)
2. **Depth**: Do I understand HOW each component works, not just WHERE it is?
3. **Connections**: Do I understand how components interact?
4. **Completeness**: Could someone implement a change based on this research alone?

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
5. **Iterate until done** — Ralph doesn't give up

## The Ralph Mindset

> "Me fail research? That's unpossible!"

Keep going. The codebase will yield its secrets eventually. Each iteration gets you closer. Trust the process.

## Chaining to Next Phase

When research is complete, suggest next steps:

```
## Research Complete

Research document: `thoughts/shared/research/2024-01-15_feature.md`
Iterations: 3
Files analyzed: 24
Components documented: 6

**Ready for planning?**
Run: `/ralph_plan @thoughts/shared/research/2024-01-15_feature.md`
```
