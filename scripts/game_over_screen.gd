# Attach to: VBoxContainer (GameOverScreen inside CanvasLayer in main.tscn)
# Shows game over info: final score, high score, and a restart button.
class_name GameOverScreen
extends VBoxContainer

@onready var final_score_label: Label = $FinalScoreLabel
@onready var best_score_label: Label = $BestScoreLabel
@onready var restart_button: Button = $RestartButton

func _ready() -> void:
	restart_button.pressed.connect(_on_restart_pressed)

func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED and visible and is_inside_tree():
		_update_labels()

func _update_labels() -> void:
	var main_node := get_node_or_null("/root/Main")
	if main_node and main_node is Main:
		final_score_label.text = "Score: %d" % main_node.score
		best_score_label.text = "Best: %d" % main_node.high_score

func _on_restart_pressed() -> void:
	var main_node := get_node_or_null("/root/Main")
	if main_node and main_node is Main:
		main_node.restart_game()
