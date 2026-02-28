#!/bin/bash
# Blocks `wrangler deploy` without an explicit `-e staging` flag.
# Production deploys require manual human execution outside Claude Code.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only act on wrangler deploy commands
if echo "$COMMAND" | grep -qE '(npx )?wrangler deploy'; then
  # Allow if -e staging or --env staging is present
  if echo "$COMMAND" | grep -qE -- '-e staging|--env staging'; then
    exit 0
  fi
  # Block: bare wrangler deploy = production
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "BLOCKED: bare `wrangler deploy` targets production. Use `npx wrangler deploy -e staging` instead. Production deploys must be done manually outside Claude Code."
    }
  }'
  exit 0
fi

# Not a wrangler deploy command — allow
exit 0
