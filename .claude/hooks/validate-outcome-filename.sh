#!/bin/bash
# PostToolUse Hook: outcome/ 파일명 규칙 검증
# 규칙: {type}_v{N}_{YYYYMMDD_HHmmss}.md
set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# outcome/ 디렉토리 파일만 검사
if ! echo "$FILE_PATH" | grep -q "/outcome/"; then
  exit 0
fi

FILENAME=$(basename "$FILE_PATH")

# .gitkeep, README 등은 무시
if echo "$FILENAME" | grep -qE '^\.|^README'; then
  exit 0
fi

# 파일명 규칙: {type}_v{N}_{YYYYMMDD_HHmmss}.md
if ! echo "$FILENAME" | grep -qE '^[a-z_]+_v[0-9]+_[0-9]{8}_[0-9]{6}\.md$'; then
  jq -n --arg reason "파일명 규칙 위반: $FILENAME
규칙: {type}_v{N}_{YYYYMMDD_HHmmss}.md
예시: draft_v1_20260213_143022.md
파일명을 규칙에 맞게 수정하세요." '{
    "hookSpecificOutput": {
      "hookEventName": "PostToolUse",
      "additionalContext": $reason
    }
  }'
fi

exit 0
