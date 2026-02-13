# /refine-resume

## 목적
리뷰 결과를 반영하여 최종 이력서를 생성합니다.

## 에이전트 역할
config/agent-roles.md → Resume Writer

## 입력
- outcome/3_review/ 의 최신 파일
- outcome/1_draft/ 의 모든 버전 (장점 결합용)
- src/jd/*.md

## 실행 절차
1. 리뷰 개선 사항 반영
2. 각 버전(A/B/C)에서 가장 효과적인 표현 선별
3. 최종본 조합
4. `scripts/validate-resume.sh` 실행 → [UNVERIFIED] 잔존 확인
5. UNVERIFIED 수치 → 정성적 표현으로 대체
6. 최종 이력서 생성

## 출력
- outcome/4_refine/final_v{N}_{YYYYMMDD_HHmmss}.md
  - 최종 이력서 본문
  - "남은 검증 필요 항목" 섹션 (있는 경우)
  - "user-profile.md 업데이트 제안" 섹션

## 검증 훅
- `scripts/validate-resume.sh` 자동 실행
- [UNVERIFIED] 태그가 남아있으면 경고 출력

## 규칙
- UNVERIFIED 수치는 최종본에서 수치 형태로 사용 불가
  → "거래액 54.3% 증가" → "거래액 대폭 증가 [수치 확인 필요]"
- VERIFIED + SELF_REPORTED 수치만 이력서에 그대로 사용
- 최종본 하단에 "이 이력서의 검증 상태" 요약 포함

## 제안 트리거
- 최종본 완성 후:
  → "/update-profile 로 이번 작업에서 발견된 인사이트를 프로필에 반영하세요"
- JD별 커스텀이 필요하면:
  → "다른 포지션용 이력서가 필요하면 src/jd/에 JD를 추가하고 /draft-resume를 다시 실행하세요"
