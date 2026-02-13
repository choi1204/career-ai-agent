#!/bin/bash
# coding-test-log.md의 테이블 형식이 올바른지 검증
# 사용: ./scripts/validate-coding-log.sh
set -euo pipefail

LOG_FILE="outcome/learning/coding-test-log.md"

if [ ! -f "$LOG_FILE" ]; then
  echo "ℹ️  코딩테스트 로그가 없습니다: $LOG_FILE"
  exit 0
fi

echo "📋 코딩테스트 로그 검증: $LOG_FILE"
echo "================================================"

ERRORS=0

# 테이블 행 추출 (헤더/구분선 제외)
TABLE_ROWS=$(grep -E '^\|' "$LOG_FILE" | grep -vE '^\|\s*-+' | grep -vE '^\|\s*날짜' || true)

if [ -z "$TABLE_ROWS" ]; then
  echo "ℹ️  풀이 기록이 없습니다."
  exit 0
fi

TOTAL=0
while IFS= read -r row; do
  TOTAL=$((TOTAL + 1))

  # 컬럼 수 확인 (| 구분자 기준 7개 컬럼: 날짜, 유형, 난이도, 결과, 시간, 핵심패턴, 메모)
  COL_COUNT=$(echo "$row" | awk -F'|' '{print NF-1}')
  if [ "$COL_COUNT" -lt 7 ]; then
    echo "⚠️  행 $TOTAL: 컬럼 부족 ($COL_COUNT/7)"
    ERRORS=$((ERRORS + 1))
  fi

  # 날짜 형식 확인 (YYYY-MM-DD)
  DATE_FIELD=$(echo "$row" | awk -F'|' '{print $2}' | xargs)
  if ! echo "$DATE_FIELD" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'; then
    echo "⚠️  행 $TOTAL: 날짜 형식 오류 ($DATE_FIELD) — YYYY-MM-DD 필요"
    ERRORS=$((ERRORS + 1))
  fi

  # 난이도 확인 (Easy/Medium/Hard)
  DIFFICULTY=$(echo "$row" | awk -F'|' '{print $4}' | xargs)
  if ! echo "$DIFFICULTY" | grep -qiE '^(Easy|Medium|Hard)$'; then
    echo "⚠️  행 $TOTAL: 난이도 오류 ($DIFFICULTY) — Easy/Medium/Hard 필요"
    ERRORS=$((ERRORS + 1))
  fi

  # 결과 확인 (정답/부분정답/오답/시간초과)
  RESULT=$(echo "$row" | awk -F'|' '{print $5}' | xargs)
  if ! echo "$RESULT" | grep -qE '^(정답|부분정답|오답|시간초과)$'; then
    echo "⚠️  행 $TOTAL: 결과 오류 ($RESULT) — 정답/부분정답/오답/시간초과 필요"
    ERRORS=$((ERRORS + 1))
  fi
done <<< "$TABLE_ROWS"

echo ""
echo "전체 기록: $TOTAL"
echo "오류: $ERRORS"

if [ "$ERRORS" -gt 0 ]; then
  echo ""
  echo "❌ 로그 형식에 $ERRORS개 오류가 있습니다."
  exit 1
fi

echo "✅ 코딩테스트 로그 형식이 올바릅니다."
exit 0
