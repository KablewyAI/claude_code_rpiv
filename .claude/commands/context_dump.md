---
description: Structured knowledge extraction interview - surfaces unwritten business context
---

# Context Dump

You are running a **structured knowledge extraction session**. The goal is to surface business logic, implicit contracts, and decision rationale that exists in the user's head but hasn't been documented yet.

This is NOT a coding session. This is an interview.

## When to Use

- Quarterly (or when the user feels like it)
- After a major feature ships (capture the "why" while it's fresh)
- When onboarding the codebase to a new team member or AI context
- When the user says "I should document why..."

## Process

### Phase 1: Identify Knowledge Gaps

Scan the codebase for areas with LOW "why" coverage. Check:

1. **BUSINESS_RULES.md** — What systems/features have no business rule entries?
2. **INVARIANTS.md** — Are there invariants the user takes for granted but hasn't written down?
3. **thoughts/shared/research/** — What areas of the codebase have never been researched?
4. **Code comments** — What critical files have few or no "why" comments?
5. **thoughts/shared/lessons/** — Are there recurring debugging patterns not yet captured?

Use sub-agents to scan:
- `@.claude/agents/codebase-locator.md` — Find files with zero research coverage
- `@.claude/agents/thoughts-locator.md` — Find which systems have documentation gaps

### Phase 2: Generate Interview Questions

Based on the gaps found, generate 10-15 specific questions organized by system. Prioritize:

1. **Bus factor risks** — Systems only the user understands
2. **Business logic** — Rules that aren't in code comments or BUSINESS_RULES.md
3. **Historical decisions** — "Why does X work this way?" for non-obvious patterns
4. **Cross-system contracts** — Implicit agreements between components
5. **Customer context** — Who uses what, and why it matters

Format questions as:

```
## System: [Name]

1. [Specific question about a specific file/function/pattern]
   Context: I see [code pattern] at [file:line] but I don't understand WHY it works this way.

2. [Question about a business rule]
   Context: The code does [X] but there's no documentation explaining the business reason.
```

### Phase 3: Interview

Present questions one system at a time. For each answer:

1. Listen (the user may answer briefly or expansively)
2. Ask ONE follow-up if the answer surfaces something important but vague
3. Don't interrogate — if they say "I don't remember" or "it just evolved that way," accept it

### Phase 4: Document

For each answer, route the knowledge to the RIGHT file:

| Knowledge Type | Destination |
|---------------|-------------|
| Business rule ("we do X because Y") | `BUSINESS_RULES.md` |
| System invariant ("X must never happen") | `INVARIANTS.md` |
| Historical decision ("we chose X over Y because Z") | ADR or plan's "Why Not" section |
| Cross-system contract ("X depends on Y doing Z") | `thoughts/shared/glossary.md` or code comment |
| Debugging lesson ("we learned the hard way that...") | `thoughts/shared/lessons/` |
| Process/workflow preference | `CLAUDE.md` or `MEMORY.md` |

After documenting, show the user what was added and where.

### Phase 5: Summary

```
## Context Dump Summary

### Knowledge Captured
- [N] business rules added to BUSINESS_RULES.md
- [N] invariants added to INVARIANTS.md
- [N] lessons captured in thoughts/shared/lessons/
- [N] glossary entries added
- [N] code comments added

### Systems With Remaining Gaps
- [System] — [what's still undocumented]

### Suggested Next Session Focus
- [Topic that surfaced during the interview but needs deeper exploration]
```

## Key Guidelines

1. **This is the user's knowledge, not yours.** Don't fill in answers from code reading. Ask, listen, document.
2. **Short answers are fine.** "Because compliance" is a valid answer. Document it as-is.
3. **Don't make it feel like homework.** Keep the pace conversational. Skip questions if the user seems done.
4. **Capture exact phrasing when possible.** The user's words often carry nuance that paraphrasing loses.
5. **Route to the right file.** Don't dump everything into one place. Each knowledge type has a home.

## Output

Updated files across the knowledge system. No new standalone document — the value is distributed to where future sessions will find it.
