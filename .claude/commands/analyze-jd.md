# /analyze-jd

## 목적
채용공고를 분석하고 사용자 프로필과의 매칭률을 산출합니다.

## 서브에이전트
**career-market-analyst** (`.claude/agents/career-market-analyst.md`)
- 모델: sonnet (데이터 분석, 속도 우선)
- 도구: Read, Grep, Glob, WebSearch, WebFetch, Write

## 입력
- src/jd/{file}.md (분석 대상 JD)
- src/user-profile.md
- src/projects/*.md

## 실행 절차

### Step 1: career-market-analyst 서브에이전트 호출
```
Task(subagent_type="career-market-analyst", prompt="""
채용공고를 분석하고 사용자 프로필과 매칭률을 산출합니다.

1. src/jd/{file}.md 읽기 (분석 대상 JD)
2. src/user-profile.md, src/projects/*.md 읽기

3. JD 파싱:
   - 필수 요구사항 / 우대사항 분리
   - 기술 스택 추출
   - 역할/책임 추출
   - 숨겨진 요구사항 추론

4. 매칭 분석:
   - 각 요구사항별 매칭 (✅ 충족 / ⚠️ 부분 충족 / ❌ 미충족)
   - 전체 매칭률
   - 강점 (차별화 포인트)
   - 갭 (부족한 부분 + 보완 방법 + 예상 소요 시간)

5. 맞춤 전략:
   - 이력서에서 강조할 프로젝트 순서
   - 면접 예상 질문
   - 준비해야 할 기술 주제

6. 지원 추천: ✅ 추천 / ⚠️ 조건부 / ❌ 비추천 + 이유

7. outcome/analysis/jd_{company}_{position}_v{N}_{timestamp}.md에 저장
""")
```

### Step 2: 결과 통합
- 서브에이전트 결과를 사용자에게 요약 제시
- 추가 분석이 필요하면 WebSearch로 기업/포지션 보충 정보 수집 가능

## 출력
- outcome/analysis/jd_{company}_{position}_v{N}_{YYYYMMDD_HHmmss}.md

## 규칙
- 매칭률 보수적 평가 (과대 산정 금지)
- 갭 분석에서 "단기 보완 가능" vs "장기 학습 필요" 구분
- 검증 가능한 정보만 사용 (추측은 [미확인] 태그)

## 제안 트리거
- 매칭률이 높으면:
  → "/draft-resume 로 이 JD에 맞춤화된 이력서를 만들어보세요"
- 특정 기술 갭이 있으면:
  → "/mock-interview 로 해당 기술 주제를 연습하세요"
