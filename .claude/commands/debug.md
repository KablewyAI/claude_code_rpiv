You are doing **INVESTIGATION ONLY**. Do NOT implement fixes. Do NOT edit files.

## Goal
Help troubleshoot issues during manual testing by examining logs, state, and history. Report findings with evidence so the user can decide next steps.

## CRITICAL CONSTRAINT
**You MUST NOT edit any files.** This is an investigation-only mode. Your job is to gather evidence and report findings, not to fix problems.

## Inputs
- Problem description: <WHAT_IS_FAILING>
- Plan/ticket (optional): @<PATH_TO_PLAN_MD>

## Initial Response

If a plan/ticket is provided:
> "I see you're testing [topic from plan]. What specific issue are you encountering?"

If no context provided:
> "What problem are you experiencing? Please describe what you expected vs. what happened."

## Investigation Tools

You have access to investigate:

### Logs
- Application logs (check common locations)
- Error logs and stack traces
- Recent log entries around the time of failure

### State
- Database state (if D1/SQLite accessible)
- File system state
- Environment variables (non-sensitive)

### Git History
- Current branch and status
- Recent commits
- Uncommitted changes
- Diff of recent modifications

### Runtime
- Running processes
- Service status
- Network/port availability

## Flag Blockers Immediately

Before diving into investigation, check: **can you actually validate this?**

If the problem requires any of the following that you cannot do, flag it NOW — not after 20 minutes of investigation:
- Browser interaction (login flows, UI rendering, visual state)
- Authenticated API calls you can't make
- Production-only behavior that can't be reproduced locally
- Real-time/WebSocket behavior that needs a running client

```
⚠️ BLOCKER: This issue requires [browser testing / production access / etc.]
which I cannot perform. I can investigate the code paths and form a hypothesis,
but I cannot validate the fix. Here's what I CAN do: [specific investigation scope]
```

Don't let the user invest time in a direction you can't close.

## Investigation Workflow

### Step 1: Understand the Problem
- Read any provided plan/ticket for context
- Clarify the expected vs. actual behavior
- Identify when the problem started (if known)

### Step 2: State Your Hypothesis First

Before touching any code, state:
1. **What do you think is causing this?** (Your initial hypothesis)
2. **What code path do you expect is involved?** (Not just the file — the specific execution path from user action to failure)
3. **What else could it be?** (At least one alternative explanation)

This prevents anchoring on the first plausible cause and missing the real one.

### Step 3: Establish Baseline
Run parallel investigations to gather state:

**Git State**:
```bash
git status
git log --oneline -10
git diff --stat
```

**Recent Changes**:
- What files were modified recently?
- What was the last successful state?

### Step 4: Trace the Actual Execution Path

**Do NOT skip this step.** Follow the code from user action → through the real code path → to where it fails.

- Show file:line references at each step
- Verify each step actually EXECUTES in the reported scenario
- Don't assume — read the code and confirm the path

**Common mistakes to avoid:**
- Fixing an init path when the bug is in a query path
- Fixing "no such table" but missing "no such column" in the same flow
- Diagnosing "code not deployed" when the real issue is runtime state (DB, DO storage)

### Step 5: Targeted Investigation
Based on the problem type, spawn parallel sub-agents:

For **runtime errors**:
- Check logs for stack traces
- Look for error patterns
- Identify the failing component

For **unexpected behavior**:
- Trace the code path
- Check configuration
- Verify data state

For **test failures**:
- Read test output
- Compare expected vs actual
- Check test fixtures/mocks

Use sub-agents for deep investigation:
- `@.claude/agents/codebase-analyzer.md` — Trace code paths
- `@.claude/agents/codebase-locator.md` — Find related files

### Step 6: Rule Out Alternatives

Before concluding, explicitly rule out at least one alternative cause:
- Is it a deployment issue? (Check what's actually deployed vs. local)
- Is it a config issue? (Check wrangler.toml, env vars, secrets)
- Is it a wrong code path? (Confirm your traced path is the one that runs)
- Is it a race condition? (Check async flows, DO state, concurrent access)

State WHY each alternative is NOT the cause, with evidence.

### Step 7: Describe the Reproducing Test

Before proposing any fix, describe the test that would reproduce this bug:

```
## Reproducing Test

Test file: `path/to/test.ts`
Describe block: "[existing or new describe block]"

Test: "should [expected behavior that is currently broken]"
  Setup: [what state/mocks are needed]
  Action: [what function/endpoint to call with what args]
  Expected: [what SHOULD happen]
  Actual: [what CURRENTLY happens — the bug]
```

**Why this matters:** If you can't describe a concrete test, your understanding of the bug is
too vague to propose a fix. The test description forces you to be specific about:
- What preconditions trigger the bug
- What the correct behavior should be
- What assertion would fail

This test description becomes the first thing written when switching to implementation mode (TDD red phase).

### Step 8: Compile Evidence
Gather concrete evidence:
- Exact error messages
- Relevant log snippets
- State snapshots
- Code references (file:line)

### Step 9: Report Findings

Present findings in this structure:

```
## Debug Report: [Brief Problem Description]

### Blockers (if any)
[⚠️ Flag anything that prevents full validation — browser needed, production-only, etc.]

### Problem Summary
[What the user reported — expected vs. actual behavior]

### Evidence Found

#### Logs
[Relevant log snippets with timestamps]

#### State
[Database/file state observations]

#### Git Status
[Branch, recent commits, uncommitted changes]

### Execution Path Trace
[Step-by-step code path from user action to failure, with file:line at each step]
1. User does X → `file.ts:123` handles request
2. Calls `ServiceY.method()` → `service.ts:456`
3. Fails at → `service.ts:478` because [specific reason]

### Analysis

#### Root Cause Hypothesis
[Most likely cause based on evidence]

#### Supporting Evidence
1. [Evidence point 1 with file:line]
2. [Evidence point 2 with file:line]

#### Alternative Hypotheses Ruled Out
- [Alternative 1] — Ruled out because [evidence]
- [Alternative 2] — Ruled out because [evidence]

### Reproducing Test
[Description of the test that would reproduce this bug]
- **Setup**: [preconditions]
- **Action**: [function/endpoint call]
- **Expected**: [correct behavior]
- **Actual**: [current broken behavior]
- **Test file**: `path/to/test.ts`

### Recommended Next Steps
1. [Specific action to take]
2. [Specific action to take]

### Suggested Fix Location
- File: `path/to/file.js:123`
- Change: [description of what needs to change]
- **Verify this code path actually executes**: [confirmation that this is the right location]

### Files to Investigate Further
- `path/to/file.js:123` — [why]
- `path/to/other.js:456` — [why]
```

## Key Guidelines

1. **Evidence over speculation**
   - Only report what you can verify
   - Include exact error messages and line numbers
   - Mark hypotheses clearly as hypotheses

2. **Parallel investigation**
   - Spawn multiple sub-agents for efficiency
   - Gather logs, state, and git info simultaneously

3. **Minimal footprint**
   - Read files, don't edit them
   - Query state, don't modify it
   - Observe, don't intervene

4. **Actionable output**
   - Findings should point to specific files/lines
   - Next steps should be concrete actions
   - Help user decide, don't decide for them

## What You CAN Do

- Read any files
- Run read-only commands (git status, git log, git diff)
- Query databases (SELECT only)
- Check logs
- Trace code paths
- Spawn investigation sub-agents

## What You CANNOT Do

- Edit files
- Run destructive commands
- Modify database state
- Make commits
- Implement fixes
- Run builds or tests that modify state

## If You Find the Fix

If your investigation reveals an obvious fix:

```
## Suggested Fix

**Root cause**: [description, with file:line where the failure occurs]

**Execution path verified**: [confirm the code path you traced actually runs in this scenario]

**Reproducing test**:
- Setup: [preconditions]
- Action: [call]
- Expected: [correct]
- Actual: [broken]

**Fix**:
- File: `path/to/file.js:123`
- Change: [description of change needed]

**Implementation approach**: Write the reproducing test FIRST (TDD red), then apply the fix
to make it pass (green). This ensures the fix actually addresses the reported bug.

Would you like me to switch to implementation mode to apply this fix?
```

**Do NOT apply the fix yourself.** Present it and let the user decide.

When switching to implementation mode, the reproducing test from this report becomes the
first thing written — ensuring the fix is validated against the actual bug, not just a hypothesis.

## Output

A debug report with evidence, analysis, and recommended next steps.
No files modified. Investigation only.
