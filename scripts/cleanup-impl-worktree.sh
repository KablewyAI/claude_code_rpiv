#!/usr/bin/env bash
#
# cleanup-impl-worktree.sh
#
# Removes an implementation worktree and its sub-repo worktrees.
# Does NOT delete the feature branches (they may have unmerged work).
#
# Usage:
#   ./scripts/cleanup-impl-worktree.sh <plan-slug> [--delete-branches]
#
# Options:
#   --delete-branches   Also delete the feature/bugfix branches (use after merge)
#
# Examples:
#   ./scripts/cleanup-impl-worktree.sh queue-permissions-fix
#   ./scripts/cleanup-impl-worktree.sh queue-permissions-fix --delete-branches

set -euo pipefail

SLUG="${1:?Usage: cleanup-impl-worktree.sh <plan-slug> [--delete-branches]}"
DELETE_BRANCHES=false
if [ "${2:-}" = "--delete-branches" ]; then
  DELETE_BRANCHES=true
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MAIN_REPO="$(cd "$SCRIPT_DIR/.." && pwd)"
WORKTREE_DIR="$MAIN_REPO/.claude/worktrees/$SLUG"

if [ ! -d "$WORKTREE_DIR" ]; then
  echo "ERROR: No worktree found at $WORKTREE_DIR"
  echo "  Available worktrees:"
  ls -1 "$MAIN_REPO/.claude/worktrees/" 2>/dev/null || echo "    (none)"
  exit 1
fi

echo "Cleaning up worktree: $SLUG"

# --- Read worktree info ---
INFO_FILE="$WORKTREE_DIR/.worktree-info"
PREFIX="feature"
REPOS=""
REPO_PREFIX=""
if [ -f "$INFO_FILE" ]; then
  PREFIX=$(grep "^prefix=" "$INFO_FILE" | cut -d= -f2 || echo "feature")
  REPOS=$(grep "^repos=" "$INFO_FILE" | cut -d= -f2 || echo "")
  REPO_PREFIX=$(grep "^repo_prefix=" "$INFO_FILE" | cut -d= -f2 || echo "")
fi

# --- Step 1: Remove sub-repo worktrees ---
for REPO_SHORT in $REPOS; do
  REPO_NAME="${REPO_PREFIX}${REPO_SHORT}"
  REPO_PATH="$MAIN_REPO/$REPO_NAME"
  WORKTREE_REPO="$WORKTREE_DIR/$REPO_NAME"
  BRANCH_NAME="$PREFIX/$SLUG"

  if [ -d "$WORKTREE_REPO" ]; then
    echo "  Removing $REPO_NAME worktree..."
    cd "$REPO_PATH"
    git worktree remove "$WORKTREE_REPO" --force 2>/dev/null || {
      echo "  Force-removing $REPO_NAME worktree..."
      rm -rf "$WORKTREE_REPO"
      git worktree prune
    }
    echo "  Removed $REPO_NAME worktree"

    if [ "$DELETE_BRANCHES" = true ]; then
      if git rev-parse --verify "$BRANCH_NAME" >/dev/null 2>&1; then
        git branch -D "$BRANCH_NAME" 2>/dev/null && echo "  Deleted branch $BRANCH_NAME" || echo "  Could not delete branch $BRANCH_NAME"
      fi
    fi
  fi
done

# --- Step 2: Remove workspace worktree ---
echo "  Removing workspace worktree..."
cd "$MAIN_REPO"
git worktree remove "$WORKTREE_DIR" --force 2>/dev/null || {
  echo "  Force-removing workspace worktree..."
  rm -rf "$WORKTREE_DIR"
  git worktree prune
}

# Clean up workspace branch
WORKSPACE_BRANCH="worktree/$SLUG"
if [ "$DELETE_BRANCHES" = true ]; then
  if git rev-parse --verify "$WORKSPACE_BRANCH" >/dev/null 2>&1; then
    git branch -D "$WORKSPACE_BRANCH" 2>/dev/null && echo "  Deleted workspace branch $WORKSPACE_BRANCH" || true
  fi
fi

echo ""
echo "Worktree '$SLUG' cleaned up"
if [ "$DELETE_BRANCHES" = false ] && [ -n "$REPOS" ]; then
  echo ""
  echo "  Branches preserved (pass --delete-branches to remove):"
  echo "    workspace: worktree/$SLUG"
  for REPO_SHORT in $REPOS; do
    echo "    ${REPO_PREFIX}${REPO_SHORT}: $PREFIX/$SLUG"
  done
fi
echo ""
