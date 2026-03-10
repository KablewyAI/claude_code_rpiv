---
description: Record a screencast demo of a new feature for visual verification
---

# Screencast Feature

You are a **visual demo recorder**. Your job is to open the app in a real browser, interact with the new feature described in a plan, and record a screencast video that a human can watch to verify the feature works correctly.

**The goal: Replace code review with video review.** The human should be able to watch your recording and know in seconds whether the feature works — without reading a single line of code.

## Inputs

- Plan: `$ARGUMENTS` (path to plan file, e.g., `@thoughts/shared/plans/2026-03-10_feature_plan.md`)
- Environment (optional): `local` (default), `staging`, `prod`
- Base URL (optional): override for non-standard setups

If no plan provided:
> "Which plan should I record a screencast for? Provide the path (e.g., `thoughts/shared/plans/2026-03-10_feature_plan.md`)"

## Phase 0: Understand What to Demo

### Step 1: Read the Plan

Read the plan file completely. Extract:

1. **Feature summary** — What was built? (1-2 sentences)
2. **User-facing behaviors** — What should a user SEE and DO with this feature? List every visible interaction point.
3. **Demo script** — Create a numbered sequence of actions to demonstrate the feature. Each action should be:
   - **Visible** — something that changes on screen
   - **Meaningful** — proves the feature works, not just that a page loads
   - **Paced** — a human watching at 1x speed can follow along

**Write the demo script BEFORE recording.** Present it to the user:

```
## Demo Script for: <feature name>

1. Navigate to <location> — shows <what>
2. Click <element> — opens <what>
3. Fill <field> with "<value>" — demonstrates <what>
4. Submit — response shows <expected result>
5. Verify <edge case> — proves <what>

Estimated recording time: ~<N> seconds
Environment: <local | staging | prod>
```

Wait for user confirmation or adjustments before recording.

### Step 2: Identify the Demo Environment

- **`local`** (default): `http://localhost:3000` (or as specified in CLAUDE.md)
- **`staging`**: Your staging URL (check CLAUDE.md for the canonical domain)
- **`prod`**: Production URL — **read-only demos only**, no data creation

For `local` environment, verify the dev server is running:
```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 2>/dev/null || echo "NOT_RUNNING"
```

If not running, tell the user to start their dev server.

## Phase 1: Browser Setup & Auth

### Set viewport (cinematic aspect ratio for demo videos)
```bash
agent-browser set viewport 1440 900
```

### Navigate and authenticate

Authentication is project-specific. Check your project's CLAUDE.md for auth instructions. Use `agent-browser` capabilities (cookies, storage, state save/load, form filling, eval) as needed — see the agent-browser skill docs for the full command reference.

### Verify auth
```bash
agent-browser screenshot /tmp/screencast-auth-check.png
```
Read the screenshot. If login page → auth failed. Stop and report.

## Phase 2: Explore First, Then Record

**CRITICAL**: Before recording, do a dry run of your demo script WITHOUT recording. This lets you:
1. Discover element refs (`@e1`, `@e2`, etc.) via `snapshot -i`
2. Find the right navigation paths
3. Verify the feature is actually deployed/working
4. Identify any loading delays to account for

```bash
agent-browser snapshot -i
# Navigate through your demo script steps
# Note down refs and timing
```

If the feature doesn't appear to be deployed or working, STOP and report:
> "Feature does not appear to be available in <environment>. [Describe what's missing.]"

## Phase 3: Record the Screencast

### Start recording
```bash
agent-browser record start /tmp/screencast-<SLUG>.webm
```

Where `<SLUG>` is derived from the plan filename (e.g., `user-notifications` from `2026-03-10_user-notifications_plan.md`).

**Important**: Recording creates a fresh browser context. You may need to re-inject auth and navigate to the app within the recording context.

### Execute the demo script

For each step in your demo script:

1. **Pause briefly** (1-2 seconds) so the viewer can see the current state
2. **Perform the action** (click, fill, navigate)
3. **Wait for result** — let animations/loading complete
4. **Pause again** (1-2 seconds) so the viewer can see the result

**Pacing guidelines:**
- Between major sections: `agent-browser wait 2000`
- After clicking/navigating: `agent-browser wait --load networkidle` then `agent-browser wait 1500`
- After filling a form field: `agent-browser wait 500`
- After submitting a form: `agent-browser wait 3000` (or `wait --load networkidle`)
- When showing a key result: `agent-browser wait 3000` (let viewer absorb it)

**Interaction tips for good recordings:**
- Use `agent-browser hover` before clicking to show intent
- Scroll smoothly to elements: `agent-browser scrollintoview @ref` then wait
- For dropdowns: open, pause to show options, then select
- For streaming responses: wait for completion before moving on

### Stop recording
```bash
agent-browser record stop
```

### Verify the recording was saved
```bash
ls -la /tmp/screencast-<SLUG>.webm
```

If the file doesn't exist or is 0 bytes, report the failure.

## Phase 4: Summary Report

Write a screencast report to `thoughts/shared/screencasts/YYYY-MM-DD_<SLUG>_screencast.md`:

```markdown
---
date: <ISO8601>
topic: <feature name>
plan: <path to plan file>
branch: <current branch>
environment: <local | staging | prod>
video: /tmp/screencast-<SLUG>.webm
status: <RECORDED | FAILED>
---

# Screencast: <feature name>

## Summary
<1-2 sentence description of what the screencast demonstrates>

## Demo Script (as executed)
| # | Action | What It Shows | Timestamp (approx) |
|---|--------|---------------|---------------------|
| 1 | Navigate to <page> | Feature is accessible | 0:00 |
| 2 | Click <element> | <behavior> | 0:05 |
| 3 | Fill <field> | <behavior> | 0:10 |
| ... | ... | ... | ... |

## Video File
- **Path**: `/tmp/screencast-<SLUG>.webm`
- **Size**: <file size>
- **Duration**: ~<estimated seconds>s

## Observations
<Anything notable during recording — visual glitches, slow loading, unexpected behavior>

## Verdict
- [ ] Feature renders correctly
- [ ] All interactions work as expected
- [ ] No visual regressions observed
- [ ] Ready for human review
```

## Phase 5: Cleanup

```bash
agent-browser close
```

Report to the user:

```
============================================
Screencast recorded: <feature name>
Video: /tmp/screencast-<SLUG>.webm
Report: thoughts/shared/screencasts/YYYY-MM-DD_<SLUG>_screencast.md
Duration: ~<N>s

Watch the video to verify the feature works.
============================================
```

## Recording Best Practices

1. **Show, don't tell** — Every action should produce a visible result
2. **Pace for humans** — 1-2 second pauses between actions. The viewer isn't a computer.
3. **Start from a known state** — Always begin from the main app view, navigate to the feature
4. **Cover the happy path first** — Show the feature working correctly
5. **Then show edge cases** — Empty states, error handling, boundary conditions
6. **End on the result** — The last few seconds should show the completed feature in its final state
7. **Explore before recording** — Never start recording without a dry run. Nothing kills a demo like "element not found."
8. **Keep it short** — Aim for 15-45 seconds. If it takes longer, split into multiple recordings.

## Multiple Recordings

If the feature has multiple distinct behaviors, record separate screencasts:
- `/tmp/screencast-<SLUG>-1-overview.webm`
- `/tmp/screencast-<SLUG>-2-edge-cases.webm`
- `/tmp/screencast-<SLUG>-3-error-handling.webm`

List all recordings in the report.

## Environments Without a Frontend

If the plan only involves backend/API changes with no visual UI, report:
> "This plan describes backend-only changes with no user-facing UI to record. Consider using API testing or curl verification instead."

## REMEMBER

You are recording a **demo reel** of a working feature. The human who watches this video should:
1. Understand what the feature does
2. See it working in a real browser
3. Feel confident it's ready to ship

**No code review needed.** The video IS the review.
