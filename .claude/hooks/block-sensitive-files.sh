#!/bin/bash
# Prevents edits/writes to sensitive files (secrets, credentials, env files)

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

BASENAME=$(basename "$FILE_PATH")

# Block .env files (any variant) and .dev.vars (Wrangler local secrets)
if [[ "$BASENAME" == .env* ]] || [[ "$BASENAME" == ".dev.vars" ]]; then
  jq -n "{
    hookSpecificOutput: {
      hookEventName: \"PreToolUse\",
      permissionDecision: \"deny\",
      permissionDecisionReason: \"BLOCKED: $BASENAME is a secrets file. Use wrangler secrets or environment variables instead.\"
    }
  }"
  exit 0
fi

# Block known sensitive file patterns
case "$BASENAME" in
  secrets.json|credentials.json|*.pem|*.key|*.p8|*.p12|*.pfx|private_key*)
    jq -n "{
      hookSpecificOutput: {
        hookEventName: \"PreToolUse\",
        permissionDecision: \"deny\",
        permissionDecisionReason: \"BLOCKED: $BASENAME looks like a secrets/credentials file. These should never be edited by Claude.\"
      }
    }"
    exit 0
    ;;
esac

# Block paths containing credential directories
if [[ "$FILE_PATH" == *"/credentials/"* ]] || [[ "$FILE_PATH" == *"/.wrangler/"* ]]; then
  jq -n "{
    hookSpecificOutput: {
      hookEventName: \"PreToolUse\",
      permissionDecision: \"deny\",
      permissionDecisionReason: \"BLOCKED: $FILE_PATH is in a sensitive directory.\"
    }
  }"
  exit 0
fi

exit 0
