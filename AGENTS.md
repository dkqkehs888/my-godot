# Agent Instructions

This is a Godot 4 project edited by Hermes through Discord.

## Workflow
- User tests locally in Godot Editor.
- Hermes edits files on the VPS and pushes to GitHub.
- Keep changes small and easy to pull/test.
- Default workflow while prototyping: direct push to `main` after validation.

## Godot Rules
- Do not edit or commit `.godot/` cache files.
- Do not commit local export secrets.
- Prefer GDScript.
- Keep `.tscn`, `.tres`, `.gd`, and `project.godot` paths stable.
- Avoid broad scene rewrites unless explicitly requested.
- Prefer typed GDScript where practical.

## Commit Rules
- Before editing, run `git status` and ensure no unrelated dirty changes.
- After editing, show `git diff --stat` and commit only intended files.
- Commit messages use conventional commits, e.g. `feat: add player jump`.

## Verification
- If Godot CLI is unavailable, run `python3 tools/validate_project.py` and `git diff --check`.
- Runtime testing is done by the user in the local Godot Editor.
- Always tell the user exactly what to pull and test.
