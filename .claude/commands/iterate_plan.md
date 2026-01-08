---
description: Update an existing plan based on feedback without starting over
---

# Iterate Plan

You are **ITERATING** an existing plan. Do NOT implement. Do NOT start over.

## Goal

Surgically update an existing plan based on user feedback while preserving what's already correct.

## Inputs

- Plan: `@<PATH_TO_PLAN_MD>`
- Feedback: `<USER_FEEDBACK or paste>`

## Initial Response

**If no plan file provided:**
> "Which plan should I iterate on? Please provide the path (e.g., `thoughts/shared/plans/2024-01-15_feature_plan.md`)"

**If plan provided but no feedback:**
> "I've read the plan. What changes or feedback should I incorporate?"

**If both provided:** Proceed immediately.

## Iteration Process

### Step 1: Read and Understand
- Read the full plan before making any changes
- Identify the "Desired end state" criteria
- Understand the current phase structure
- Note verification commands already specified
- **Never spawn sub-tasks before reading the plan yourself**

### Step 2: Research (Only If Needed)
Only spawn research tasks if changes require new technical understanding.

Use sub-agents in parallel when investigating:
- `@.claude/agents/codebase-locator.md` — Find affected files
- `@.claude/agents/codebase-analyzer.md` — Understand implementation details
- `@.claude/agents/codebase-pattern-finder.md` — Find patterns to follow

### Step 3: Present Understanding
Before making changes, confirm with user:

```
## Understanding Your Feedback

Based on your feedback, I understand you want to:
1. [Change 1]
2. [Change 2]

This will affect:
- **Phase X**: [modification needed]
- **Phase Y**: [modification needed]
- **New Phase?**: [if adding phases]

Is this understanding correct? Shall I update the plan?
```

### Step 4: Surgical Updates
Upon confirmation:
- Make minimal edits to incorporate feedback
- Preserve existing structure where possible
- Update verification commands if scope changed
- Add new phases only if necessary
- Update the `date` in frontmatter to today
- Change `status` to `draft` if it was `approved`

### Step 5: Present Changes
After updating, show what changed:

```
## Plan Updated

**Changes made:**
1. [Change 1 description]
2. [Change 2 description]

**Phases affected:**
- Phase X: [what changed]
- Phase Y: [what changed]

Please review the updated plan at `thoughts/shared/plans/...`
```

## Success Criteria Structure

When updating verification sections, maintain two categories:

**Automated verification** (must exist):
- Build/compile commands
- Test commands
- Lint/type-check commands

**Manual verification** (if applicable):
- UI testing steps
- Real-world scenario testing
- Edge case verification

## Key Guidelines

1. **Be skeptical of problematic requests**
   - If feedback introduces risk, flag it
   - Ask clarifying questions before risky changes

2. **Surgical edits over rewrites**
   - Don't rewrite sections that don't need changing
   - Preserve original author's style and structure

3. **Thoroughness before changes**
   - Read the FULL plan before editing
   - Understand context of each phase

4. **Interactive confirmation**
   - Always confirm understanding before updating
   - Present summary of what will change

5. **Resolve ambiguity first**
   - If feedback is unclear, ask before guessing
   - Don't make assumptions about intent

## Handling Risky Feedback

If the feedback seems problematic:

```
## Concern About Requested Change

You've asked me to [change]. I have a concern:

**Risk**: [What could go wrong]
**Impact**: [Who/what is affected]

**Options:**
A) Proceed anyway with the change
B) Modify the approach to [safer alternative]
C) Skip this change and discuss further

How would you like to proceed?
```

## What NOT to Do

- Don't implement the plan
- Don't delete phases without confirmation
- Don't change verification commands without flagging
- Don't add phases beyond what feedback requires
- Don't critique the original plan's quality
- Don't suggest improvements beyond feedback scope
- Don't rewrite sections unnecessarily

## Output

Update the plan file in place at its original location.
Preserve the original filename unless topic fundamentally changed.
