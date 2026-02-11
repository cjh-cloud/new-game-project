# Attach to: VBoxContainer (HUDContainer inside CanvasLayer in main.tscn)
# Displays the current score at the top of the screen.
class_name HUD
extends VBoxContainer

@onready var score_label: Label = $ScoreLabel

func _process(_delta: float) -> void:
	var main_node := get_node_or_null("/root/Main")
	if main_node and main_node is Main:
		score_label.text = "Score: %d" % main_node.score
