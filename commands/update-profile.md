# /update-profile

## 목적
outcome/에 축적된 작업 결과를 기반으로 src/user-profile.md를 개선합니다.

## 에이전트 역할
config/agent-roles.md → Career Advisor

## 입력
- src/user-profile.md (현재 버전)
- outcome/ 전체
- src/projects/

## 실행 절차
1. 현재 user-profile.md 분석
2. outcome/에서 개선 포인트 수집:
   - 이력서 작업 중 보완된 표현
   - 면접 시뮬레이션에서 정리된 기술 깊이
   - 새로 등록된 프로젝트
3. 변경 사항 diff 형태로 제안
4. 사용자 승인 후 반영
5. 백업 자동 생성

## 출력
- src/user-profile.md 업데이트
- src/user-profile_backup_{YYYYMMDD_HHmmss}.md (백업)
- 변경 사항 요약 콘솔 출력

## 규칙
- 기존 내용 임의 삭제 금지 (추가/수정만)
- 변경 전 반드시 사용자 확인 (diff 보여주고 승인)
- 백업 자동 생성 필수
