# Coding Guide

## GDScript
- Prefer typed variables and function signatures where practical.
- Use `snake_case.gd` for script files.
- Use descriptive node names in scenes.
- Keep changes small and path-stable.

## Godot Resources
- Avoid hand-editing large scene rewrites unless necessary.
- Do not commit `.godot/` cache files.
- Keep `project.godot` changes minimal and intentional.

## Commits
Use conventional commits:

```text
feat: add player movement
fix: correct main scene path
chore: add validation script
```
