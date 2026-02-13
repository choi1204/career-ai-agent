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
# outcome/4_refine/ 에 최종본이 커밋될 때 검증 태그 확인

STAGED_FINALS=$(git diff --cached --name-only | grep "outcome/4_refine/final_" || true)

if [ -n "$STAGED_FINALS" ]; then
  echo "🔍 최종 이력서 검증 중..."

  HOOK_FAILED=0
  for FILE in $STAGED_FINALS; do
    if [ -f "$FILE" ]; then
      ./scripts/validate-resume.sh "$FILE"
      if [ $? -ne 0 ]; then
        HOOK_FAILED=1
      fi
    fi
  done

  if [ "$HOOK_FAILED" -ne 0 ]; then
    echo ""
    echo "❌ 검증 미통과 이력서가 포함되어 있습니다."
    echo "   [UNVERIFIED] / [CONFLICT] / [EXAGGERATED] 태그를 해결하세요."
    echo "   강제 커밋: git commit --no-verify"
    exit 1
  fi
fi

exit 0
HOOKEOF

chmod +x "$HOOK_FILE"
echo "✅ pre-commit hook 설치 완료: $HOOK_FILE"
