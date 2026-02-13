#!/bin/bash
# PreToolUse Hook: main 브랜치 직접 push 차단
# - main/master에 직접 push 금지
# - PR을 통해서만 main에 반영
set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [ -z "$COMMAND" ]; then
  exit 0
fi

# git push 명령인지 확인
if ! echo "$COMMAND" | grep -qE 'git\s+push'; then
  exit 0
fi

# main 또는 master 브랜치로 push하는지 확인
if echo "$COMMAND" | grep -qE 'git\s+push\s+(origin\s+)?(main|master)(\s|$)'; then
  echo 'main 브랜치에 직접 push가 차단되었습니다.

워크플로우:
1. /report-issue 로 GitHub Issue 생성
2. /fix-issue {번호} 로 feature 브랜치 생성
3. 변경사항 커밋 (커밋 메시지에 #번호 포함)
4. feature 브랜치를 push 후 PR 생성
5. PR 리뷰 후 main에 머지

현재 브랜치에서 push하려면:
→ git push origin {현재브랜치명}' >&2
  exit 2
fi

exit 0
