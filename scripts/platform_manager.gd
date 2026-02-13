# Attach to: Node2D (PlatformManager node in main.tscn)
# Procedurally generates and cleans up platforms as the player climbs.
class_name PlatformManager
extends Node2D

## Packed scenes for each platform type.
var normal_platform_scene: PackedScene = preload("res://scenes/platforms/normal_platform.tscn")
var moving_platform_scene: PackedScene = preload("res://scenes/platforms/moving_platform.tscn")
var breakable_platform_scene: PackedScene = preload("res://scenes/platforms/breakable_platform.tscn")

## The Y coordinate of the highest platform generated so far.
var highest_platform_y: float = 0.0

## Screen dimensions for placing platforms within bounds.
var screen_width: float = 480.0

## Horizontal margin so platforms don't clip the edges.
const MARGIN: float = 40.0

## Base vertical spacing range (increases with difficulty).
var min_spacing: float = 80.0
var max_spacing: float = 140.0

## Maximum spacing cap so the game stays beatable.
const MAX_SPACING_CAP: float = 220.0

## How many initial platforms to spawn.
const INITIAL_PLATFORM_COUNT: int = 12

## How far above the camera top to keep generating platforms.
const GENERATION_BUFFER: float = 400.0

## How far below the camera bottom before a platform is freed.
const CLEANUP_BUFFER: float = 200.0

func _ready() -> void:
	screen_width = get_viewport_rect().size.x

## Spawns the initial set of platforms. Call this from main.gd at game start.
## `start_y` is the Y position of the player's starting platform.
func generate_initial_platforms(start_y: float) -> void:
	# Clear any existing platforms
	for child in get_children():
		child.queue_free()

	highest_platform_y = start_y

	# Place the very first platform directly under the player
	_spawn_platform(screen_width / 2.0, start_y, 0)  # always normal

	# Generate platforms going upward
	for i in range(INITIAL_PLATFORM_COUNT):
		var spacing := randf_range(min_spacing, max_spacing)
		highest_platform_y -= spacing
		var x := randf_range(MARGIN, screen_width - MARGIN)
		_spawn_platform(x, highest_platform_y, _pick_platform_type(0.0))

## Generates new platforms above the viewport as the camera moves up.
## `camera_top_y` is the top edge of the camera in world coords.
## `difficulty` is a 0..1+ value that increases platform variety and spacing.
func generate_platforms(camera_top_y: float, difficulty: float) -> void:
	# Scale spacing with difficulty
	var current_max_spacing: float = min(max_spacing + difficulty * 60.0, MAX_SPACING_CAP)
	var current_min_spacing: float = min(min_spacing + difficulty * 20.0, current_max_spacing - 20.0)

	while highest_platform_y > camera_top_y - GENERATION_BUFFER:
		var spacing := randf_range(current_min_spacing, current_max_spacing)
		highest_platform_y -= spacing
		var x := randf_range(MARGIN, screen_width - MARGIN)
		_spawn_platform(x, highest_platform_y, _pick_platform_type(difficulty))

## Removes platforms that have scrolled far below the camera.
## `camera_bottom_y` is the bottom edge of the camera in world coords.
func cleanup_platforms(camera_bottom_y: float) -> void:
	for child in get_children():
		if child.global_position.y > camera_bottom_y + CLEANUP_BUFFER:
			child.queue_free()

## Picks a platform type index based on difficulty.
## 0 = normal, 1 = moving, 2 = breakable
func _pick_platform_type(difficulty: float) -> int:
	var roll := randf()
	# Increase breakable/moving chance with difficulty
	var breakable_chance := clampf(0.1 + difficulty * 0.15, 0.1, 0.3)
	var moving_chance := clampf(0.1 + difficulty * 0.1, 0.1, 0.25)

	if roll < breakable_chance:
		return 2
	elif roll < breakable_chance + moving_chance:
		return 1
	else:
		return 0

## Spawns a single platform at the given position.
func _spawn_platform(x: float, y: float, type: int) -> void:
	var platform: Node2D
	match type:
		0:
			platform = normal_platform_scene.instantiate()
		1:
			platform = moving_platform_scene.instantiate()
		2:
			platform = breakable_platform_scene.instantiate()
		_:
			platform = normal_platform_scene.instantiate()

	platform.position = Vector2(x, y)
	add_child(platform)
