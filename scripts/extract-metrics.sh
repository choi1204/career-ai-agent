#!/bin/bash
# 마크다운 파일에서 수치(%, 건, 시간, 배, 초 등)를 자동 추출
# 사용: ./scripts/extract-metrics.sh <파일경로>
set -euo pipefail

FILE="${1:-}"
if [ -z "$FILE" ]; then
  echo "Usage: ./scripts/extract-metrics.sh <filepath>"
  echo "Example: ./scripts/extract-metrics.sh outcome/1_draft/draft_v1_20260213.md"
  exit 1
fi

if [ ! -f "$FILE" ]; then
  echo "Error: 파일을 찾을 수 없습니다: $FILE"
  exit 1
fi

echo "=== 수치 추출 결과: $FILE ==="
echo ""

TOTAL=0

# 퍼센트 (%, 퍼센트)
echo "[퍼센트]"
COUNT=$(grep -coE '[0-9]+\.?[0-9]*\s*(%|퍼센트)' "$FILE" 2>/dev/null || echo "0")
grep -noE '[0-9]+\.?[0-9]*\s*(%|퍼센트)' "$FILE" 2>/dev/null || echo "  (없음)"
TOTAL=$((TOTAL + COUNT))
echo ""

# 건수 (건, 개, 명, 회, row, 행, 건수)
echo "[건수]"
COUNT=$(grep -coE '[0-9,]+\s*(건|개|명|회|row|행|건수)' "$FILE" 2>/dev/null || echo "0")
grep -noE '[0-9,]+\s*(건|개|명|회|row|행|건수)' "$FILE" 2>/dev/null || echo "  (없음)"
TOTAL=$((TOTAL + COUNT))
echo ""

# 시간 (초, 분, 시간, ms, s)
echo "[시간]"
COUNT=$(grep -coE '[0-9]+\.?[0-9]*\s*(초|분|시간|ms|s\b)' "$FILE" 2>/dev/null || echo "0")
grep -noE '[0-9]+\.?[0-9]*\s*(초|분|시간|ms|s\b)' "$FILE" 2>/dev/null || echo "  (없음)"
TOTAL=$((TOTAL + COUNT))
echo ""

# 배수 (배, x, X)
echo "[배수]"
COUNT=$(grep -coE '[0-9]+\.?[0-9]*\s*(배|[xX]\b)' "$FILE" 2>/dev/null || echo "0")
grep -noE '[0-9]+\.?[0-9]*\s*(배|[xX]\b)' "$FILE" 2>/dev/null || echo "  (없음)"
TOTAL=$((TOTAL + COUNT))
echo ""

# 금액 (원, 만원, 억, 달러, $)
echo "[금액]"
COUNT=$(grep -coE '[0-9,]+\.?[0-9]*\s*(원|만원|억|달러|\$)' "$FILE" 2>/dev/null || echo "0")
grep -noE '[0-9,]+\.?[0-9]*\s*(원|만원|억|달러|\$)' "$FILE" 2>/dev/null || echo "  (없음)"
TOTAL=$((TOTAL + COUNT))
echo ""

# 증감 지표 (WoW, MoM, YoY, QoQ)
echo "[증감 지표]"
COUNT=$(grep -coE '[+-]?[0-9]+\.?[0-9]*\s*(WoW|MoM|YoY|QoQ)' "$FILE" 2>/dev/null || echo "0")
grep -noE '[+-]?[0-9]+\.?[0-9]*\s*(WoW|MoM|YoY|QoQ)' "$FILE" 2>/dev/null || echo "  (없음)"
TOTAL=$((TOTAL + COUNT))
echo ""

# 검증 태그 현황
echo "[검증 태그 현황]"
VERIFIED=$(grep -coE '\[evidence:' "$FILE" 2>/dev/null || echo "0")
UNVERIFIED=$(grep -coE '\[UNVERIFIED' "$FILE" 2>/dev/null || echo "0")
SELF_REPORTED=$(grep -coE '\[SELF_REPORTED' "$FILE" 2>/dev/null || echo "0")
CONFLICT=$(grep -coE '\[CONFLICT' "$FILE" 2>/dev/null || echo "0")
EXAGGERATED=$(grep -coE '\[EXAGGERATED' "$FILE" 2>/dev/null || echo "0")

echo "  VERIFIED: $VERIFIED"
echo "  SELF_REPORTED: $SELF_REPORTED"
echo "  UNVERIFIED: $UNVERIFIED"
echo "  CONFLICT: $CONFLICT"
echo "  EXAGGERATED: $EXAGGERATED"
echo ""

echo "=== 총 추출 수치: ${TOTAL}개 ==="
