#!/bin/bash
# git pre-commit hook 설치
# 사용: ./scripts/setup-hooks.sh
set -euo pipefail

HOOK_DIR=".git/hooks"
HOOK_FILE="$HOOK_DIR/pre-commit"

if [ ! -d ".git" ]; then
  echo "Error: git 저장소가 아닙니다. 먼저 git init을 실행하세요."
  exit 1
fi

if [ ! -d "$HOOK_DIR" ]; then
  mkdir -p "$HOOK_DIR"
fi

cat > "$HOOK_FILE" << 'HOOKEOF'
#!/bin/bash
# Career AI Agent - Pre-commit Hook
# 1) outcome/4_refine/ 최종본 → 검증 태그 확인
# 2) outcome/4_final/ 최종본 → 검증 태그 + evidence 참조 확인
# 3) outcome/learning/coding-test-log.md → 로그 형식 확인

HOOK_FAILED=0

# --- 이력서 검증 태그 확인 ---
STAGED_FINALS=$(git diff --cached --name-only | grep -E "outcome/(4_refine|4_final)/" || true)

if [ -n "$STAGED_FINALS" ]; then
  echo "🔍 최종 이력서 검증 중..."

  for FILE in $STAGED_FINALS; do
    if [ -f "$FILE" ]; then
      ./scripts/validate-resume.sh "$FILE"
      if [ $? -ne 0 ]; then
        HOOK_FAILED=1
      fi

      ./scripts/validate-evidence-refs.sh "$FILE"
      if [ $? -ne 0 ]; then
        HOOK_FAILED=1
      fi
    fi
  done
fi

# --- 코딩테스트 로그 형식 확인 ---
STAGED_LOG=$(git diff --cached --name-only | grep "outcome/learning/coding-test-log.md" || true)

if [ -n "$STAGED_LOG" ]; then
  echo "📋 코딩테스트 로그 검증 중..."
  ./scripts/validate-coding-log.sh
  if [ $? -ne 0 ]; then
    HOOK_FAILED=1
  fi
fi

# --- 결과 ---
if [ "$HOOK_FAILED" -ne 0 ]; then
  echo ""
  echo "❌ 검증 미통과 파일이 포함되어 있습니다."
  echo "   강제 커밋: git commit --no-verify"
  exit 1
fi

exit 0
HOOKEOF

chmod +x "$HOOK_FILE"
echo "✅ pre-commit hook 설치 완료: $HOOK_FILE"
