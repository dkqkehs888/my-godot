#!/usr/bin/env python3
from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def ok(message: str) -> None:
    print(f"OK: {message}")


def fail(message: str) -> None:
    print(f"ERROR: {message}", file=sys.stderr)
    raise SystemExit(1)


def find_main_scene(path: Path) -> str:
    text = path.read_text(encoding="utf-8")
    in_application = False
    for raw_line in text.splitlines():
        line = raw_line.strip()
        if not line or line.startswith(";"):
            continue
        section = re.fullmatch(r"\[(.+)]", line)
        if section:
            in_application = section.group(1) == "application"
            continue
        if in_application and line.startswith("run/main_scene="):
            return line.split("=", 1)[1].strip()
    return ""


def godot_res_to_path(value: str) -> Path:
    cleaned = value.strip().strip('"')
    if not cleaned.startswith("res://"):
        fail(f"expected res:// path, got {value!r}")
    return ROOT / cleaned.removeprefix("res://")


def ensure_no_tracked_generated_files() -> None:
    try:
        out = subprocess.check_output(
            ["git", "ls-files"], cwd=ROOT, text=True, stderr=subprocess.DEVNULL
        )
    except Exception:
        print("WARN: git ls-files unavailable; skipping tracked generated-file check")
        return
    bad = [line for line in out.splitlines() if line.startswith((".godot/", ".import/"))]
    if bad:
        fail("generated Godot files are tracked: " + ", ".join(bad[:10]))
    ok("no generated Godot cache files tracked")


def main() -> None:
    project = ROOT / "project.godot"
    if not project.exists():
        fail("project.godot missing")
    ok("project.godot found")

    main_scene_value = find_main_scene(project)
    if not main_scene_value:
        fail("project.godot missing application run/main_scene")
    main_scene = godot_res_to_path(main_scene_value)
    if not main_scene.exists():
        fail(f"main scene does not exist: {main_scene.relative_to(ROOT)}")
    ok(f"main scene exists: {main_scene.relative_to(ROOT)}")

    for folder in ["scenes", "scripts", "docs", "tools"]:
        if not (ROOT / folder).exists():
            fail(f"required folder missing: {folder}")
        ok(f"folder exists: {folder}")

    for script in (ROOT / "scripts").rglob("*.gd"):
        if script.stat().st_size == 0:
            fail(f"empty GDScript file: {script.relative_to(ROOT)}")
    ok("GDScript files are non-empty")

    ensure_no_tracked_generated_files()
    ok("validation complete")


if __name__ == "__main__":
    main()
