#!/bin/bash
# PreCompact hook — auto-generates a handoff document before context compaction.
# This ensures session context is preserved even when compaction is triggered
# automatically (user didn't manually create a handoff).
#
# Reads the transcript JSONL and extracts:
#   - Recent assistant messages (what was being worked on)
#   - Recent tool calls (files touched, commands run)
#   - Task list state (if any)
#
# Writes to: thoughts/shared/handoffs/YYYY-MM-DD_auto-compact_handoff.md

INPUT=$(cat)
TRANSCRIPT=$(echo "$INPUT" | jq -r '.transcript_path // empty')
TRIGGER=$(echo "$INPUT" | jq -r '.trigger // "unknown"')

# Only auto-generate for automatic compaction
# Manual compaction means the user is in control
if [ "$TRIGGER" = "manual" ]; then
  exit 0
fi

# Need a transcript to work with
if [ -z "$TRANSCRIPT" ] || [ ! -f "$TRANSCRIPT" ]; then
  exit 0
fi

# Find the handoffs directory
HANDOFF_DIR="$CLAUDE_PROJECT_DIR/thoughts/shared/handoffs"
if [ ! -d "$HANDOFF_DIR" ]; then
  mkdir -p "$HANDOFF_DIR" 2>/dev/null || exit 0
fi

DATE=$(date +%Y-%m-%d)
TIME=$(date +%H%M%S)
HANDOFF_FILE="$HANDOFF_DIR/${DATE}_auto-compact-${TIME}_handoff.md"

# Don't overwrite if any auto-handoff was already created today
# (either by this hook or by the background Claude instance from the Stop hook)
if ls "$HANDOFF_DIR"/${DATE}_*_handoff.md 1>/dev/null 2>&1; then
  exit 0
fi

# Extract recent context from transcript (last 100 lines)
# Get recent assistant messages for "what was being worked on"
RECENT_MESSAGES=$(tail -100 "$TRANSCRIPT" | jq -r '
  select(.type == "assistant" and .message.content != null) |
  .message.content[] |
  select(.type == "text") |
  .text' 2>/dev/null | tail -2000)

# Get recent tool calls for "files touched"
RECENT_TOOLS=$(tail -200 "$TRANSCRIPT" | jq -r '
  select(.type == "assistant" and .message.content != null) |
  .message.content[] |
  select(.type == "tool_use") |
  "\(.name): \(.input | keys | join(", "))"' 2>/dev/null | sort -u | tail -30)

# Get files that were edited/written
FILES_TOUCHED=$(tail -200 "$TRANSCRIPT" | jq -r '
  select(.type == "assistant" and .message.content != null) |
  .message.content[] |
  select(.type == "tool_use" and (.name == "Edit" or .name == "Write")) |
  .input.file_path // .input.path // empty' 2>/dev/null | sort -u)

# Get recent bash commands
BASH_COMMANDS=$(tail -200 "$TRANSCRIPT" | jq -r '
  select(.type == "assistant" and .message.content != null) |
  .message.content[] |
  select(.type == "tool_use" and .name == "Bash") |
  .input.command // empty' 2>/dev/null | tail -10)

# Get current git state
GIT_BRANCH=$(cd "$CLAUDE_PROJECT_DIR" && git branch --show-current 2>/dev/null || echo "unknown")
GIT_STATUS=$(cd "$CLAUDE_PROJECT_DIR" && git status --short 2>/dev/null | head -20)

# Write the handoff
cat > "$HANDOFF_FILE" << HANDOFF
---
date: $(date -u +%Y-%m-%dT%H:%M:%SZ)
type: auto-compact
trigger: $TRIGGER
branch: $GIT_BRANCH
---

# Auto-Handoff (Pre-Compaction)

> This handoff was auto-generated before context compaction.
> It captures session state so the next session (or post-compaction context) can continue.
> Review and supplement with manual notes if resuming complex work.

## Git State

- **Branch**: \`$GIT_BRANCH\`
- **Uncommitted changes**:
\`\`\`
${GIT_STATUS:-"(clean)"}
\`\`\`

## Files Touched This Session

\`\`\`
${FILES_TOUCHED:-"(none detected)"}
\`\`\`

## Recent Tool Activity

\`\`\`
${RECENT_TOOLS:-"(none detected)"}
\`\`\`

## Recent Commands

\`\`\`
${BASH_COMMANDS:-"(none detected)"}
\`\`\`

## Last Assistant Context

> The most recent assistant messages before compaction:

${RECENT_MESSAGES:-"(could not extract)"}

## Resume Instructions

1. Read this file to understand where the session left off
2. Check git status for uncommitted work
3. Check the task list if one was active
4. Continue from the last known state
HANDOFF

# Inject a system message so Claude knows the handoff was created
jq -n --arg file "$HANDOFF_FILE" '{
  systemMessage: ("Auto-handoff created at " + $file + " before compaction. Reference this file if context about earlier work is needed.")
}'
