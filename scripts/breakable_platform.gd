# Attach to: StaticBody2D (root of breakable_platform.tscn)
# A brown platform that crumbles and disappears after the player bounces on it.
class_name BreakablePlatform
extends StaticBody2D

const PLATFORM_WIDTH: float = 60.0
const PLATFORM_HEIGHT: float = 12.0

var _is_breaking: bool = false

## Called by the main scene or player when a bounce happens on this platform.
func start_break() -> void:
	if _is_breaking:
		return
	_is_breaking = true
	# Disable collision immediately so the player falls through
	$CollisionShape2D.set_deferred("disabled", true)
	# Quick crumble tween: shrink and fade out, then free
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.0, 0.0), 0.25)
	tween.tween_property(self, "modulate:a", 0.0, 0.25)
	tween.chain().tween_callback(queue_free)

func _draw() -> void:
	var rect := Rect2(-PLATFORM_WIDTH / 2.0, -PLATFORM_HEIGHT / 2.0, PLATFORM_WIDTH, PLATFORM_HEIGHT)
	draw_rect(rect, Color(0.65, 0.4, 0.2))
	# Crack lines for visual cue
	draw_line(Vector2(-10, -2), Vector2(0, 3), Color(0.4, 0.25, 0.1), 1.5)
	draw_line(Vector2(5, -3), Vector2(15, 2), Color(0.4, 0.25, 0.1), 1.5)
	# Subtle top highlight
	draw_rect(Rect2(-PLATFORM_WIDTH / 2.0, -PLATFORM_HEIGHT / 2.0, PLATFORM_WIDTH, 3), Color(0.75, 0.5, 0.3))
