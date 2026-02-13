# /review-resume

## 목적
팩트체크 통과한 이력서를 채용 담당자 관점에서 평가하고 개선 방향을 도출합니다.

## 에이전트 역할
config/agent-roles.md → Resume Writer + Career Advisor

## 입력
- outcome/2_verify/ 의 최신 파일
- src/jd/*.md (있으면 JD 기준 평가)
- config/scoring-rubric.md

## 실행 절차
1. config/scoring-rubric.md 기준으로 항목별 평가:
   - 첫인상 (10초 스캔): 핵심 역량이 바로 보이는가?
   - 임팩트: 성과가 정량적으로 표현되어 있는가?
   - 기술 깊이: 의사결정 과정이 보이는가?
   - JD 매칭: 타깃 포지션과 관련성
   - 가독성: 구조, 분량, 용어
2. 항목별 A/B/C/D 등급 + 구체적 개선 포인트
3. 각 개선 포인트에 Before/After 예시 포함
4. JD가 있으면 요구사항별 매칭 점수표

## 출력
- outcome/3_review/review_v{N}_{YYYYMMDD_HHmmss}.md

## 규칙
- 추상적 피드백 금지 ("더 구체적으로" 같은 피드백은 불가)
- 모든 피드백에 Before → After 예시 필수
- 평가는 보수적으로 (A 등급 남발 금지)

## 제안 트리거
- 특정 프로젝트의 기술 깊이가 부족하면:
  → "/mock-interview 로 해당 프로젝트를 심층 질문하면 숨겨진 임팩트를 발굴할 수 있습니다"
- 전체적으로 C 등급 이하면:
  → "user-profile.md 의 프로젝트 설명을 보강하는 것이 우선입니다"
