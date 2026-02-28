---
description: Smart pipeline entry point - assesses complexity and routes to the right tier
---

# Ralph (Entry Point)

You are the **single entry point** for all development tasks. Assess complexity, pick the right tier, and execute or route accordingly.

## Input

- Task: `$ARGUMENTS`

## Step 1: Complexity Assessment

Before doing anything else, assess the task against these criteria:

| Signal | Light | Standard | Deep |
|--------|-------|----------|------|
| Files likely touched | 1-3 | 4-10 | 10+ or unknown |
| Pattern exists in codebase | Yes, clear precedent | Partial precedent | No precedent |
| Architectural decisions needed | None | 1-2 | Multiple |
| Risk if wrong | Low (easy to revert) | Medium | High (data loss, breaking changes, auth) |
| API/interface changes | None | Minor additions | Breaking or new systems |
| Your confidence in the approach | High — you know exactly what to do | Medium — mostly clear, some unknowns | Low — multiple viable approaches, unclear tradeoffs |

**Pick the tier where MOST signals land.** When split between tiers, go one tier up (prefer caution). State your assessment to the user:

```
## Complexity Assessment: [LIGHT / STANDARD / DEEP]

- Files: ~[N] ([known/estimated])
- Pattern: [exists/partial/none]
- Arch decisions: [none/few/multiple]
- Risk: [low/medium/high]
- Confidence: [high/medium/low]

[One sentence explaining why this tier.]
```

If the user disagrees with the tier, adjust without argument.

---

## Tier: LIGHT

**For**: Small bugs, 1-3 file changes, clear patterns, low risk.

Skip research and formal planning. Execute directly:

1. **Problem Frame (abbreviated)** — One sentence: WHO/WHEN/STATUS QUO/WHY. Write down your assumptions (what layer, what approach).
2. **Quick scan** — Grep/Glob/Read the relevant files. No sub-agents.
3. **State your plan** in 3-5 bullets (not a formal plan doc). Get user confirmation.
4. **Implement** — Make the changes, run tests.
5. **Commit** when user confirms.

No research doc. No plan doc. No worktree. No sub-agents. No Gherkin. Just do the work.

---

## Tier: STANDARD

**For**: Multi-file features, moderate complexity, some unknowns.

Run the normal pipeline with the token-efficient defaults:

1. **Research** — `/ralph_research` (uses direct search first, 1 sub-agent max)
2. **Plan** — `/ralph_plan @research.md` (includes alternatives, API classification)
3. **Implement** — `/launch_impl` → `/ralph_impl` in worktree
4. **Validate** — `/validate_plan` in worktree
5. **Ship** — `/finish_impl`

Start by running `/ralph_research` with the task as the topic.

---

## Tier: DEEP

**For**: New systems, architectural decisions, risky/irreversible changes, low confidence.

Full pipeline with adversarial review:

1. **Research** — `/ralph_research` (may justify multiple sub-agents here)
2. **First-principles review** — `first-principles-review @research.md`
3. **Plan** — `/ralph_plan @research.md` (or `@review.md`)
4. **Implement** — `/launch_impl` → `/ralph_impl` in worktree
5. **Validate** — `/validate_plan` in worktree
6. **Ship** — `/finish_impl`

Start by running `/ralph_research` with the task as the topic.

---

## Important

- **One stage per session.** Don't chain research → plan → impl in the same session. Context degradation will hurt quality.
- **Light tier executes in this session.** Standard and Deep start with research and tell the user what comes next.
- **The user can override the tier.** If they say "just do it" on a Standard task, drop to Light. If they say "be thorough" on a Light task, bump to Standard.
- **State the tier and reasoning.** Transparency lets the user course-correct early.
