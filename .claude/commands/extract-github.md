# /extract-github

## 목적
GitHub PR/커밋 히스토리에서 기술적 의사결정, 아키텍처 패턴, 시행착오를 추출합니다.

## 사용법
```
/extract-github {owner/repo} {username} [--from 2024-01] [--to 2025-12]
```

## 실행
1. `gh auth status` 확인 → 실패 시 안내 후 중단
2. career-github-analyzer 서브에이전트 호출 (sonnet, Bash, Write 없음)
3. 결과를 `outcome/analysis/github_{repo-name}_v{N}_{timestamp}.md`에 저장
4. 요약 + `/enrich-project`로 보강 안내

## 서브에이전트
**career-github-analyzer** — PR 추출 + 기술적 패턴 분류 + 기존 프로젝트 매핑
