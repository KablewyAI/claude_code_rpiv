#!/bin/bash
# Blocks dangerous git operations: force-push, hard reset, branch -D on protected branches

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Block force push
if echo "$COMMAND" | grep -qE '\bgit\b.*\bpush\b.*(-f|--force)\b'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "BLOCKED: force push. Use --force-with-lease if you must, or ask the user to push manually."
    }
  }'
  exit 0
fi

# Block hard reset
if echo "$COMMAND" | grep -qE '\bgit\b.*\breset\b.*--hard'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "BLOCKED: git reset --hard destroys uncommitted work. Use git stash or git checkout <file> for targeted reverts."
    }
  }'
  exit 0
fi

# Block branch -D on protected branches
if echo "$COMMAND" | grep -qE '\bgit\b.*\bbranch\b.*-D\s+(main|master|staging|develop)\b'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "BLOCKED: cannot delete protected branch. Use GitHub UI for branch management."
    }
  }'
  exit 0
fi

# Block clean -f (removes untracked files permanently)
if echo "$COMMAND" | grep -qE '\bgit\b.*\bclean\b.*-f'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "BLOCKED: git clean -f permanently deletes untracked files. Review with git clean -n (dry run) first."
    }
  }'
  exit 0
fi

# Block direct push to main (enforce PR workflow)
# Customize RPIV_PUSH_MAIN_ALLOWED_DIRS to whitelist directories where push to main is OK
# Example: export RPIV_PUSH_MAIN_ALLOWED_DIRS="docs|workspace"
if echo "$COMMAND" | grep -qE '\bgit\b.*\bpush\b.*\b(origin\s+)?main\b'; then
  ALLOWED="${RPIV_PUSH_MAIN_ALLOWED_DIRS:-}"
  SHOULD_BLOCK=false

  # Check if command explicitly CDs into a sub-directory
  if echo "$COMMAND" | grep -qE 'cd\s+[a-zA-Z]'; then
    if [ -n "$ALLOWED" ]; then
      echo "$COMMAND" | grep -qE "cd\s+($ALLOWED)" || SHOULD_BLOCK=true
    else
      SHOULD_BLOCK=true
    fi
  fi

  if [ "$SHOULD_BLOCK" = true ]; then
    jq -n '{
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "deny",
        permissionDecisionReason: "BLOCKED: direct push to main. Use feature/bugfix branches and create a PR instead."
      }
    }'
    exit 0
  fi
fi

exit 0
