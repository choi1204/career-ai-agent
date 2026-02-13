# /fix-issue

## 목적
GitHub Issue를 기반으로 브랜치 생성 → 수정 → PR 생성까지 자동화합니다.
모든 시스템 개선은 이 워크플로우를 따릅니다.

## 에이전트 역할
config/agent-roles.md → Career Advisor (시스템 확장 담당)

## 입력
- GitHub Issue 번호 (필수)
- 또는 Issue URL

## 실행 절차
1. Issue 내용 읽기:
   ```bash
   gh issue view {번호}
   ```

2. 브랜치 생성:
   - 이슈 유형에 따라:
     - bug → `fix/issue-{번호}-{요약}`
     - enhancement → `enhance/issue-{번호}-{요약}`
     - feature → `feat/issue-{번호}-{요약}`
     - docs → `docs/issue-{번호}-{요약}`
   ```bash
   git checkout -b {브랜치명}
   ```

3. 수정 작업:
   - Issue의 "관련 파일"과 "제안 해결 방향" 참고
   - 수정 범위를 최소한으로 유지
   - 수정 후 관련 스크립트 테스트 실행

4. 커밋:
   - 메시지 형식: `[{타입}] {요약} (fixes #{번호})`

5. PR 생성:
   ```bash
   gh pr create --title "[{타입}] {요약}" \
     --body "Fixes #{번호}\n\n## 변경 내용\n..." \
     --label {라벨}
   ```

6. 리뷰 요청:
   - 변경 범위가 commands/ → 커맨드 구조 일관성 확인
   - 변경 범위가 scripts/ → 스크립트 실행 테스트
   - 변경 범위가 config/ → 다른 커맨드 영향 확인

## 출력
- PR URL 출력
- config/evolution-log.md 업데이트 (예정)

## 규칙
- main 브랜치에 직접 커밋 금지
- PR에 Issue 번호 반드시 연결 (`Fixes #N`)
- 수정 후 관련 스크립트가 정상 동작하는지 확인
- PR 본문에 변경 내용 + 테스트 방법 포함

## 머지 후 작업
- Issue 자동 close 확인
- config/evolution-log.md에 버전 기록 추가
- 관련된 CLAUDE.md/README.md 업데이트 (필요시)

## 제안 트리거
- 수정 범위가 커서 여러 커밋이 필요하면:
  → "이 수정은 범위가 넓습니다. 여러 이슈로 나누는 것을 권장합니다"
- 수정이 다른 커맨드에 영향을 주면:
  → "이 변경은 {커맨드}에도 영향을 줍니다. 함께 수정할까요?"
