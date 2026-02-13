# /batch-analyze-jd

## 목적
`src/jd/`의 모든 JD 파일을 **동시 분석**하여 비교 매트릭스와 우선순위 랭킹을 생성합니다.
개별 `/analyze-jd`를 반복하는 대신 한 번에 모든 JD를 병렬 처리합니다.

## 서브에이전트
**career-market-analyst** (`.claude/agents/career-market-analyst.md`)
- 모델: sonnet (데이터 수집, 속도 우선)
- 도구: Read, Grep, Glob, WebSearch, WebFetch, Write
- JD 개수만큼 **병렬 실행**

## 입력
- src/jd/*.md (모든 JD 파일)
- src/user-profile.md (매칭 기준)
- src/projects/*.md (역량 데이터)

## 실행 절차

### Step 1: JD 파일 목록 확인
`src/jd/`에 있는 모든 `.md` 파일 (템플릿 제외)을 식별합니다.

### Step 2: 병렬 분석 실행
각 JD 파일마다 career-market-analyst 서브에이전트를 **동시 호출**합니다:
```
# JD 1
Task(subagent_type="career-market-analyst", prompt="""
JD 파일: src/jd/{jd_file_1}.md
src/user-profile.md, src/projects/*.md 대조하여:
1. 필수/우대 요구사항 분리
2. 기술 스택 추출
3. 역할/책임 추출
4. 매칭 분석 (✅ 충족 / ⚠️ 부분 / ❌ 미충족)
5. 전체 매칭률 (보수적 평가)
6. 갭 분석: 단기 보완 가능 vs 장기 학습 필요
""")

# JD 2
Task(subagent_type="career-market-analyst", prompt="""...""")

# ... JD N
```

### Step 3: 비교 매트릭스 생성
메인 세션이 모든 결과를 통합합니다:

```markdown
## 비교 매트릭스
| 기업 | 포지션 | 매칭률 | 최대 갭 | 갭 해소 기간 | 추천도 |
|------|--------|--------|---------|------------|--------|
| A사  | 백엔드  | 75%    | 시스템설계 | 3개월     | ★★★★  |
| B사  | 풀스택  | 60%    | React   | 1개월      | ★★★   |
```

### Step 4: 우선순위 랭킹
매칭률, 갭 해소 난이도, 성장 기회를 종합하여 추천 순위를 매깁니다:
1. 매칭률 70%+ : 즉시 지원 가능
2. 매칭률 50~70% : 단기 보완 후 지원
3. 매칭률 50% 미만 : 장기 목표

## 출력
- outcome/analysis/batch_jd_v{N}_{YYYYMMDD_HHmmss}.md
  - 개별 JD 분석 결과
  - 비교 매트릭스
  - 우선순위 랭킹
  - 전략적 지원 순서 제안

## 규칙
- 매칭률은 보수적으로 산정 (애매하면 미충족으로)
- 갭 해소 기간은 현실적으로 추정
- 개별 JD 분석은 `templates/jd-analysis-template.md` 구조 따름

## 제안 트리거
- 매칭률 70%+ JD가 있으면:
  → "이 포지션은 바로 지원 가능합니다. /draft-resume 로 맞춤 이력서를 만들어보세요"
- 모든 JD에서 공통 갭이 있으면:
  → "모든 포지션에서 {기술}이 부족합니다. 이 기술 학습을 우선하세요"
- JD가 1개뿐이면:
  → "비교 분석을 위해 src/jd/에 더 많은 JD를 추가하면 전략적 판단이 가능합니다"
