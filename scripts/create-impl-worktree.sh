#!/usr/bin/env bash
#
# create-impl-worktree.sh
#
# Creates an isolated implementation environment for a plan:
#   1. Workspace worktree (CLAUDE.md, commands, thoughts)
#   2. Sub-repo worktrees inside it (each gets its own branch)
#   3. Symlinks thoughts/shared/ to the canonical location
#
# Usage:
#   ./scripts/create-impl-worktree.sh <plan-slug> [prefix] [repos...]
#
# Examples:
#   ./scripts/create-impl-worktree.sh queue-permissions-fix bugfix backend
#   ./scripts/create-impl-worktree.sh error-log-reliability feature backend
#   ./scripts/create-impl-worktree.sh dark-mode feature backend frontend
#
# Arguments:
#   plan-slug   Name for the worktree (matches plan file slug)
#   prefix      Branch prefix: feature, bugfix, experiment (default: feature)
#   repos...    Sub-repo directory names to include (default: none — single-repo mode)
#
# Configuration:
#   Set RPIV_REPO_PREFIX in your environment to customize sub-repo directory names.
#   Default: "" (no prefix). Example: RPIV_REPO_PREFIX="myproject-"
#
# The resulting structure (multi-repo):
#   .claude/worktrees/<slug>/                         # workspace worktree
#   .claude/worktrees/<slug>/<prefix>backend/         # backend worktree (own branch)
#   .claude/worktrees/<slug>/<prefix>frontend/        # frontend worktree (own branch)
#   .claude/worktrees/<slug>/thoughts/shared/         # symlink → main repo
#
# Single-repo mode (no repos specified):
#   .claude/worktrees/<slug>/                         # worktree with everything

set -euo pipefail

# --- Configuration ---
REPO_PREFIX="${RPIV_REPO_PREFIX:-}"

# --- Parse arguments ---
SLUG="${1:?Usage: create-impl-worktree.sh <plan-slug> [prefix] [repos...]}"
PREFIX="${2:-feature}"
shift 2 2>/dev/null || shift $# 2>/dev/null
REPOS=("${@}")

# --- Resolve paths ---
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MAIN_REPO="$(cd "$SCRIPT_DIR/.." && pwd)"
WORKTREE_BASE="$MAIN_REPO/.claude/worktrees"
WORKTREE_DIR="$WORKTREE_BASE/$SLUG"

# --- Validate ---
if [ -d "$WORKTREE_DIR" ]; then
  echo "ERROR: Worktree already exists at $WORKTREE_DIR"
  echo "  To resume: cd $WORKTREE_DIR && claude"
  echo "  To remove: ./scripts/cleanup-impl-worktree.sh $SLUG"
  exit 1
fi

# Check that we're in the workspace repo
if [ ! -f "$MAIN_REPO/CLAUDE.md" ]; then
  echo "ERROR: Not in the workspace repo root. Expected CLAUDE.md at $MAIN_REPO"
  exit 1
fi

echo "Creating implementation worktree: $SLUG"
echo "  Branch prefix: $PREFIX"
if [ ${#REPOS[@]} -gt 0 ]; then
  echo "  Sub-repos: ${REPOS[*]}"
fi
echo ""

# --- Step 1: Create workspace worktree ---
echo "Step 1: Creating workspace worktree..."
cd "$MAIN_REPO"
git worktree add "$WORKTREE_DIR" -b "worktree/$SLUG" HEAD 2>/dev/null || {
  # Branch might already exist from a previous partial setup
  git worktree add "$WORKTREE_DIR" "worktree/$SLUG" 2>/dev/null || {
    echo "ERROR: Failed to create workspace worktree"
    exit 1
  }
}
echo "  Created workspace worktree at $WORKTREE_DIR"

# --- Step 2: Symlink thoughts/shared/ ---
echo "Step 2: Symlinking thoughts/shared/..."
CANONICAL_THOUGHTS="$MAIN_REPO/thoughts/shared"
WORKTREE_THOUGHTS="$WORKTREE_DIR/thoughts/shared"

if [ -d "$CANONICAL_THOUGHTS" ]; then
  # Remove the worktree's copy (it's a snapshot, not canonical)
  if [ -d "$WORKTREE_THOUGHTS" ] && [ ! -L "$WORKTREE_THOUGHTS" ]; then
    rm -rf "$WORKTREE_THOUGHTS"
  fi
  mkdir -p "$(dirname "$WORKTREE_THOUGHTS")"
  ln -sf "$CANONICAL_THOUGHTS" "$WORKTREE_THOUGHTS"
  echo "  thoughts/shared/ -> $CANONICAL_THOUGHTS"
else
  echo "  No thoughts/shared/ found at $CANONICAL_THOUGHTS (skipping)"
fi

# --- Step 3: Create sub-repo worktrees (if multi-repo) ---
for REPO_SHORT in "${REPOS[@]}"; do
  REPO_NAME="${REPO_PREFIX}${REPO_SHORT}"
  REPO_PATH="$MAIN_REPO/$REPO_NAME"
  BRANCH_NAME="$PREFIX/$SLUG"
  WORKTREE_REPO="$WORKTREE_DIR/$REPO_NAME"

  if [ ! -d "$REPO_PATH/.git" ]; then
    echo "  Skipping $REPO_NAME - not a git repo at $REPO_PATH"
    continue
  fi

  echo "Step 3: Creating $REPO_NAME worktree (branch: $BRANCH_NAME)..."
  cd "$REPO_PATH"

  # Check if branch already exists
  if git rev-parse --verify "$BRANCH_NAME" >/dev/null 2>&1; then
    echo "  Branch $BRANCH_NAME already exists - using it"
    git worktree add "$WORKTREE_REPO" "$BRANCH_NAME"
  else
    git worktree add "$WORKTREE_REPO" -b "$BRANCH_NAME" main
  fi
  echo "  $REPO_NAME worktree at $WORKTREE_REPO (branch: $BRANCH_NAME)"

  # Copy essential untracked config files (gitignored files won't be in worktree checkout)
  for CONFIG_FILE in tsconfig.json wrangler.toml .env.example; do
    if [ -f "$REPO_PATH/$CONFIG_FILE" ] && [ ! -f "$WORKTREE_REPO/$CONFIG_FILE" ]; then
      cp "$REPO_PATH/$CONFIG_FILE" "$WORKTREE_REPO/$CONFIG_FILE"
      echo "  Copied $CONFIG_FILE (gitignored, not in worktree checkout)"
    fi
  done

  # Install dependencies if package.json exists
  if [ -f "$WORKTREE_REPO/package.json" ]; then
    echo "  Installing dependencies for $REPO_NAME..."
    cd "$WORKTREE_REPO"
    npm install --silent 2>&1 | tail -3
    echo "  Dependencies installed for $REPO_NAME"
  fi
done

# --- Step 4: Create a .worktree-info file for tooling ---
cat > "$WORKTREE_DIR/.worktree-info" <<EOF
slug=$SLUG
prefix=$PREFIX
repos=${REPOS[*]}
repo_prefix=$REPO_PREFIX
main_repo=$MAIN_REPO
created=$(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF

# --- Done ---
echo ""
echo "================================================================"
echo "  Worktree ready: $SLUG"
echo "================================================================"
echo ""
echo "  Structure:"
echo "    $WORKTREE_DIR/"
echo "    ├── CLAUDE.md, .claude/commands/     (workspace)"
echo "    ├── thoughts/shared/                 (symlink -> main)"
for REPO_SHORT in "${REPOS[@]}"; do
  echo "    └── ${REPO_PREFIX}${REPO_SHORT}/              ($PREFIX/$SLUG branch)"
done
echo ""
echo "  To start working:"
echo "    cd $WORKTREE_DIR && claude"
echo ""
echo "  When done:"
echo "    ./scripts/cleanup-impl-worktree.sh $SLUG"
echo ""
