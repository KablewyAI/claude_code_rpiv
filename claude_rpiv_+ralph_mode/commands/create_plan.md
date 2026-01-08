---
description: Create a detailed implementation plan through interactive research
---

# Create Implementation Plan

You are creating an **IMPLEMENTATION PLAN**. Do NOT implement yet.

## Initial Response

If no context provided:
> "I'm ready to help create an implementation plan. Please provide:
> - A description of what you want to build/change
> - Any relevant ticket/issue references
> - Path to research document (if exists): `@thoughts/shared/research/...`"

If context is provided, read all mentioned files FULLY before proceeding.

## Planning Process

### Step 1: Read Everything First
- Read any provided files completely (no limit/offset)
- Read referenced research documents
- Read related existing code
- **Never spawn sub-tasks before reading provided files yourself**

### Step 2: Gather Context
Spawn parallel research agents to fill gaps:

- `@.claude/agents/codebase-locator.md` — Find related files
- `@.claude/agents/codebase-analyzer.md` — Understand current implementation
- `@.claude/agents/codebase-pattern-finder.md` — Find patterns to follow
- `@.claude/agents/thoughts-locator.md` — Find related docs

Wait for all sub-tasks to complete before proceeding.

### Step 3: Ask Clarifying Questions
Only ask questions that code investigation cannot answer:
- Ambiguous requirements
- Business logic decisions
- User experience preferences
- Priority/scope trade-offs

Present your findings first, then ask focused questions.

### Step 4: Propose Structure
Before writing the full plan, propose the phasing:

```
Based on my research, I propose this structure:

Phase 0: Safety/Setup
- [ ] Identify existing tests
- [ ] Verify dev environment

Phase 1: [Name]
- [Brief description of changes]
- Verification: [how to verify]

Phase 2: [Name]
- [Brief description of changes]
- Verification: [how to verify]

Does this phasing make sense? Any phases to add/remove/reorder?
```

Get user feedback on structure before writing details.

### Step 5: Write Detailed Plan
Write to: `thoughts/shared/plans/YYYY-MM-DD_<short-topic>_plan.md`

Use this structure:

```markdown
---
date: <ISO8601>
topic: <short topic>
status: draft
branch: <branch>
git_commit: <hash>
tags: [plan, <feature-area>]
---

# Plan: <topic>

## Overview
[2-3 sentence summary of what this plan accomplishes]

## Current State
[Brief description of how things work today, with file:line references]

## Desired End State
- [ ] [Requirement 1]
- [ ] [Requirement 2]
- [ ] [Requirement 3]

## Phase 0 — Safety / Setup
- [ ] Identify current tests: `path/to/tests/`
- [ ] Verify dev environment: `npm run dev`
- [ ] Note any golden files / snapshots

## Phase 1 — [Name]

### Changes
- [ ] **[Change description]**
  - Files: `path/to/file.js`
  - Symbols: `functionName`, `ClassName`
  - Details: [specific changes needed]

### Tests
- [ ] Add/update tests for [what]
- [ ] Test file: `path/to/test.js`

### Verification
**Automated:**
- Command: `npm test`
- Expected: All tests pass

**Manual:**
- [ ] [Manual verification step]
- [ ] [Manual verification step]

## Phase 2 — [Name]
[Same structure as Phase 1]

## Rollback Plan
- What to revert if something goes wrong
- `git revert` or manual steps

## Success Criteria

### Automated (must pass)
- `npm run lint` — No errors
- `npm test` — All tests pass
- `npm run build` — Builds successfully

### Manual (verify before merge)
- [ ] [UI/UX verification]
- [ ] [Edge case testing]
- [ ] [Performance check if relevant]

## PR Checklist
- [ ] Tests pass
- [ ] Lints/formatting pass
- [ ] Docs updated (if user-facing)
- [ ] No leftover debug logs
- [ ] No TODO placeholders introduced
```

### Step 6: Present for Review
After writing the plan:
1. Present a summary to the user
2. Ask for feedback on each phase
3. Iterate based on input

## Key Guidelines

1. **Read files COMPLETELY** — No limit/offset, full context needed
2. **Research before asking** — Spawn agents, then ask questions
3. **Interactive throughout** — Don't write everything at once
4. **Separate success criteria** — Automated vs. manual verification
5. **No open questions in final plan** — Research or ask first
6. **Be specific about files** — Include paths and line numbers
7. **Small phases** — Each should be independently verifiable

## Planning Rules

- Keep phases small and independently verifiable
- After every phase: specify exact verification commands
- Prefer targeted tests over "run everything"
- Include file paths and exact symbols you'll touch
- Call out error handling and user-facing messages
- Call out backwards-compat concerns
- Do NOT add new dependencies unless explicitly required

## What NOT to Do

- Don't write the full plan without user input on structure
- Don't leave open questions in the final plan
- Don't create massive phases that can't be verified
- Don't skip verification commands
- Don't assume requirements—ask when unclear
- Don't implement during planning

## REMEMBER: Plans are collaborative

You're not writing a plan in isolation—you're working with the user to design something they understand and approve. Be interactive, seek feedback, and iterate.
