extends Area2D

@export var speed: float = 520.0
@export var lifetime: float = 1.4

var direction: Vector2 = Vector2.RIGHT
var _age: float = 0.0

func set_direction(new_direction: Vector2) -> void:
    if new_direction == Vector2.ZERO:
        direction = Vector2.RIGHT
    else:
        direction = new_direction.normalized()
    rotation = direction.angle()

func _physics_process(delta: float) -> void:
    global_position += direction * speed * delta
    _age += delta
    if _age >= lifetime:
        queue_free()

func _ready() -> void:
    add_to_group("player_projectiles")
