#!/usr/bin/env python3
from __future__ import annotations

import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


class DungeonRoomSystemTest(unittest.TestCase):
    def test_main_scene_uses_dungeon_controller_and_room_container(self) -> None:
        main_scene = ROOT / "scenes/main/main.tscn"
        text = main_scene.read_text(encoding="utf-8")
        self.assertIn("res://scripts/core/dungeon_controller.gd", text)
        self.assertIn('script = ExtResource("1_dungeon_controller")', text)
        self.assertIn('name="RoomContent"', text)
        self.assertIn('name="Player"', text)
        self.assertIn('name="RoomLabel"', text)

    def test_dungeon_controller_defines_isaac_style_room_graph(self) -> None:
        script = ROOT / "scripts/core/dungeon_controller.gd"
        self.assertTrue(script.exists(), "dungeon_controller.gd should exist")
        text = script.read_text(encoding="utf-8")
        self.assertIn("ROOM_SIZE", text)
        self.assertIn("ROOM_BOUNDS := Rect2(Vector2.ZERO, ROOM_SIZE)", text)
        self.assertIn("current_room", text)
        self.assertIn("visited_rooms", text)
        self.assertIn("_build_floor_layout", text)
        self.assertIn("_draw_current_room", text)
        self.assertIn("_try_room_transition", text)
        self.assertIn("_move_to_room", text)
        self.assertIn("Vector2i(0, 0)", text)
        for direction in ["left", "right", "up", "down"]:
            self.assertIn(f'"{direction}"', text)
        room_count = len(re.findall(r"Vector2i\(", text))
        self.assertGreaterEqual(room_count, 8, "prototype floor should define several connected rooms")

    def test_room_doors_and_boundaries_are_rendered(self) -> None:
        script = ROOT / "scripts/core/dungeon_controller.gd"
        text = script.read_text(encoding="utf-8")
        self.assertIn("DoorTop", text)
        self.assertIn("DoorBottom", text)
        self.assertIn("DoorLeft", text)
        self.assertIn("DoorRight", text)
        self.assertIn("_add_wall_segment", text)
        self.assertIn("_add_door_marker", text)
        self.assertIn("_add_room_obstacles", text)

    def test_player_has_room_bounds_export_used_by_dungeon_controller(self) -> None:
        player_script = ROOT / "scripts/actors/player/player.gd"
        text = player_script.read_text(encoding="utf-8")
        self.assertIn("room_bounds", text)
        self.assertIn("set_room_bounds", text)
        self.assertIn("global_position = global_position.clamp", text)

    def test_docs_describe_local_room_testing(self) -> None:
        roadmap = (ROOT / "docs/ROADMAP.md").read_text(encoding="utf-8")
        self.assertIn("Dungeon", roadmap)
        self.assertIn("room transition", roadmap)


if __name__ == "__main__":
    unittest.main()
