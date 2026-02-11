# Attach to: AnimatableBody2D (root of moving_platform.tscn)
# A blue platform that oscillates horizontally.
class_name MovingPlatform
extends AnimatableBody2D

const PLATFORM_WIDTH: float = 60.0
const PLATFORM_HEIGHT: float = 12.0

## How far the platform moves from its starting position.
@export var move_range: float = 100.0
## Horizontal movement speed in pixels per second.
@export var move_speed: float = 80.0

var _start_x: float = 0.0
var _time: float = 0.0

func _ready() -> void:
	_start_x = position.x
	_time = randf() * TAU  # random phase offset so they don't all sync

func _physics_process(delta: float) -> void:
	_time += delta * (move_speed / move_range)
	position.x = _start_x + sin(_time) * move_range

func _draw() -> void:
	var rect := Rect2(-PLATFORM_WIDTH / 2.0, -PLATFORM_HEIGHT / 2.0, PLATFORM_WIDTH, PLATFORM_HEIGHT)
	draw_rect(rect, Color(0.2, 0.5, 0.9))
	# Subtle top highlight
	draw_rect(Rect2(-PLATFORM_WIDTH / 2.0, -PLATFORM_HEIGHT / 2.0, PLATFORM_WIDTH, 3), Color(0.35, 0.65, 1.0))
