# Technical Design

## Engine
- Godot 4.x
- GDScript-first

## Project Structure
- `scenes/`: Godot scenes
- `scripts/`: GDScript files
- `assets/`: art/audio/fonts/raw source assets
- `docs/`: design and workflow notes
- `tools/`: validation and helper scripts

## Validation
Run on VPS before pushing:

```bash
python3 tools/validate_project.py
git diff --check
```

Runtime validation happens on the user's local Godot Editor.
