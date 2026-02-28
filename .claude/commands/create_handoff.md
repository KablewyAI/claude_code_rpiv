---
description: Create a handoff document for another agent to continue your work
---

# Create Handoff

You are creating a **HANDOFF DOCUMENT** so a fresh agent can continue without reading the whole thread.

## Goal

Compact and summarize your context without losing key details. The next agent should be able to pick up exactly where you left off.

## Process

### Step 1: Determine Filepath & Metadata

Create file at: `thoughts/shared/handoffs/YYYY-MM-DD_HH-MM-SS_<description>.md`

Where:
- `YYYY-MM-DD` is today's date
- `HH-MM-SS` is current time in 24-hour format
- `<description>` is a brief kebab-case description

Examples:
- `2024-01-15_14-30-00_dark-mode-implementation.md`
- `2024-01-15_09-15-30_api-refactor-phase-2.md`

Gather metadata:
```bash
git rev-parse --short HEAD  # commit hash
git branch --show-current   # branch name
date -Iseconds              # ISO timestamp
```

### Step 2: Write Handoff Document

Use this structure:

```markdown
---
date: <ISO8601 with timezone>
topic: <short topic>
status: active
branch: <branch name>
worktree: <worktree name if in a worktree, otherwise omit>
git_commit: <commit hash>
repository: <repo name>
tags: [handoff, <feature-area>]
last_updated: <YYYY-MM-DD>
---

# Handoff: <topic>

## Task(s)
[Description of tasks you were working on with status of each]

- **[Task 1]**: [Status: completed/in-progress/planned]
  - [Brief description of what was done or needs doing]
- **[Task 2]**: [Status]
  - [Brief description]

If working from a plan, note which phase you're on:
> Currently on Phase 2 of `thoughts/shared/plans/2024-01-15_feature_plan.md`

## Critical References
[2-3 most important files that MUST be read to continue]

- `thoughts/shared/plans/...` — The implementation plan
- `thoughts/shared/research/...` — Research context
- `path/to/key/file.js` — [Why it's critical]

## Recent Changes
[Changes you made to the codebase in file:line syntax]

- `src/components/Feature.js:45-67` — Added new handler
- `src/utils/helpers.js:12` — Fixed edge case
- `tests/feature.test.js` — Added test coverage

## Learnings
[Important things the next agent should know]

- Pattern: [Description of pattern discovered]
- Gotcha: [Something that was tricky]
- Root cause: [If debugging, what you found]
- Context: [Important background]

## Artifacts
[Exhaustive list of artifacts you produced or updated]

- `thoughts/shared/plans/2024-01-15_feature_plan.md` — Implementation plan
- `thoughts/shared/research/2024-01-15_feature.md` — Research doc
- `src/components/Feature.js` — New component
- `tests/feature.test.js` — Test file

## Action Items & Next Steps
[Prioritized list for next agent]

1. [ ] [Immediate next action]
2. [ ] [Following action]
3. [ ] [After that]

If blocked:
> **Blocked on**: [What's blocking progress]
> **To unblock**: [What needs to happen]

## Current State
[What's working, what's failing]

**Working:**
- [What's functioning correctly]

**Failing/Remaining:**
- [What's not working yet]
- [Error messages if relevant]

## Other Notes
[Anything else useful that doesn't fit above]

- Related files: `path/to/related/`
- Useful commands: `npm run specific-thing`
- External docs: [Links if relevant]
```

### Step 3: Review and Confirm

Before saving, verify:
- [ ] All critical references are included
- [ ] Recent changes are documented with file:line
- [ ] Next steps are clear and actionable
- [ ] Current state accurately reflects reality
- [ ] Learnings capture non-obvious insights

## Key Guidelines

1. **More information, not less**
   - This is a minimum template
   - Include more if necessary

2. **Be thorough and precise**
   - Include both high-level objectives and details
   - Use file:line references

3. **Avoid excessive code snippets**
   - Brief snippets for key changes only
   - Prefer file:line references agent can follow

4. **Focus on continuity**
   - What does the next agent need to succeed?
   - What would YOU want to know if resuming?

5. **Capture learnings**
   - Non-obvious insights are gold
   - Patterns, gotchas, context

## What NOT to Do

- Don't include full code blocks (use file:line refs)
- Don't skip the "Learnings" section
- Don't be vague about next steps
- Don't forget to list artifacts
- Don't omit error messages if debugging

## Output

A handoff document that allows a fresh agent to continue your work without context loss.

After creating, inform the user:
> "Handoff created at `thoughts/shared/handoffs/...`. A new agent can resume with `/resume_handoff @<path>`"
