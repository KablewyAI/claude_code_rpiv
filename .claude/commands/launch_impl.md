---
description: Create an isolated worktree and launch autonomous implementation for a plan
---

# Launch Implementation

You are setting up an isolated implementation environment for a plan and giving the user the exact command to launch it.

## Input

- Plan: `$ARGUMENTS` (path to plan file, e.g., `thoughts/shared/plans/2026-02-23_queue-permissions-fix_plan.md`)

## Process

### Step 1: Validate the plan exists

If no plan path was provided or the file doesn't exist, list available unvalidated plans:

```bash
ls -1 thoughts/shared/plans/*.md | while read plan; do
  slug=$(basename "$plan" | sed 's/^[0-9-]*_//' | sed 's/_plan\.md$//')
  validation="thoughts/shared/validations/*${slug}*"
  if ! ls $validation >/dev/null 2>&1; then
    echo "  $plan"
  fi
done
```

Then ask the user which plan to implement.

### Step 2: Derive the slug, prefix, and repos

From the plan file:

1. **Slug**: Strip date prefix and `_plan.md` suffix from filename. Shorten if over 30 chars.
   - `2026-02-23_queue-permissions-removal-concurrency-fix_plan.md` → `queue-permissions-fix`
   - `2026-02-23_error-log-reliability-fixes_plan.md` → `error-log-reliability`

2. **Prefix**: Read the plan content. Use `bugfix` if the plan's goal/title clearly describes fixing a bug, error, or regression. Use `feature` for new functionality or refactors.

3. **Repos** (MUST auto-detect): Read the FULL plan content and scan for repo references. Use these rules:

   **Scan the plan for file paths in change tables, implementation notes, and verification commands:**
   ```
   Grep the plan for: backend/, frontend/, desktop/, src/services/, src/routes/, src/views/, src/components/
   ```

   **Detection rules:**
   - Include `backend` if the plan references ANY of: `backend/`, `src/services/`, `src/routes/`, `src/mcp/`, `src/middleware/`, `src/durable-objects/`, backend test files, or `npm test` in backend context
   - Include `frontend` if the plan references ANY of: `frontend/`, `src/views/`, `src/components/`, `src/services/` in frontend context (e.g., `queue-view.js`, `streaming-controller.js`, `mcp-chat-service.js`), or frontend test files
   - Include `desktop` if the plan references ANY of: `desktop/`, Electron/Tauri files, desktop-specific paths, or Phase names mentioning "Desktop", "Electron", or "Tauri"
   - **Common frontend signals**: file paths ending in `.js` that reference views, components, or frontend services; Phase names mentioning "Frontend", "UI", or "Concurrency Limit" for client-side work
   - Default to `backend` only if NO frontend or desktop references found

   **Example**: The queue permissions plan has Phase 3 "Frontend Concurrency Limit" modifying `frontend/src/views/queue-view.js` — this means BOTH `backend` AND `frontend` repos are needed.

### Step 3: Check if worktree already exists

```bash
if [ -d ".claude/worktrees/<slug>" ]; then
  echo "Worktree already exists! Resume with:"
  echo "  cd .claude/worktrees/<slug> && claude --dangerously-skip-permissions"
fi
```

If it exists, just give the resume command and stop.

### Step 4: Verify plan is committed to main

The plan MUST be committed to main before creating the worktree (Claude Code resolves `@` paths at invocation time). Check:

```bash
git status --porcelain thoughts/shared/plans/<plan-file>
```

If the plan has uncommitted changes, commit and push it first:

```bash
git add thoughts/shared/plans/<plan-file>
git commit -m "docs: Add <slug> plan"
git push origin main
```

### Step 5: Create the worktree

Run the create script:

```bash
./scripts/create-impl-worktree.sh <slug> <prefix> <repos...>
```

### Step 6: Output the launch command

Print a clear, copy-pasteable block:

```
════════════════════════════════════════════════════════════
  Ready to launch: <slug>
════════════════════════════════════════════════════════════

  Paste this into a new terminal:

    cd <worktree-path> && claude --dangerously-skip-permissions

  Then inside that session, run:

    /ralph_impl @thoughts/shared/plans/<plan-file>

  When done, clean up:

    ./scripts/cleanup-impl-worktree.sh <slug> --delete-branches
════════════════════════════════════════════════════════════
```

## Rules

- Do NOT launch the Claude session yourself — you can't start a new interactive session from within this one
- Do NOT run ralph_impl in this session — it should run in the isolated worktree
- DO commit the plan to main if it isn't already
- DO create the worktree using the script
- DO give the user the exact commands to paste
- Keep output concise — the user just needs the commands
