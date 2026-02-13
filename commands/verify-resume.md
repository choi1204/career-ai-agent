# /verify-resume

## 목적
이력서 초안의 모든 주장/수치를 원본 데이터와 대조하여 환각을 제거합니다.

## 에이전트 역할
config/agent-roles.md → Fact Checker

## 입력
- outcome/1_draft/ 의 최신 파일 (또는 사용자 지정)
- src/user-profile.md
- src/projects/*.md
- src/evidence/

## 실행 절차
1. `scripts/extract-metrics.sh` 실행 → 초안에서 모든 수치/주장 추출
2. 추출된 각 항목을 소스와 대조:
   - src/evidence/ 파일과 대조 → ✅ VERIFIED
   - src/projects/*.md 에만 있음 → 📝 SELF_REPORTED
   - 어디에도 없음 → ⚠️ UNVERIFIED
   - 소스와 수치 불일치 → ❌ CONFLICT
   - 소스 대비 20% 이상 차이 → 🔍 EXAGGERATED
3. `scripts/check-evidence.sh` 실행 → 프로그래매틱 대조 결과 첨부
4. 검증 결과 리포트 생성

## 출력
- outcome/2_verify/verify_v{N}_{YYYYMMDD_HHmmss}.md
  - 원문 + 각 문장별 검증 태그
  - 수정 제안 (CONFLICT/EXAGGERATED 항목)
  - 출처 요청 목록 (UNVERIFIED 항목)

## 검증 훅
- `scripts/check-evidence.sh` 자동 실행
- 결과를 산출물에 "자동 검증 결과" 섹션으로 첨부

## 규칙
- CONFLICT 항목은 원본 수치와 초안 수치를 나란히 표시
- UNVERIFIED 항목은 삭제하지 않고 태그만 부착 + 사용자에게 출처 요청
- 사용자에게 "이 수치의 출처를 제공해주세요" 형태로 구체적 질문

## 제안 트리거
- UNVERIFIED 비율이 30% 이상이면:
  → "증거 자료가 부족합니다. src/evidence/ 가이드를 참고해서 추가해주세요"
- 특정 프로젝트의 수치가 전부 UNVERIFIED이면:
  → "/intake-project 로 해당 프로젝트를 다시 정리하면 검증률이 올라갑니다"
