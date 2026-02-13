#!/bin/bash
# PreToolUse Hook: user-profile.md 수정 전 자동 백업
# - src/user-profile.md를 수정하기 전에 타임스탬프 백업 생성
set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# user-profile.md 수정인지 확인
if ! echo "$FILE_PATH" | grep -q "src/user-profile.md"; then
  exit 0
fi

PROJECT_DIR=$(echo "$INPUT" | jq -r '.cwd // empty')
PROFILE="$PROJECT_DIR/src/user-profile.md"

if [ -f "$PROFILE" ]; then
  TIMESTAMP=$(date +%Y%m%d_%H%M%S)
  BACKUP_DIR="$PROJECT_DIR/src/.profile-backups"
  mkdir -p "$BACKUP_DIR"
  cp "$PROFILE" "$BACKUP_DIR/user-profile_${TIMESTAMP}.md"

  jq -n --arg msg "user-profile.md 백업 생성: src/.profile-backups/user-profile_${TIMESTAMP}.md" '{
    "hookSpecificOutput": {
      "hookEventName": "PreToolUse",
      "additionalContext": $msg
    }
  }'
fi

exit 0
