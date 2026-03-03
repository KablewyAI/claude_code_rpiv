#!/bin/bash
# StatusLine script — writes context window usage to a state file
# that other hooks (context-usage-reminder.sh) can read.
#
# Configure in settings.json under "statusLine" (not "hooks").
# Receives rich JSON including context_window data after each assistant message.
#
# Also displays a compact status line showing context usage.

INPUT=$(cat)

# Extract context window data
USED_PCT=$(echo "$INPUT" | jq -r '.context_window.used_percentage // 0')
REMAINING_PCT=$(echo "$INPUT" | jq -r '.context_window.remaining_percentage // 100')
TOTAL_COST=$(echo "$INPUT" | jq -r '.cost.total_cost_usd // 0')
MODEL=$(echo "$INPUT" | jq -r '.model.display_name // "Unknown"')

# Write state file for other hooks to read
STATE_FILE="/tmp/.claude_context_usage_${USER}"

# Preserve state flags across updates, but reset if usage dropped (new session)
PREV_WARNED="false"
PREV_SPAWNED="false"
PREV_PCT=0
if [ -f "$STATE_FILE" ]; then
  PREV_WARNED=$(cat "$STATE_FILE" | jq -r '.warned // false')
  PREV_SPAWNED=$(cat "$STATE_FILE" | jq -r '.handoff_spawned // false')
  PREV_PCT=$(cat "$STATE_FILE" | jq -r '.used_percentage // 0')
fi

# Reset flags if context usage dropped significantly (new session or manual compact)
if [ "$USED_PCT" -lt "$PREV_PCT" ] 2>/dev/null && [ $(( PREV_PCT - USED_PCT )) -gt 10 ] 2>/dev/null; then
  PREV_WARNED="false"
  PREV_SPAWNED="false"
fi

jq -n \
  --arg used "$USED_PCT" \
  --arg remaining "$REMAINING_PCT" \
  --arg warned "$PREV_WARNED" \
  --arg spawned "$PREV_SPAWNED" \
  '{
    used_percentage: ($used | tonumber),
    remaining_percentage: ($remaining | tonumber),
    warned: (if $warned == "true" then true else false end),
    handoff_spawned: (if $spawned == "true" then true else false end),
    updated_at: (now | todate)
  }' > "$STATE_FILE" 2>/dev/null

# Output status line
# Format: 🧠 45% | $0.12 | Opus
if [ "$USED_PCT" -ge 85 ]; then
  INDICATOR="🔴"
elif [ "$USED_PCT" -ge 70 ]; then
  INDICATOR="🟡"
else
  INDICATOR="🟢"
fi

COST_FMT=$(printf '$%.2f' "$TOTAL_COST" 2>/dev/null || echo "\$$TOTAL_COST")

echo "${INDICATOR} ${USED_PCT}% | ${COST_FMT} | ${MODEL}"
