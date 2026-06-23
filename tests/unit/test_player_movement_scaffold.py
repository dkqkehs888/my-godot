#!/usr/bin/env python3
from __future__ import annotations

import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


class PlayerMovementScaffoldTest(unittest.TestCase):
    def test_player_script_supports_wasd_physics_movement(self) -> None:
        script = ROOT / "scripts/actors/player/player.gd"
        self.assertTrue(script.exists(), "player.gd should exist")
        text = script.read_text(encoding="utf-8")
        self.assertIn("extends CharacterBody2D", text)
        self.assertIn("_physics_process", text)
        self.assertIn("move_and_slide()", text)
        for key in ["KEY_W", "KEY_A", "KEY_S", "KEY_D"]:
            self.assertIn(key, text)
        self.assertIn("normalized()", text, "diagonal WASD movement should be normalized")

    def test_main_scene_instances_player_scene(self) -> None:
        main_scene = ROOT / "scenes/main/main.tscn"
        self.assertTrue(main_scene.exists(), "main.tscn should exist")
        text = main_scene.read_text(encoding="utf-8")
        self.assertIn("res://scenes/actors/player/player.tscn", text)
        self.assertIn('name="Player"', text)
        self.assertIn("instance=ExtResource", text)

    def test_player_scene_has_collision_and_visible_placeholder(self) -> None:
        scene = ROOT / "scenes/actors/player/player.tscn"
        self.assertTrue(scene.exists(), "player.tscn should exist")
        text = scene.read_text(encoding="utf-8")
        self.assertIn('type="CharacterBody2D"', text)
        self.assertIn('type="CollisionShape2D"', text)
        self.assertIn('type="Polygon2D"', text)
        self.assertIn("res://scripts/actors/player/player.gd", text)


if __name__ == "__main__":
    unittest.main()
