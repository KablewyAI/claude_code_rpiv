---
description: Push branches, create PRs, and wrap up a worktree implementation
---

# Finish Implementation

You are wrapping up a worktree implementation session: pushing branches, creating PRs, and preparing for merge.

## Pre-Flight: Detect Context

### Step 1: Read `.worktree-info`

```bash
cat .worktree-info 2>/dev/null
```

If missing, you're probably NOT in a worktree. Stop and tell the user:
> "This command should be run from inside a worktree (e.g., `.claude/worktrees/<slug>/`). Use `/launch_impl` to create one."

Parse the fields: `slug`, `prefix`, `repos`, `main_repo`, `created`.

### Step 2: Find the plan and validation report

Find the plan file matching the slug:

```bash
ls thoughts/shared/plans/*${SLUG}*plan.md 2>/dev/null
```

Find validation reports:

```bash
ls thoughts/shared/validations/*${SLUG}* 2>/dev/null
```

**Validation gate:**
- If a validation report exists with `status: FAIL` → **STOP**. Tell the user to fix blocking issues and re-run `/validate_plan` first.
- If a validation report exists with `status: PASS` or `status: PASS WITH NOTES` → proceed.
- If NO validation report exists → **WARN** the user ("No validation report found — consider running `/validate_plan` first") but allow them to proceed if they confirm.

### Step 3: Verify each sub-repo is clean and on the right branch

For each repo listed in `.worktree-info`:

```bash
cd <worktree-dir>/<project>-<repo>
git status --porcelain
git branch --show-current
```

**Checks:**
- Working tree must be clean (no uncommitted changes). If dirty → STOP and tell the user to commit first.
- Branch must match expected pattern: `<prefix>/<slug>` (e.g., `bugfix/queue-permissions-fix`).
- Must have at least one commit ahead of `main`. Check with:
  ```bash
  git log main..<branch> --oneline
  ```
  If no commits → WARN ("No commits on branch — nothing to PR").

## Execution

### Step 4: Gather commit info per repo

For each sub-repo with commits:

```bash
cd <worktree-dir>/<project>-<repo>
BRANCH=$(git branch --show-current)

# Commit log
git log main..$BRANCH --oneline

# Full diff summary
git diff main..$BRANCH --stat
```

Store this info — you'll need it for the PR body.

### Step 5: Push branches

For each sub-repo with commits:

```bash
cd <worktree-dir>/<project>-<repo>
git push --no-verify -u origin $BRANCH
```

Use `--no-verify` because validation is our source of truth (pre-push hooks like `tsc --noEmit` may fail in worktree environments missing config files).

If push fails, report the error and stop. Common issues:
- No remote configured → check `git remote -v`
- Auth failure → user needs to fix credentials
- Branch already exists on remote → use `git push --no-verify --force-with-lease origin $BRANCH` (but WARN the user first)

### Step 6: Create or update PRs

For each sub-repo with a pushed branch, check if a PR already exists:

```bash
cd <worktree-dir>/<project>-<repo>
gh pr view $BRANCH --json url,number,state 2>/dev/null
```

#### Generate the PR body

Read the plan file and validation report. Build the PR body using this template:

```markdown
## Summary

[2-3 sentences from the plan's goal/overview section]

## Changes

[Group changes by plan phase. For each phase, list the key changes with file references from the diff.]

### Phase N: <Phase Title>
- `path/to/file.ts` — [What changed and why]
- `path/to/other.ts` — [What changed and why]

## Testing

### Automated
- [x/blank] Tests pass (`npm test`)
- [x/blank] Type check passes (`npx tsc --noEmit`)

### From Validation Report
[Copy the validation verdict and any notes. If PASS WITH NOTES, include the notes.]

## Related

- Plan: `thoughts/shared/plans/<plan-file>`
- Validation: `thoughts/shared/validations/<validation-file>`
[- Cross-repo PR: <other-repo> #<number> — if applicable, added in Step 7]
```

**PR title**: Convert the slug to title case with spaces. E.g., `queue-permissions-fix` → `Queue permissions fix`.

#### Create or update

If NO existing PR:
```bash
cd <worktree-dir>/<project>-<repo>
gh pr create --title "<title>" --body "$(cat <<'EOF'
<generated body>
EOF
)"
```

If PR already exists:
```bash
gh pr edit <number> --body "$(cat <<'EOF'
<updated body>
EOF
)"
```

Store each PR's URL and number for cross-linking.

### Step 7: Cross-link PRs (multi-repo only)

If PRs were created in multiple repos (e.g., both backend and frontend):

For each PR, edit the body to append a cross-reference in the "Related" section:

```bash
gh pr edit <number> --body "$(cat <<'EOF'
<body with added cross-link>
EOF
)"
```

Add lines like:
```
- Backend PR: <org>/<project>-backend#<number>
- Frontend PR: <org>/<project>-frontend#<number>
```

### Step 8: Commit validation report to main workspace

If a validation report exists, commit it to the main workspace repo (not the worktree):

```bash
cd <main_repo>
git add thoughts/shared/validations/*${SLUG}*
git status --porcelain thoughts/shared/validations/
```

If there are changes to commit:
```bash
git commit -m "docs: Add ${SLUG} validation report"
git push origin main
```

## Output

Print a clear summary:

```
════════════════════════════════════════════════════════════
  Implementation wrapped up: <slug>
════════════════════════════════════════════════════════════

  PRs created:
    - <project>-backend: <PR URL>
    - <project>-frontend: <PR URL>    (if applicable)

  Validation: <PASS / PASS WITH NOTES / not found>

  Next steps:
    1. Review and merge PRs on GitHub (branch protection requires human approval):
       - <PR URL>
       - <PR URL>    (if applicable)
    2. After merge, pull main in sub-repos:
       cd <main_repo>/<project>-backend && git checkout main && git pull
       cd <main_repo>/<project>-frontend && git checkout main && git pull  (if applicable)
    3. Deploy to staging (with permission):
       cd <main_repo>/<project>-backend && npx wrangler deploy -e staging
    4. Clean up worktree:
       cd <main_repo> && ./scripts/cleanup-impl-worktree.sh <slug> --delete-branches

════════════════════════════════════════════════════════════
```

## Rules

- **Idempotent** — Safe to re-run. Checks for existing PRs before creating. Checks for existing pushes before pushing.
- **Does NOT merge PRs** — Sub-repos have branch protection requiring CI + human approval. Tell the user to merge on GitHub.
- **Does NOT deploy** — That's a separate step requiring explicit user permission.
- **Does NOT delete the worktree** — User does that manually after merge.
- **Does NOT re-run tests** — Validation report is the source of truth.
- **Uses `--no-verify` on push** — Worktree environments may lack gitignored config files. Validation already confirmed quality.
- **Blocks on FAIL validation** — Don't create PRs for known-broken code.
- **Warns on missing validation** — But lets the user override.
