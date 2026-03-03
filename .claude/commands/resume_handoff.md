---
description: Resume work from a handoff document created by a previous session
---

# Resume Handoff

You are **RESUMING** from a handoff document. Continue where the previous session left off.

## Goal

Pick up work from a handoff document without needing the full conversation history. Execute the documented next steps.

## Inputs

- Handoff: `@<PATH_TO_HANDOFF_MD>`

## Initial Response

**If no handoff path provided:**
> "Which handoff should I resume from? Please provide the path (e.g., `thoughts/shared/handoffs/2024-01-15_14-30-00_feature.md`)"

**If path provided:** Proceed with context gathering.

## Resume Process

### Step 1: Read Handoff Document
Read the full handoff to understand:
- **Task(s)**: What are we trying to accomplish?
- **Critical References**: What files must I read?
- **Recent Changes**: What was already done?
- **Learnings**: What should I know?
- **Action Items**: What should I do next?
- **Current State**: What's working/failing?

### Step 2: Gather Referenced Context
Read all critical references in parallel:
- Plan file (if referenced)
- Research file (if referenced)
- Key code files mentioned
- Any artifacts listed

Use sub-agents if deep investigation needed:
- `@.claude/agents/codebase-analyzer.md` — Understand current state
- `@.claude/agents/thoughts-locator.md` — Find related docs

### Step 3: Verify Current State
Before continuing, verify documented state is accurate:

```bash
git status                    # Check branch and changes
git log --oneline -5          # See recent commits
git diff --stat               # Check uncommitted changes
```

Compare against handoff:
- Is the branch correct?
- Are documented changes present?
- Are "failing" items still failing?
- Any unexpected changes since handoff?

### Step 4: Present Resume Summary
Confirm understanding before proceeding:

```
## Resuming: <topic>

**From handoff**: `thoughts/shared/handoffs/...`
**Created**: [date from handoff]

**Goal**: [From handoff task description]

**Already completed**:
- [List from handoff]

**Current state**:
- Branch: [branch name]
- [Status of failing/remaining items]

**I will now**:
1. [First action item]
2. [Second action item]
3. [Third action item]

**Learnings I'll apply**:
- [Key learning from handoff]

Shall I proceed?
```

### Step 5: Execute Action Items
Upon confirmation:
- Execute documented action items in order
- Follow plan verification commands (if implementing)
- Apply learnings from the handoff
- If something doesn't match, stop and report

### Step 6: Update or Create New Handoff
If stopping before completing all items:
- Create a new handoff with `/create_handoff`
- Reference the original handoff
- Document new learnings and progress

## Handling Discrepancies

If current state doesn't match handoff:

```
## State Mismatch Detected

**Handoff says**: [documented state]
**Actually found**: [current state]

**Possible reasons**:
1. [Hypothesis]
2. [Hypothesis]

**Options**:
A) Investigate the discrepancy first
B) Continue with documented next steps anyway
C) Create new handoff reflecting current state

How should I proceed?
```

**Never silently continue** if state is significantly different.

## Handling Stale Handoffs

If handoff seems outdated (significant time passed, code evolved):

```
## Handoff May Be Stale

This handoff was created on [date]. Since then:
- [X commits on this branch]
- [Changes to key files]
- [Other relevant changes]

**Recommendation**:
- Re-run `/research_codebase` to understand current state
- Update the plan if needed
- Then continue with implementation

Shall I investigate what's changed, or proceed with caution?
```

## Key Guidelines

1. **Trust but verify**
   - Handoff documents facts, but verify current state
   - Things may have changed since handoff was written

2. **Follow the plan**
   - If a plan exists, follow its phases and verification
   - Don't improvise beyond documented next steps

3. **Apply learnings**
   - The previous agent documented insights for a reason
   - Use patterns and avoid gotchas they discovered

4. **Incremental progress**
   - Complete one action item at a time
   - Verify after each before continuing

5. **Transparent status**
   - Report what matches/doesn't match
   - Flag any surprises

6. **Clean handoffs**
   - If stopping, create new handoff for next session
   - Leave clear breadcrumbs

## What NOT to Do

- Don't assume handoff is current without verification
- Don't skip documented action items
- Don't improvise beyond the plan
- Don't continue if state significantly differs
- Don't ignore learnings from previous session
- Don't leave stale handoff as latest if creating new one

## Output

Continue execution from where the previous session left off.
Create new handoff if stopping before completion.
