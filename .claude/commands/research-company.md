# /research-company

## 목적
관심 기업에 대한 체계적인 리서치를 수행합니다.
**WebSearch/WebFetch**로 실시간 정보를 수집합니다.

## 서브에이전트
**career-market-analyst** (`.claude/agents/career-market-analyst.md`)
- 모델: sonnet (데이터 수집, 속도 우선)
- 도구: Read, Grep, Glob, **WebSearch, WebFetch**, Write
- WebSearch/WebFetch로 실시간 기업 정보 수집 가능

## 입력
- 사용자가 지정한 기업명
- templates/company-research-template.md

## 실행 절차

### Step 1: career-market-analyst 서브에이전트 호출
```
Task(subagent_type="career-market-analyst", prompt="""
기업명: {기업명}

templates/company-research-template.md 구조에 따라 리서치 수행:
1. WebSearch로 기업 기본 정보 수집 (규모, 업종, 주요 서비스)
2. WebSearch로 기술 스택 및 엔지니어링 문화 조사
   - "{기업명} engineering blog"
   - "{기업명} tech stack"
3. WebSearch로 채용 트렌드 조사
   - "{기업명} 채용 {포지션}"
4. WebSearch로 면접 프로세스 조사
5. WebSearch로 연봉 범위 조사 (공개 데이터)
6. 장단점 분석

모든 정보에 출처 URL 포함.
확인되지 않은 정보는 [미확인] 태그 부착.
결과를 outcome/analysis/company_{기업명}_v1_{timestamp}.md에 저장.
""")
```

### Step 2: 메인 세션이 결과 보완
- 서브에이전트 결과 검토
- 사용자에게 추가 관심사항 확인
- 제안 트리거 확인

## 출력
- outcome/analysis/company_{name}_v{N}_{YYYYMMDD_HHmmss}.md

## 규칙
- 검증 가능한 출처만 사용 (기술 블로그, 공식 채용 페이지 등)
- 추측성 정보는 [미확인] 태그
- 기업 비하/비방 금지

## 제안 트리거
- 기업 기술 블로그에 흥미로운 기술 도전이 있으면:
  → "이 기업은 {기술}을 중요하게 여깁니다. /mock-interview 로 연습하세요"
