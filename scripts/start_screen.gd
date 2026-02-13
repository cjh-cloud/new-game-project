# Attach to: VBoxContainer (StartScreen inside CanvasLayer in main.tscn)
# Shows the title, high score, and a tap-to-start prompt.
class_name StartScreen
extends VBoxContainer

@onready var high_score_label: Label = $HighScoreLabel

func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED and visible:
		_update_high_score()

func _update_high_score() -> void:
	# 1. Check if the node is in the tree AND if the label is actually ready
	if not is_inside_tree() or not is_node_ready():
		return
	
	# 2. Safety check for the label specifically
	if high_score_label == null:
		return

	var main_node := get_node_or_null("/root/Main")
	if main_node and main_node is Main:
		high_score_label.text = "Best: %d" % main_node.high_score
	else:
		high_score_label.text = "Best: 0"

func _input(event: InputEvent) -> void:
	if not visible:
		return
	# Start on any touch or key press
	if event is InputEventScreenTouch and event.pressed:
		_start()
	elif event is InputEventKey and event.pressed:
		_start()
	elif event is InputEventMouseButton and event.pressed:
		_start()

func _start() -> void:
	var main_node := get_node_or_null("/root/Main")
	if main_node and main_node is Main:
		main_node.start_game()
