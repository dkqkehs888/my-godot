extends Node2D

const ROOM_SIZE := Vector2(1280.0, 720.0)
const ROOM_BOUNDS := Rect2(Vector2.ZERO, ROOM_SIZE)
const DOOR_MARGIN := 46.0
const DOOR_HALF_SIZE := 58.0
const PLAYER_EXIT_PADDING := 72.0

@onready var room_content: Node2D = $RoomContent
@onready var player: CharacterBody2D = $Player
@onready var room_label: Label = $RoomLabel

var current_room := Vector2i(0, 0)
var visited_rooms: Dictionary = {}
var floor_layout: Dictionary = {}

func _ready() -> void:
    _build_floor_layout()
    visited_rooms[current_room] = true
    player.set_room_bounds(ROOM_BOUNDS)
    _draw_current_room()

func _process(_delta: float) -> void:
    _try_room_transition()

func _build_floor_layout() -> void:
    floor_layout = {
        Vector2i(0, 0): {"type": "start", "doors": ["left", "right", "up"]},
        Vector2i(-1, 0): {"type": "combat", "doors": ["right", "up"]},
        Vector2i(1, 0): {"type": "combat", "doors": ["left", "right", "down"]},
        Vector2i(0, -1): {"type": "treasure", "doors": ["down", "right"]},
        Vector2i(-1, -1): {"type": "combat", "doors": ["down", "right"]},
        Vector2i(1, -1): {"type": "combat", "doors": ["left"]},
        Vector2i(2, 0): {"type": "boss", "doors": ["left"]},
        Vector2i(1, 1): {"type": "shop", "doors": ["up"]},
    }

func _draw_current_room() -> void:
    for child in room_content.get_children():
        child.queue_free()

    var room_data: Dictionary = floor_layout[current_room]
    var room_type := str(room_data.get("type", "room"))
    var doors: Array = room_data.get("doors", [])

    _add_floor(room_type)
    _add_walls(doors)
    _add_room_obstacles(room_type)
    _update_room_label(room_type, doors)

func _add_floor(room_type: String) -> void:
    var floor := Polygon2D.new()
    floor.name = "RoomFloor"
    floor.polygon = PackedVector2Array([
        Vector2.ZERO,
        Vector2(ROOM_SIZE.x, 0.0),
        ROOM_SIZE,
        Vector2(0.0, ROOM_SIZE.y),
    ])

    match room_type:
        "start":
            floor.color = Color(0.12, 0.12, 0.14, 1.0)
        "treasure":
            floor.color = Color(0.12, 0.10, 0.18, 1.0)
        "boss":
            floor.color = Color(0.18, 0.09, 0.09, 1.0)
        "shop":
            floor.color = Color(0.12, 0.15, 0.10, 1.0)
        _:
            floor.color = Color(0.11, 0.11, 0.12, 1.0)

    room_content.add_child(floor)

func _add_walls(doors: Array) -> void:
    var wall_color := Color(0.45, 0.45, 0.50, 1.0)
    _add_wall_segment("WallTopLeft", Vector2(0.0, 0.0), Vector2(ROOM_SIZE.x * 0.5 - DOOR_HALF_SIZE, 0.0), wall_color)
    _add_wall_segment("WallTopRight", Vector2(ROOM_SIZE.x * 0.5 + DOOR_HALF_SIZE, 0.0), Vector2(ROOM_SIZE.x, 0.0), wall_color)
    _add_wall_segment("WallBottomLeft", Vector2(0.0, ROOM_SIZE.y), Vector2(ROOM_SIZE.x * 0.5 - DOOR_HALF_SIZE, ROOM_SIZE.y), wall_color)
    _add_wall_segment("WallBottomRight", Vector2(ROOM_SIZE.x * 0.5 + DOOR_HALF_SIZE, ROOM_SIZE.y), ROOM_SIZE, wall_color)
    _add_wall_segment("WallLeftTop", Vector2(0.0, 0.0), Vector2(0.0, ROOM_SIZE.y * 0.5 - DOOR_HALF_SIZE), wall_color)
    _add_wall_segment("WallLeftBottom", Vector2(0.0, ROOM_SIZE.y * 0.5 + DOOR_HALF_SIZE), Vector2(0.0, ROOM_SIZE.y), wall_color)
    _add_wall_segment("WallRightTop", Vector2(ROOM_SIZE.x, 0.0), Vector2(ROOM_SIZE.x, ROOM_SIZE.y * 0.5 - DOOR_HALF_SIZE), wall_color)
    _add_wall_segment("WallRightBottom", Vector2(ROOM_SIZE.x, ROOM_SIZE.y * 0.5 + DOOR_HALF_SIZE), ROOM_SIZE, wall_color)

    if doors.has("up"):
        _add_door_marker("DoorTop", Vector2(ROOM_SIZE.x * 0.5, DOOR_MARGIN), Vector2(96.0, 24.0))
    else:
        _add_wall_segment("WallTopClosedDoor", Vector2(ROOM_SIZE.x * 0.5 - DOOR_HALF_SIZE, 0.0), Vector2(ROOM_SIZE.x * 0.5 + DOOR_HALF_SIZE, 0.0), wall_color)

    if doors.has("down"):
        _add_door_marker("DoorBottom", Vector2(ROOM_SIZE.x * 0.5, ROOM_SIZE.y - DOOR_MARGIN), Vector2(96.0, 24.0))
    else:
        _add_wall_segment("WallBottomClosedDoor", Vector2(ROOM_SIZE.x * 0.5 - DOOR_HALF_SIZE, ROOM_SIZE.y), Vector2(ROOM_SIZE.x * 0.5 + DOOR_HALF_SIZE, ROOM_SIZE.y), wall_color)

    if doors.has("left"):
        _add_door_marker("DoorLeft", Vector2(DOOR_MARGIN, ROOM_SIZE.y * 0.5), Vector2(24.0, 96.0))
    else:
        _add_wall_segment("WallLeftClosedDoor", Vector2(0.0, ROOM_SIZE.y * 0.5 - DOOR_HALF_SIZE), Vector2(0.0, ROOM_SIZE.y * 0.5 + DOOR_HALF_SIZE), wall_color)

    if doors.has("right"):
        _add_door_marker("DoorRight", Vector2(ROOM_SIZE.x - DOOR_MARGIN, ROOM_SIZE.y * 0.5), Vector2(24.0, 96.0))
    else:
        _add_wall_segment("WallRightClosedDoor", Vector2(ROOM_SIZE.x, ROOM_SIZE.y * 0.5 - DOOR_HALF_SIZE), Vector2(ROOM_SIZE.x, ROOM_SIZE.y * 0.5 + DOOR_HALF_SIZE), wall_color)

func _add_wall_segment(node_name: String, from: Vector2, to: Vector2, color: Color) -> void:
    var line := Line2D.new()
    line.name = node_name
    line.points = PackedVector2Array([from, to])
    line.width = 5.0
    line.default_color = color
    room_content.add_child(line)

func _add_door_marker(node_name: String, center: Vector2, size: Vector2) -> void:
    var door := Polygon2D.new()
    door.name = node_name
    var half := size * 0.5
    door.polygon = PackedVector2Array([
        center + Vector2(-half.x, -half.y),
        center + Vector2(half.x, -half.y),
        center + Vector2(half.x, half.y),
        center + Vector2(-half.x, half.y),
    ])
    door.color = Color(0.75, 0.62, 0.35, 1.0)
    room_content.add_child(door)

func _add_room_obstacles(room_type: String) -> void:
    if room_type == "start":
        return

    var obstacle_color := Color(0.28, 0.25, 0.22, 1.0)
    var centers: Array[Vector2] = []
    match room_type:
        "treasure":
            centers = [Vector2(420.0, 260.0), Vector2(860.0, 460.0)]
        "boss":
            centers = [Vector2(430.0, 260.0), Vector2(850.0, 260.0), Vector2(640.0, 470.0)]
        "shop":
            centers = [Vector2(500.0, 360.0), Vector2(780.0, 360.0)]
        _:
            centers = [Vector2(420.0, 360.0), Vector2(860.0, 360.0)]

    for index in range(centers.size()):
        _add_obstacle("Obstacle%d" % index, centers[index], Vector2(72.0, 72.0), obstacle_color)

func _add_obstacle(node_name: String, center: Vector2, size: Vector2, color: Color) -> void:
    var obstacle := Polygon2D.new()
    obstacle.name = node_name
    var half := size * 0.5
    obstacle.polygon = PackedVector2Array([
        center + Vector2(-half.x, -half.y),
        center + Vector2(half.x, -half.y),
        center + Vector2(half.x, half.y),
        center + Vector2(-half.x, half.y),
    ])
    obstacle.color = color
    room_content.add_child(obstacle)

func _update_room_label(room_type: String, doors: Array) -> void:
    var room_name := room_type.capitalize()
    var visited_count := visited_rooms.size()
    room_label.text = "Room %s %s | %s | doors: %s | visited: %d/%d" % [
        current_room,
        room_name,
        "WASD: move | Arrow Keys: shoot | Walk through gold doors",
        _format_doors(doors),
        visited_count,
        floor_layout.size(),
    ]

func _format_doors(doors: Array) -> String:
    var labels: Array[String] = []
    for door in doors:
        labels.append(str(door))
    return ", ".join(labels)

func _try_room_transition() -> void:
    if not floor_layout.has(current_room):
        return

    var doors: Array = floor_layout[current_room].get("doors", [])
    if player.global_position.x <= 8.0 and doors.has("left"):
        _move_to_room(Vector2i.LEFT, Vector2(ROOM_SIZE.x - PLAYER_EXIT_PADDING, ROOM_SIZE.y * 0.5))
    elif player.global_position.x >= ROOM_SIZE.x - 8.0 and doors.has("right"):
        _move_to_room(Vector2i.RIGHT, Vector2(PLAYER_EXIT_PADDING, ROOM_SIZE.y * 0.5))
    elif player.global_position.y <= 8.0 and doors.has("up"):
        _move_to_room(Vector2i.UP, Vector2(ROOM_SIZE.x * 0.5, ROOM_SIZE.y - PLAYER_EXIT_PADDING))
    elif player.global_position.y >= ROOM_SIZE.y - 8.0 and doors.has("down"):
        _move_to_room(Vector2i.DOWN, Vector2(ROOM_SIZE.x * 0.5, PLAYER_EXIT_PADDING))

func _move_to_room(offset: Vector2i, entry_position: Vector2) -> void:
    var next_room := current_room + offset
    if not floor_layout.has(next_room):
        return

    current_room = next_room
    visited_rooms[current_room] = true
    player.global_position = entry_position
    _clear_projectiles()
    _draw_current_room()

func _clear_projectiles() -> void:
    for child in get_children():
        if child.is_in_group("player_projectiles"):
            child.queue_free()
