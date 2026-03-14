#!/bin/bash
# Stop hook — monitors context window usage and takes action:
#   - At 70%: injects a warning message suggesting /create_handoff
#   - At 85%: spawns a background Claude instance that writes a rich handoff
#
# Reads context usage from a state file written by the statusline script.
# The 85% threshold launches `claude -p` with --enable-auto-mode
# in the background — completely non-blocking to the main session.

INPUT=$(cat)

# Don't act if a stop hook is already active (prevents loops)
STOP_HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')
if [ "$STOP_HOOK_ACTIVE" = "true" ]; then
  exit 0
fi

# Read context usage from statusline state file
STATE_FILE="/tmp/.claude_context_usage_${USER}"
if [ ! -f "$STATE_FILE" ]; then
  exit 0
fi

STATE=$(cat "$STATE_FILE" 2>/dev/null)
USED_PCT=$(echo "$STATE" | jq -r '.used_percentage // 0')
WARNED=$(echo "$STATE" | jq -r '.warned // false')
HANDOFF_SPAWNED=$(echo "$STATE" | jq -r '.handoff_spawned // false')

# --- 85% threshold: spawn background Claude to write handoff ---
if [ "$USED_PCT" -ge 85 ] 2>/dev/null && [ "$HANDOFF_SPAWNED" != "true" ]; then
  # Mark as spawned so we don't launch multiple instances
  echo "$STATE" | jq '.handoff_spawned = true' > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"

  # Get transcript path from the hook input
  TRANSCRIPT=$(echo "$INPUT" | jq -r '.transcript_path // empty')

  if [ -n "$TRANSCRIPT" ] && [ -f "$TRANSCRIPT" ]; then
    DATE=$(date +%Y-%m-%d)
    TIME=$(date +%H-%M-%S)
    HANDOFF_DIR="$CLAUDE_PROJECT_DIR/thoughts/shared/handoffs"
    mkdir -p "$HANDOFF_DIR" 2>/dev/null
    HANDOFF_PATH="$HANDOFF_DIR/${DATE}_${TIME}_auto-context-limit_handoff.md"

    # Spawn a background Claude instance to write a rich handoff
    # --enable-auto-mode: Claude handles permission decisions autonomously with safety guardrails
    # --max-turns 10: cap the work so it doesn't run forever
    # Runs in project directory so it picks up .claude/ config
    (
      cd "$CLAUDE_PROJECT_DIR" 2>/dev/null
      claude -p "You are an automated handoff agent. Your ONLY job is to create a handoff document.

Read the session transcript at: $TRANSCRIPT

Then write a comprehensive handoff document to: $HANDOFF_PATH

The handoff must include:
1. **Tasks**: What was being worked on, status of each
2. **Critical References**: Key files that must be read to continue
3. **Recent Changes**: Files modified with file:line references
4. **Learnings**: Non-obvious insights, patterns, gotchas discovered
5. **Current State**: What's working, what's failing
6. **Next Steps**: Prioritized action items for the next session

Use this YAML frontmatter:
---
date: $(date -u +%Y-%m-%dT%H:%M:%SZ)
topic: auto-handoff-context-limit
type: auto-context-limit
status: active
branch: $(cd "$CLAUDE_PROJECT_DIR" && git branch --show-current 2>/dev/null || echo "unknown")
git_commit: $(cd "$CLAUDE_PROJECT_DIR" && git rev-parse --short HEAD 2>/dev/null || echo "unknown")
---

IMPORTANT:
- Be thorough. This handoff replaces context that will be lost to compaction.
- Focus on WHAT was being done and WHY, not just which files were touched.
- Include any decisions that were made and their rationale.
- If there are task lists or plans being followed, note the current position.
- Write the file and exit. Do not do anything else." \
        --enable-auto-mode \
        --max-turns 10 \
        > /dev/null 2>&1
    ) &

    jq -n --arg pct "$USED_PCT" --arg path "$HANDOFF_PATH" '{
      additionalContext: ("CONTEXT AT " + $pct + "% — A background agent is writing a handoff to " + $path + ". You can continue working. If you have additional context to preserve, mention it now and it will be captured in the auto-handoff or you can run /create_handoff for a manual one.")
    }'
    exit 0
  fi
fi

# --- 70% threshold: warning message ---
if [ "$USED_PCT" -ge 70 ] 2>/dev/null && [ "$WARNED" != "true" ]; then
  # Mark as warned so we don't repeat every turn
  echo "$STATE" | jq '.warned = true' > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"

  jq -n --arg pct "$USED_PCT" '{
    additionalContext: ("CONTEXT USAGE WARNING: " + $pct + "% of context window used. Compaction is approaching. Consider creating a handoff now with /create_handoff to preserve session context before it is automatically compressed. If the current task has a natural breakpoint, this is a good time to wrap up and start a fresh session.")
  }'
  exit 0
fi

exit 0
