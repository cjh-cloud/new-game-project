# Attach to: CharacterBody2D (root of player.tscn)
# The player character that bounces off platforms and is controlled via
# accelerometer tilt (mobile) or keyboard (desktop testing).
class_name Player
extends CharacterBody2D

## Jump impulse applied when the player lands on a platform.
@export var jump_force: float = -900.0
## Horizontal movement speed (keyboard / touch fallback).
@export var move_speed: float = 400.0
## Gravity acceleration (pixels / sec^2).
@export var gravity: float = 1800.0
## Sensitivity multiplier for accelerometer tilt input.
@export var tilt_sensitivity: float = 40.0

## Emitted when the player bounces so the main scene can track the score.
signal bounced(height: float)

var screen_width: float

func _ready() -> void:
	screen_width = get_viewport_rect().size.x

func _physics_process(delta: float) -> void:
	# --- Gravity ---
	velocity.y += gravity * delta

	# --- Horizontal movement ---
	var horizontal_input: float = 0.0

	# Mobile: accelerometer tilt
	var accel := Input.get_accelerometer()
	if accel != Vector3.ZERO:
		horizontal_input = accel.x * tilt_sensitivity
	else:
		# Keyboard fallback for desktop testing
		horizontal_input = Input.get_axis("move_left", "move_right") * move_speed

	# Touch fallback: tap left/right half of screen
	if accel == Vector3.ZERO and horizontal_input == 0.0:
		horizontal_input = _get_touch_horizontal()

	velocity.x = horizontal_input

	# --- Move and check for platform collisions ---
	move_and_slide()

	# Bounce when landing on a platform (only while falling)
	if is_on_floor() and velocity.y >= 0.0:
		_bounce()

	# --- Screen wrapping ---
	if global_position.x < -20:
		global_position.x = screen_width + 20
	elif global_position.x > screen_width + 20:
		global_position.x = -20

func _bounce() -> void:
	velocity.y = jump_force
	bounced.emit(global_position.y)

## Returns horizontal velocity based on which half of the screen is touched.
func _get_touch_horizontal() -> float:
	if not DisplayServer.is_touchscreen_available():
		return 0.0
	# Check active touches
	for i in range(10):
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			var touch_pos := get_viewport().get_mouse_position()
			if touch_pos.x < screen_width / 2.0:
				return -move_speed
			else:
				return move_speed
	return 0.0

## Custom draw for the player's doodle-like appearance.
func _draw() -> void:
	# Body - green rectangle
	var body_rect := Rect2(-15, -20, 30, 40)
	draw_rect(body_rect, Color(0.3, 0.8, 0.2))

	# Left eye - white circle with black pupil
	draw_circle(Vector2(-6, -10), 6, Color.WHITE)
	draw_circle(Vector2(-4, -10), 3, Color.BLACK)

	# Right eye - white circle with black pupil
	draw_circle(Vector2(8, -10), 6, Color.WHITE)
	draw_circle(Vector2(10, -10), 3, Color.BLACK)

	# Feet
	draw_rect(Rect2(-12, 18, 10, 5), Color(0.3, 0.8, 0.2))
	draw_rect(Rect2(2, 18, 10, 5), Color(0.3, 0.8, 0.2))
