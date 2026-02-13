#!/bin/bash
# evidence 태그가 참조하는 파일이 실제 존재하는지 검증
# 사용: ./scripts/validate-evidence-refs.sh <대상 파일>
set -euo pipefail

if [ $# -eq 0 ]; then
  echo "사용법: $0 <대상 파일>"
  exit 1
fi

TARGET="$1"

if [ ! -f "$TARGET" ]; then
  echo "Error: 파일을 찾을 수 없습니다: $TARGET"
  exit 1
fi

echo "📎 evidence 참조 검증: $TARGET"
echo "================================================"

# [evidence: 경로] 패턴에서 경로 추출
REFS=$(grep -oP '\[evidence:\s*\K[^\]]+' "$TARGET" 2>/dev/null || true)

if [ -z "$REFS" ]; then
  echo "ℹ️  evidence 참조가 없습니다."
  exit 0
fi

TOTAL=0
FOUND=0
MISSING=0
MISSING_LIST=""

while IFS= read -r ref; do
  ref=$(echo "$ref" | xargs)  # trim whitespace
  TOTAL=$((TOTAL + 1))

  if [ -f "$ref" ]; then
    FOUND=$((FOUND + 1))
  else
    MISSING=$((MISSING + 1))
    MISSING_LIST="$MISSING_LIST\n  ❌ $ref"
  fi
done <<< "$REFS"

echo "전체 참조: $TOTAL"
echo "존재함: $FOUND"
echo "누락됨: $MISSING"

if [ "$MISSING" -gt 0 ]; then
  echo ""
  echo "⚠️  누락된 evidence 파일:"
  echo -e "$MISSING_LIST"
  echo ""
  echo "src/evidence/ 에 해당 파일을 추가하세요."
  exit 1
fi

echo "✅ 모든 evidence 참조가 유효합니다."
exit 0
