# Attach to: StaticBody2D (root of normal_platform.tscn)
# A standard green platform that never moves or breaks.
class_name NormalPlatform
extends StaticBody2D

const PLATFORM_WIDTH: float = 60.0
const PLATFORM_HEIGHT: float = 12.0

func _draw() -> void:
	var rect := Rect2(-PLATFORM_WIDTH / 2.0, -PLATFORM_HEIGHT / 2.0, PLATFORM_WIDTH, PLATFORM_HEIGHT)
	draw_rect(rect, Color(0.2, 0.75, 0.2))
	# Subtle top highlight
	draw_rect(Rect2(-PLATFORM_WIDTH / 2.0, -PLATFORM_HEIGHT / 2.0, PLATFORM_WIDTH, 3), Color(0.3, 0.9, 0.3))
