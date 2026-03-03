#!/usr/bin/env bash
#
# setup-worktree-thoughts.sh
#
# Replaces thoughts/shared/ in a worktree with a symlink to the main repo's
# canonical thoughts/shared/ directory. This ensures all worktrees share a
# single set of research, plans, validations, and handoffs.
#
# Usage:
#   From inside a worktree:  ./scripts/setup-worktree-thoughts.sh
#   With explicit paths:     ./scripts/setup-worktree-thoughts.sh <worktree-dir> <main-repo-dir>
#
# The script is idempotent — safe to run multiple times.

set -euo pipefail

# Resolve the main repo root (where thoughts/shared/ lives canonically)
MAIN_REPO="${2:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
WORKTREE_DIR="${1:-$(pwd)}"

CANONICAL_THOUGHTS="$MAIN_REPO/thoughts/shared"
WORKTREE_THOUGHTS="$WORKTREE_DIR/thoughts/shared"

# Validate
if [ ! -d "$CANONICAL_THOUGHTS" ]; then
  echo "ERROR: Canonical thoughts/shared/ not found at: $CANONICAL_THOUGHTS"
  exit 1
fi

if [ "$WORKTREE_DIR" = "$MAIN_REPO" ]; then
  echo "SKIP: Already in the main repo — no symlink needed."
  exit 0
fi

# Already a symlink?
if [ -L "$WORKTREE_THOUGHTS" ]; then
  EXISTING_TARGET=$(readlink "$WORKTREE_THOUGHTS")
  if [ "$EXISTING_TARGET" = "$CANONICAL_THOUGHTS" ]; then
    echo "OK: Symlink already exists and points to the right place."
    exit 0
  else
    echo "WARN: Symlink exists but points to $EXISTING_TARGET — updating..."
    rm "$WORKTREE_THOUGHTS"
  fi
fi

# If thoughts/shared/ is a real directory in the worktree, check for unique content
if [ -d "$WORKTREE_THOUGHTS" ]; then
  # Check for files that exist in worktree but NOT in canonical dir
  UNIQUE_FILES=$(diff -rq "$WORKTREE_THOUGHTS" "$CANONICAL_THOUGHTS" 2>/dev/null | grep "^Only in $WORKTREE_THOUGHTS" || true)

  if [ -n "$UNIQUE_FILES" ]; then
    echo "WARN: Found files in worktree thoughts/ that don't exist in main repo:"
    echo "$UNIQUE_FILES"
    echo ""
    echo "Copying unique files to main repo before symlinking..."

    # Copy unique files to canonical location
    rsync -av --ignore-existing "$WORKTREE_THOUGHTS/" "$CANONICAL_THOUGHTS/"
    echo "Copied."
  fi

  # Remove the worktree's copy (we've saved unique files above)
  rm -rf "$WORKTREE_THOUGHTS"
fi

# Ensure parent directory exists
mkdir -p "$(dirname "$WORKTREE_THOUGHTS")"

# Create the symlink
ln -s "$CANONICAL_THOUGHTS" "$WORKTREE_THOUGHTS"

echo "OK: Created symlink $WORKTREE_THOUGHTS -> $CANONICAL_THOUGHTS"
echo "All worktree thoughts are now shared with the main repo."
