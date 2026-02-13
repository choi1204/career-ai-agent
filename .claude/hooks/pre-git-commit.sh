#!/bin/bash
# PreToolUse Hook: git commit 시 이슈 번호 참조 강제
# - 커밋 메시지에 #N (이슈 번호) 또는 "fixes #N" 포함 필수
# - 예외: initial commit, merge commit
set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [ -z "$COMMAND" ]; then
  exit 0
fi

# git commit 명령인지 확인
if ! echo "$COMMAND" | grep -qE 'git\s+commit'; then
  exit 0
fi

# merge commit은 예외
if echo "$COMMAND" | grep -q '\-\-no-edit'; then
  exit 0
fi

# --amend는 예외
if echo "$COMMAND" | grep -q '\-\-amend'; then
  exit 0
fi

# 커밋 메시지에서 이슈 번호 확인 (#N 패턴)
if echo "$COMMAND" | grep -qE '#[0-9]+'; then
  exit 0
fi

# 이슈 번호가 없으면 차단
echo '커밋 메시지에 GitHub Issue 번호가 없습니다.

워크플로우:
1. /report-issue 로 GitHub Issue 생성
2. /fix-issue {번호} 로 브랜치 생성
3. 커밋 메시지에 #번호 포함 (예: "[feat] 기능 추가 (#3)")

현재 main 브랜치에서 직접 커밋하려는 경우:
→ 먼저 Issue를 생성하고 브랜치를 만드세요.' >&2
exit 2
