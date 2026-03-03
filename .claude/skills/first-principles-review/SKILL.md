---
name: first-principles-review
description: Challenge the direction before planning. Inspired by Rich Hickey's Hammock Driven Development, this skill forces explicit problem statements, separates facts from assumptions, surfaces missing tradeoffs, and generates unanswered questions. Produces a thinking document designed to be re-read after sleeping on it. Slots optionally before /ralph_plan in the Ralph Pipeline.
---

# First Principles Review

You are conducting a first-principles review — a structured thinking exercise that challenges direction before committing to a plan. This is NOT a plan, NOT a research doc, and NOT an action list. It is a **thinking document** designed to surface misconceptions, hidden assumptions, and missing tradeoffs.

Read the reference: [Hammock Driven Development concepts](references/hammock-driven-dev.md)

See also: [Dev Process Wisdom from 17 Talks](../../thoughts/shared/research/2026-02-25_talk-transcripts-dev-process-wisdom.md)

## When to Use This

This skill fills the **adversarial gap** between `/ralph_research` and `/ralph_plan`. Research gathers information. Planning commits to a direction. This skill challenges whether the gathered information supports the direction you're about to commit to.

Use it:
- Between research and plan when direction is not obvious
- When multiple smart people disagree on approach
- When the "obvious" solution feels too easy
- When building something new, not extending something proven
- When you catch yourself saying "I think" instead of "I know"
- When the research doc's Problem Frame assumptions were never tested

Do NOT use this for bug fixes with clear root causes, well-understood incremental features, or tasks where the pattern is established and proven.

## Input

The user provides a topic, question, or area of concern. Examples:
- `first-principles-review the two-layer tool security gating system`
- `first-principles-review our MCP catalog deployment architecture`
- `first-principles-review @thoughts/shared/research/2026-02-20_auth-refactor.md`

If the input references an `@<path>`, read that document for context before starting.

## Pre-Flight

### Worktree Thoughts Symlink

If running in a worktree (check: `git rev-parse --git-common-dir` differs from `git rev-parse --git-dir`), ensure `thoughts/shared/` is symlinked to the main repo:

```bash
bash scripts/setup-worktree-thoughts.sh "$(pwd)" "$(git rev-parse --git-common-dir | sed 's|/\.git$||')"
```

This ensures all review docs are written to the shared canonical location, not siloed in the worktree.

### Create Output Directory

```bash
mkdir -p thoughts/shared/reviews
```

---

## Phase 1: Re-examine the Problem

> Hickey: "If you can't state the problem, you don't understand it."

The research doc should contain a Problem Frame. If it doesn't, flag this gap.

Read the Problem Frame and ask:

### Has the problem shifted?
After reading full research, does the original statement still hold? Often research reveals the stated problem is a symptom of something deeper.

- **Original problem statement**: [quote from research]
- **Revised statement** (if changed): [WHO/WHEN/STATUS QUO/WHY format]
- **Why it shifted**: [what research revealed]
- If unchanged: "The original framing holds. Evidence: [cite findings]."

### Were the assumptions confirmed?
For each assumption in the Problem Frame: CONFIRMED, REFUTED, or UNRESOLVED. Flag any assumption that was NEVER TESTED during research.

### What new unknowns emerged?
List unknowns discovered during research that were NOT in the original list.

**If the problem has fundamentally shifted**, stop and present the reframing to the user before Phase 2.

---

## Phase 2: Enumerate Facts

> Hickey: "Facts are not opinions. How do you KNOW this?"

Spawn **three parallel sub-agents** to gather concrete evidence from the codebase:

1. **codebase-locator** — Find all files, directories, and entry points relevant to the topic. Map the boundaries: what's in scope, what's adjacent, what's explicitly out of scope.

2. **codebase-analyzer** — For each component identified by the locator, trace the actual implementation. Read the code. Report what it DOES, not what you think it does or what comments say it does.

3. **codebase-pattern-finder** — Find similar patterns elsewhere in the codebase. How have related problems been solved before? What conventions exist? Where do conventions break?

**After agents return**, compile a facts table. For EVERY fact, classify:

| # | Fact | Source | Confidence |
|---|------|--------|------------|
| 1 | [What is true] | [File:line, test output, user statement, docs] | High / Med / Low |

**Confidence criteria**:
- **High**: Directly observed in code or verified by test output
- **Medium**: Stated in documentation or comments but not verified against current code
- **Low**: Inferred from pattern, heard secondhand, or based on outdated info

Flag any "fact" where the source is "I assumed" or "it's always been that way" — these are assumptions, not facts. Move them to Phase 3.

---

## Phase 3: Surface Assumptions

> Hickey: "Assumptions are the raw material of misconceptions."

For EACH component or decision area identified in Phase 2, answer these four questions:

### 3a. Why Was It Built This Way?

What was the original motivation? Is there a commit message, PR description, or research doc that explains the choice? If not, the reasoning is lost — flag this as an assumption.

### 3b. What Constraints Have Expired?

Technical constraints change. Dependencies get updated. Platform limits increase. Team size changes. For each constraint that influenced the current design: **is it still true?**

Examples of expired constraints:
- "We did X because the library didn't support Y" — does it now?
- "We chose this approach for performance" — has the bottleneck shifted?
- "This was built when we had one customer" — do we have many now?

### 3c. What Was Never Evaluated?

What alternatives were never considered? This is different from "we considered X and rejected it." The most dangerous assumptions are the ones that were never even questioned.

### 3d. What Coupling Is Accidental?

Which dependencies between components exist because of implementation convenience rather than inherent domain relationships? Accidental coupling is a sign that the abstraction boundaries may be wrong.

**Output format** for each assumption:

```
### Assumption: [brief name]
- **What we believe**: [the assumption]
- **Evidence for**: [what supports it]
- **Evidence against**: [what challenges it, or "none found"]
- **If wrong, impact**: [what breaks if this assumption is false]
- **How to verify**: [concrete step to confirm or refute]
```

---

## Phase 4: Find Missing Tradeoffs

> Hickey: "If you have only one option, you haven't thought enough."

Go through every significant design decision in the current system (or the proposed direction) and enumerate alternatives.

For EACH decision:

```
### Decision: [what was decided]
- **Current approach**: [what we do]
- **Alternative A**: [different approach]
  - Makes easy: [what]
  - Makes hard: [what]
  - Prevents: [what]
- **Alternative B**: [another approach]
  - Makes easy: [what]
  - Makes hard: [what]
  - Prevents: [what]
- **Why current was chosen**: [reason, or "unknown — no record found"]
```

**Single-option flag**: If you cannot identify at least one meaningful alternative for a decision, flag it explicitly:

```
> SINGLE-OPTION FLAG: [decision] has no documented alternatives.
> This means either: (a) the space hasn't been explored, or
> (b) it's genuinely the only viable option — state which and why.
```

Single-option decisions are not automatically bad, but they deserve explicit acknowledgment.

---

## Phase 5: Identify Unknowns

> Hickey: "Questions are more important than answers at this stage."

Generate unanswered questions. For each question, categorize and explain WHY it matters:

| Category | Question | Why It Matters | How to Resolve |
|----------|----------|---------------|----------------|
| **Behavioral** | How does the system actually behave under [condition]? | [impact if wrong] | [test, trace, or measure] |
| **Requirement** | Do users actually need [capability]? | [wasted effort if not] | [ask, observe, or instrument] |
| **Architectural** | What happens when [constraint] changes? | [rework scope] | [prototype, spike, or model] |
| **Temporal** | How long until [assumption] expires? | [technical debt timeline] | [monitor, review date] |
| **Measurement** | How would we know if [approach] is working? | [can't course-correct without signal] | [define metric, instrument] |

**Minimum**: Generate at least 3 questions per category (15 total). If a category has fewer than 3, explain why it's not applicable to this topic.

---

## Phase 6: Synthesize

> Hickey: "Feed the background mind well, then step away."

Write a synthesis section with exactly these subsections:

### Problem Restated
One paragraph. After all this analysis, restate the problem. Has it changed from Phase 1? If so, explain how and why.

### Confidence Map
For each major component or decision area, rate your confidence that the current direction is correct:

| Area | Confidence | Basis |
|------|-----------|-------|
| [area] | High / Med / Low | [why — reference specific facts and assumptions] |

### Highest-Risk Assumptions
List the top 3 assumptions that, if wrong, would most change the direction. For each: what would you do differently if it were false?

### Top 5 Unanswered Questions
From Phase 5, select the 5 questions that most need answers before committing to a direction. Rank them by impact, not ease of answering.

### What NOT to Do Yet
Based on this review, what actions or decisions should be explicitly deferred? What would be premature to commit to right now?

### Re-Read Prompt
Write 2-3 sentences designed for the author to re-read after sleeping on it. These should be the most provocative, assumption-challenging observations from the review. The goal is to trigger the background mind.

---

## Self-Assessment Checkpoints

Before marking the review as complete, ALL of the following must be "yes":

1. **Problem clarity**: Can the problem statement be understood by someone with zero context?
2. **Fact grounding**: Is every fact in Phase 2 sourced with file:line or concrete evidence?
3. **Assumption honesty**: Have you identified at least 3 non-obvious assumptions?
4. **Alternative breadth**: Does every significant decision have at least one documented alternative?
5. **Question depth**: Are there at least 15 categorized questions in Phase 5?
6. **Synthesis coherence**: Does the confidence map reference specific facts and assumptions (not vibes)?
7. **Restraint**: Does the document end with questions and observations, NOT prescriptions or action items?

If any checkpoint fails, iterate. Minimum 2 iterations (draft, then stress-test against the checkpoints).

---

## Output Document

Write to: `thoughts/shared/reviews/YYYY-MM-DD_<topic-slug>.md`

Use this frontmatter:

```yaml
---
date: <ISO8601>
topic: <short-topic>
status: complete
branch: <branch name>
worktree: <worktree name, if applicable>
git_commit: <commit hash>
tags: [review, first-principles, <component tags>]
iterations: <number of iterations>
---
```

### Document Structure

```markdown
# First Principles Review: <Topic>

## Problem Statement
[Phase 1 output]

## Facts
[Phase 2 table]

## Assumptions
[Phase 3 structured blocks]

## Missing Tradeoffs
[Phase 4 decision blocks with single-option flags]

## Unknowns
[Phase 5 categorized table]

## Synthesis
[Phase 6 — all subsections including Re-Read Prompt]

## Iteration Log
| # | Focus | Changes |
|---|-------|---------|
| 1 | Initial draft | Full document generated |
| 2 | Stress-test | [what changed after self-assessment] |
```

---

## Chaining

After completing the review, suggest:

> This review is ready for `/ralph_plan @<review_path>`. However, it was **designed to be slept on**. Consider re-reading the "Re-Read Prompt" section tomorrow before planning.

The review document can be passed as input to `/ralph_plan` via the `@<path>` convention. The plan phase will have access to the facts, assumptions, and open questions identified here.

---

## What This Is NOT

- **Not a plan**: No action items, no implementation steps, no timelines
- **Not a research doc**: Research gathers information. This challenges the interpretation of that information
- **Not a decision**: This surfaces options and unknowns. Decisions happen in `/ralph_plan`
- **Not a blocker**: If the team has already decided and just needs to execute, use `/ralph_plan` directly. This skill is for when the direction itself is uncertain
