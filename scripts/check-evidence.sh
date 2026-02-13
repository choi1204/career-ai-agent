#!/bin/bash
# 추출된 수치가 src/evidence/ 에 대응하는 출처가 있는지 확인
# 사용: ./scripts/check-evidence.sh <대상파일> [evidence디렉토리]
set -euo pipefail

TARGET_FILE="${1:-}"
EVIDENCE_DIR="${2:-src/evidence}"

if [ -z "$TARGET_FILE" ]; then
  echo "Usage: ./scripts/check-evidence.sh <target-file> [evidence-dir]"
  echo "Example: ./scripts/check-evidence.sh outcome/1_draft/draft_v1_20260213.md"
  exit 1
fi

if [ ! -f "$TARGET_FILE" ]; then
  echo "Error: 파일을 찾을 수 없습니다: $TARGET_FILE"
  exit 1
fi

echo "=== 증거 대조 결과 ==="
echo "대상: $TARGET_FILE"
echo ""

# evidence 디렉토리 존재 확인
if [ ! -d "$EVIDENCE_DIR" ]; then
  echo "Warning: evidence 디렉토리가 없습니다: $EVIDENCE_DIR"
  exit 1
fi

# evidence 디렉토리 파일 목록
EVIDENCE_FILES=$(find "$EVIDENCE_DIR" -type f \
  -not -name '_guide.md' \
  -not -name '.gitkeep' \
  -not -name '*.md~' \
  2>/dev/null || true)

if [ -z "$EVIDENCE_FILES" ]; then
  echo "Warning: src/evidence/ 에 등록된 증거 자료가 없습니다."
  echo "    증거 자료를 추가하면 팩트체크 품질이 올라갑니다."
  echo "    가이드: src/evidence/_guide.md"
  echo ""
  echo "=== 대조 완료 ==="
  exit 0
fi

echo "등록된 증거 파일:"
echo "$EVIDENCE_FILES" | while read -r f; do
  echo "  - $f"
done
echo ""

# 검증 태그 카운트
VERIFIED_COUNT=$(grep -coE '\[evidence:' "$TARGET_FILE" 2>/dev/null || echo "0")
UNVERIFIED_COUNT=$(grep -coE '\[UNVERIFIED' "$TARGET_FILE" 2>/dev/null || echo "0")
SELF_REPORTED_COUNT=$(grep -coE '\[SELF_REPORTED' "$TARGET_FILE" 2>/dev/null || echo "0")
CONFLICT_COUNT=$(grep -coE '\[CONFLICT' "$TARGET_FILE" 2>/dev/null || echo "0")
EXAGGERATED_COUNT=$(grep -coE '\[EXAGGERATED' "$TARGET_FILE" 2>/dev/null || echo "0")

TOTAL=$((VERIFIED_COUNT + UNVERIFIED_COUNT + SELF_REPORTED_COUNT + CONFLICT_COUNT + EXAGGERATED_COUNT))

echo "검증 현황:"
echo "  ✅ VERIFIED:      $VERIFIED_COUNT"
echo "  📝 SELF_REPORTED: $SELF_REPORTED_COUNT"
echo "  ⚠️  UNVERIFIED:    $UNVERIFIED_COUNT"
echo "  ❌ CONFLICT:      $CONFLICT_COUNT"
echo "  🔍 EXAGGERATED:   $EXAGGERATED_COUNT"

if [ "$TOTAL" -gt 0 ]; then
  SAFE=$((VERIFIED_COUNT + SELF_REPORTED_COUNT))
  RATE=$((SAFE * 100 / TOTAL))
  echo "  ─────────────────"
  echo "  📊 안전 사용 가능률: ${RATE}% ($SAFE/$TOTAL)"
fi

# UNVERIFIED 항목 상세 출력
if [ "$UNVERIFIED_COUNT" -gt 0 ]; then
  echo ""
  echo "⚠️  UNVERIFIED 항목 (출처 필요):"
  grep -n '\[UNVERIFIED' "$TARGET_FILE" 2>/dev/null | while read -r line; do
    echo "  $line"
  done
fi

# CONFLICT 항목 상세 출력
if [ "$CONFLICT_COUNT" -gt 0 ]; then
  echo ""
  echo "❌ CONFLICT 항목 (수정 필요):"
  grep -n '\[CONFLICT' "$TARGET_FILE" 2>/dev/null | while read -r line; do
    echo "  $line"
  done
fi

echo ""
echo "=== 대조 완료 ==="
