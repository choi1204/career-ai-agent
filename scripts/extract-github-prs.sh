#!/bin/bash
# GitHub PR 목록 추출 유틸리티 (career-github-analyzer용)
# 사용: ./scripts/extract-github-prs.sh <owner/repo> <username> [from-date] [to-date]
# 예시: ./scripts/extract-github-prs.sh 29cm/backend choi1204 2024-01-01 2025-12-31
set -euo pipefail

REPO="${1:-}"
USERNAME="${2:-}"
FROM_DATE="${3:-}"
TO_DATE="${4:-}"

if [ -z "$REPO" ] || [ -z "$USERNAME" ]; then
  echo "Usage: $0 <owner/repo> <username> [from-date] [to-date]"
  echo "Example: $0 29cm/backend choi1204 2024-01-01 2025-12-31"
  exit 1
fi

# 인증 확인
if ! gh auth status &>/dev/null; then
  echo "Error: gh CLI 인증이 필요합니다. 'gh auth login'을 실행하세요."
  exit 1
fi

# repo 접근 확인
if ! gh repo view "$REPO" --json name &>/dev/null; then
  echo "Error: $REPO 에 접근할 수 없습니다. 권한을 확인하세요."
  exit 1
fi

echo "=== GitHub PR 추출: $REPO (author: $USERNAME) ==="

# PR 목록 조회
PRS=$(gh pr list --repo "$REPO" --author "$USERNAME" --state merged \
  --limit 100 \
  --json number,title,createdAt,mergedAt,additions,deletions,changedFiles \
  2>/dev/null)

if [ -z "$PRS" ] || [ "$PRS" = "[]" ]; then
  echo "조건에 맞는 PR이 없습니다."
  exit 0
fi

# 날짜 필터링
if [ -n "$FROM_DATE" ] && [ -n "$TO_DATE" ]; then
  PRS=$(echo "$PRS" | jq --arg from "${FROM_DATE}T00:00:00Z" --arg to "${TO_DATE}T23:59:59Z" \
    '[.[] | select(.mergedAt >= $from and .mergedAt <= $to)]')
  echo "날짜 필터: $FROM_DATE ~ $TO_DATE"
fi

# 변경 규모 순 정렬 + 출력
echo ""
echo "$PRS" | jq -r 'sort_by(-(.additions + .deletions)) | .[] |
  "PR #\(.number) | \(.title) | +\(.additions)/-\(.deletions) | \(.changedFiles) files | merged: \(.mergedAt[:10])"'

TOTAL=$(echo "$PRS" | jq length)
echo ""
echo "=== 총 ${TOTAL}개 PR ==="
