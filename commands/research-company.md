# /research-company

## 목적
관심 기업에 대한 체계적인 리서치를 수행합니다.

## 에이전트 역할
config/agent-roles.md → Market Analyst

## 입력
- 사용자가 지정한 기업명
- templates/company-research-template.md

## 실행 절차
1. 기업 기본 정보 (규모, 업종, 주요 서비스)
2. 기술 스택 및 엔지니어링 문화 (기술 블로그 참고)
3. 최근 채용 트렌드 (어떤 포지션을 주로 뽑는지)
4. 면접 프로세스 (공개 정보 기반)
5. 연봉 범위 (공개 데이터, 커뮤니티 정보)
6. 장단점 분석

## 출력
- outcome/analysis/company_{name}_v{N}_{YYYYMMDD_HHmmss}.md

## 규칙
- 검증 가능한 출처만 사용 (기술 블로그, 공식 채용 페이지 등)
- 추측성 정보는 [미확인] 태그
- 기업 비하/비방 금지

## 제안 트리거
- 기업 기술 블로그에 흥미로운 기술 도전이 있으면:
  → "이 기업은 {기술}을 중요하게 여깁니다. /mock-interview 로 연습하세요"
