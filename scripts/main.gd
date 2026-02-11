# Attach to: Node2D (root of main.tscn)
# Orchestrates the game loop: camera tracking, score, platform generation,
# game state transitions (start, playing, game over).
class_name Main
extends Node2D

@onready var player: Player = $Player
@onready var camera: Camera2D = $Camera2D
@onready var platform_manager: PlatformManager = $PlatformManager
@onready var hud: Control = $HUD/HUDContainer
@onready var start_screen: Control = $HUD/StartScreen
@onready var game_over_screen: Control = $HUD/GameOverScreen
@onready var background: ColorRect = $Background

## The viewport height in pixels.
var screen_height: float = 854.0
var screen_width: float = 480.0

## Highest point the player has reached (used for score).
var highest_y: float = 0.0
var score: int = 0
var high_score: int = 0

## Difficulty factor that ramps up over time (0.0 = easy, 1.0+ = hard).
var difficulty: float = 0.0

## Player starting position.
var player_start_y: float = 600.0

enum GameState { START, PLAYING, GAME_OVER }
var state: int = GameState.START

func _ready() -> void:
	screen_height = get_viewport_rect().size.y
	screen_width = get_viewport_rect().size.x

	high_score = _load_high_score()

	# Position player at the start
	player.position = Vector2(screen_width / 2.0, player_start_y)
	player.set_physics_process(false)

	# Position camera so the player appears ~30% from the top of the screen.
	# With DRAG_CENTER: camera center = player_y + 0.2 * screen_height
	camera.position = Vector2(screen_width / 2.0, player_start_y + screen_height * 0.2)

	# Set up the background
	_update_background()

	# Generate the initial platforms
	platform_manager.generate_initial_platforms(player_start_y + 30.0)

	# Connect player bounce signal
	player.bounced.connect(_on_player_bounced)

	# Show start screen, hide others
	start_screen.visible = false  # toggle off then on to trigger visibility notification
	game_over_screen.visible = false
	hud.visible = false
	start_screen.visible = true

func _physics_process(_delta: float) -> void:
	if state != GameState.PLAYING:
		return

	# --- Camera follows player upward only ---
	# Keep the player at ~30% from the top of the viewport.
	var target_y := player.position.y + screen_height * 0.2
	if target_y < camera.position.y:
		camera.position.y = target_y

	# Keep camera centered horizontally
	camera.position.x = screen_width / 2.0

	# --- Update background to follow camera ---
	_update_background()

	# --- Generate new platforms above the camera ---
	var camera_top_y := camera.position.y - screen_height / 2.0
	var camera_bottom_y := camera.position.y + screen_height / 2.0
	platform_manager.generate_platforms(camera_top_y, difficulty)
	platform_manager.cleanup_platforms(camera_bottom_y)

	# --- Update score ---
	if player.position.y < highest_y:
		highest_y = player.position.y
		score = int(abs(highest_y - player_start_y) / 10.0)
		difficulty = clampf(score / 500.0, 0.0, 2.0)

	# --- Check game over: player fell below camera ---
	if player.position.y > camera_bottom_y + 100:
		_game_over()

func _on_player_bounced(height: float) -> void:
	# Check if the player landed on a breakable platform
	# We detect this through the player's floor collision
	var last_collision := player.get_last_slide_collision()
	if last_collision:
		var collider := last_collision.get_collider()
		if collider is BreakablePlatform:
			collider.start_break()

func start_game() -> void:
	state = GameState.PLAYING

	# Reset everything
	score = 0
	highest_y = player_start_y
	difficulty = 0.0

	player.position = Vector2(screen_width / 2.0, player_start_y)
	player.velocity = Vector2.ZERO
	player.set_physics_process(true)

	camera.position = Vector2(screen_width / 2.0, player_start_y + screen_height * 0.2)

	platform_manager.generate_initial_platforms(player_start_y + 30.0)

	# Give the player an initial bounce
	player.velocity.y = player.jump_force

	# Show HUD, hide screens
	start_screen.visible = false
	game_over_screen.visible = false
	hud.visible = true

func _game_over() -> void:
	state = GameState.GAME_OVER
	player.set_physics_process(false)

	# Update high score
	if score > high_score:
		high_score = score
		_save_high_score(high_score)

	# Show game over screen
	game_over_screen.visible = true

func restart_game() -> void:
	start_game()

func _update_background() -> void:
	# Position the background to always fill the camera viewport
	background.position = Vector2(
		camera.position.x - screen_width / 2.0,
		camera.position.y - screen_height / 2.0
	)

func _save_high_score(value: int) -> void:
	var file := FileAccess.open("user://highscore.dat", FileAccess.WRITE)
	if file:
		file.store_32(value)

func _load_high_score() -> int:
	if not FileAccess.file_exists("user://highscore.dat"):
		return 0
	var file := FileAccess.open("user://highscore.dat", FileAccess.READ)
	if file:
		return file.get_32()
	return 0
