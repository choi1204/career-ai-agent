#!/bin/bash
# PostToolUse Hook: outcome/ 파일 작성 후 자동 검증
# - outcome/1_draft/ → extract-metrics.sh + check-evidence.sh
# - outcome/4_refine/ or outcome/4_final/ → validate-resume.sh + validate-evidence-refs.sh
# - outcome/learning/coding-test-log.md → validate-coding-log.sh
set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

PROJECT_DIR=$(echo "$INPUT" | jq -r '.cwd // empty')
if [ -z "$PROJECT_DIR" ]; then
  exit 0
fi

RESULTS=""
HAS_ERROR=0

# outcome/1_draft/ 에 작성된 경우 → 수치 추출 + 증거 대조
if echo "$FILE_PATH" | grep -q "outcome/1_draft/"; then
  if [ -x "$PROJECT_DIR/scripts/extract-metrics.sh" ]; then
    METRICS=$("$PROJECT_DIR/scripts/extract-metrics.sh" "$FILE_PATH" 2>&1 || true)
    RESULTS="$RESULTS\n\n## 자동 수치 추출 결과\n$METRICS"
  fi
  if [ -x "$PROJECT_DIR/scripts/check-evidence.sh" ]; then
    EVIDENCE=$("$PROJECT_DIR/scripts/check-evidence.sh" "$FILE_PATH" 2>&1 || true)
    RESULTS="$RESULTS\n\n## 자동 증거 대조 결과\n$EVIDENCE"
  fi
fi

# outcome/4_refine/ 또는 outcome/4_final/ 에 작성된 경우 → 최종 검증
if echo "$FILE_PATH" | grep -qE "outcome/(4_refine|4_final)/"; then
  if [ -x "$PROJECT_DIR/scripts/validate-resume.sh" ]; then
    VALIDATE=$("$PROJECT_DIR/scripts/validate-resume.sh" "$FILE_PATH" 2>&1 || true)
    if [ $? -ne 0 ]; then
      HAS_ERROR=1
    fi
    RESULTS="$RESULTS\n\n## 이력서 검증 결과\n$VALIDATE"
  fi
  if [ -x "$PROJECT_DIR/scripts/validate-evidence-refs.sh" ]; then
    REFS=$("$PROJECT_DIR/scripts/validate-evidence-refs.sh" "$FILE_PATH" 2>&1 || true)
    RESULTS="$RESULTS\n\n## evidence 참조 검증\n$REFS"
  fi
fi

# coding-test-log.md 작성 시 → 로그 형식 검증
if echo "$FILE_PATH" | grep -q "coding-test-log.md"; then
  if [ -x "$PROJECT_DIR/scripts/validate-coding-log.sh" ]; then
    LOG_CHECK=$(cd "$PROJECT_DIR" && ./scripts/validate-coding-log.sh 2>&1 || true)
    RESULTS="$RESULTS\n\n## 코딩테스트 로그 검증\n$LOG_CHECK"
  fi
fi

# 결과가 있으면 AI에게 피드백
if [ -n "$RESULTS" ]; then
  jq -n --arg ctx "$(echo -e "$RESULTS")" '{
    "hookSpecificOutput": {
      "hookEventName": "PostToolUse",
      "additionalContext": $ctx
    }
  }'
fi

exit 0
