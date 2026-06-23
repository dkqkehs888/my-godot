extends CharacterBody2D

const tear_scene: PackedScene = preload("res://scenes/projectiles/tear.tscn")

@export var speed: float = 220.0
@export var shoot_cooldown: float = 0.22
@export var tear_spawn_offset: float = 24.0

var _shoot_timer: float = 0.0

func _physics_process(delta: float) -> void:
    _shoot_timer = maxf(_shoot_timer - delta, 0.0)
    _move_player()
    _handle_shooting()

func _move_player() -> void:
    var direction := Vector2.ZERO

    if Input.is_key_pressed(KEY_A):
        direction.x -= 1.0
    if Input.is_key_pressed(KEY_D):
        direction.x += 1.0
    if Input.is_key_pressed(KEY_W):
        direction.y -= 1.0
    if Input.is_key_pressed(KEY_S):
        direction.y += 1.0

    if direction.length() > 0.0:
        direction = direction.normalized()

    velocity = direction * speed
    move_and_slide()

func _handle_shooting() -> void:
    if _shoot_timer > 0.0:
        return

    var shoot_direction := Vector2.ZERO
    if Input.is_key_pressed(KEY_LEFT):
        shoot_direction = Vector2.LEFT
    elif Input.is_key_pressed(KEY_RIGHT):
        shoot_direction = Vector2.RIGHT
    elif Input.is_key_pressed(KEY_UP):
        shoot_direction = Vector2.UP
    elif Input.is_key_pressed(KEY_DOWN):
        shoot_direction = Vector2.DOWN

    if shoot_direction != Vector2.ZERO:
        _shoot(shoot_direction)
        _shoot_timer = shoot_cooldown

func _shoot(direction: Vector2) -> void:
    var tear := tear_scene.instantiate()
    tear.global_position = global_position + direction * tear_spawn_offset
    tear.set_direction(direction)

    var target_parent := get_tree().current_scene
    if target_parent == null:
        target_parent = get_parent()
    target_parent.add_child(tear)
