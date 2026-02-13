#!/bin/bash
# PostToolUse Hook: outcome/ 산출물에 제안 섹션 포함 여부 체크
# - 제안이 필요한 디렉토리의 파일에 "제안" 관련 키워드 없으면 리마인더
# - 차단(exit 2)이 아닌 리마인더(additionalContext)만 제공
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

# 제안이 필요한 디렉토리만 검사
# 제외: outcome/2_verify/ (중간 산출물), outcome/learning/ (누적 데이터)
NEEDS_SUGGESTION=0
if echo "$FILE_PATH" | grep -qE "outcome/(1_draft|3_review|4_refine|4_final|analysis|assessment)/"; then
  NEEDS_SUGGESTION=1
fi

if [ "$NEEDS_SUGGESTION" -eq 0 ]; then
  exit 0
fi

# .gitkeep, README 등은 무시
FILENAME=$(basename "$FILE_PATH")
if echo "$FILENAME" | grep -qE '^\.|^README'; then
  exit 0
fi

# 파일에 제안 관련 키워드가 있는지 검사
if [ -f "$FILE_PATH" ]; then
  if grep -qE '(제안|다음 단계|추천|Suggestion|Next Step)' "$FILE_PATH" 2>/dev/null; then
    exit 0
  fi
fi

# 제안 섹션이 없으면 리마인더 제공
DIRNAME=$(echo "$FILE_PATH" | grep -oP 'outcome/[^/]+')
jq -n --arg reason "이 산출물($DIRNAME)에 '제안사항' 또는 '다음 단계' 섹션이 포함되어 있지 않습니다.
해당 커맨드의 '제안 트리거' 섹션을 확인하고, 사용자에게 다음 액션을 제안해주세요.
(이 메시지는 리마인더이며, 파일 저장을 차단하지 않습니다.)" '{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": $reason
  }
}'

exit 0
