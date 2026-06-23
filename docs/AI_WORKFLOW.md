# AI Workflow

## Target Flow

Discord command → VPS Hermes edits Godot files → Hermes pushes to GitHub → local PC pulls → Godot Editor test.

## Request Pattern

```text
프로젝트: /opt/data/projects/my-godot
작업: <작은 기능 또는 버그 수정>
조건:
- <제약>
- 수정 후 main에 push
완료 후 로컬 테스트 방법 알려줘
```

## Definition of Done

- Change is committed and pushed.
- `python3 tools/validate_project.py` passes on VPS.
- `git diff --check` passes before commit.
- User can `git pull` and test in Godot locally.
