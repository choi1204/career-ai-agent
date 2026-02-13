#!/bin/bash
# 최종 이력서에 [UNVERIFIED] / [CONFLICT] / [EXAGGERATED] 태그가 남아있는지 확인
# pre-commit hook으로 사용 가능
# 사용: ./scripts/validate-resume.sh [파일경로]
set -uo pipefail

# 특정 파일 또는 outcome/4_refine/ 전체 검사
if [ -n "${1:-}" ]; then
  FILES="$1"
else
  FILES=$(find outcome/4_refine -name "final_*.md" -type f 2>/dev/null || true)
fi

if [ -z "$FILES" ]; then
  echo "검사할 최종 이력서가 없습니다."
  exit 0
fi

HAS_ERROR=0

for FILE in $FILES; do
  echo "=== 검증: $FILE ==="

  FILE_ERROR=0

  # UNVERIFIED 체크
  UNVERIFIED=$(grep -n '\[UNVERIFIED' "$FILE" 2>/dev/null || true)
  if [ -n "$UNVERIFIED" ]; then
    echo "⚠️  [UNVERIFIED] 태그가 남아있습니다:"
    echo "$UNVERIFIED" | while read -r line; do
      echo "  $line"
    done
    FILE_ERROR=1
  fi

  # CONFLICT 체크
  CONFLICT=$(grep -n '\[CONFLICT' "$FILE" 2>/dev/null || true)
  if [ -n "$CONFLICT" ]; then
    echo "❌ [CONFLICT] 태그가 남아있습니다:"
    echo "$CONFLICT" | while read -r line; do
      echo "  $line"
    done
    FILE_ERROR=1
  fi

  # EXAGGERATED 체크
  EXAGGERATED=$(grep -n '\[EXAGGERATED' "$FILE" 2>/dev/null || true)
  if [ -n "$EXAGGERATED" ]; then
    echo "🔍 [EXAGGERATED] 태그가 남아있습니다:"
    echo "$EXAGGERATED" | while read -r line; do
      echo "  $line"
    done
    FILE_ERROR=1
  fi

  if [ "$FILE_ERROR" -eq 0 ]; then
    echo "✅ 검증 통과"
  else
    HAS_ERROR=1
  fi
  echo ""
done

if [ "$HAS_ERROR" -ne 0 ]; then
  echo "❌ 검증 미통과 항목이 있습니다. 수정 후 다시 시도하세요."
fi

exit $HAS_ERROR
