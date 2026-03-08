class_name EndScreen
extends CanvasLayer

signal closed

@onready var title_label: Label = $Control/Panel/VBoxContainer/Title
@onready var score_label: Label = $Control/Panel/VBoxContainer/Score
@onready var lives_label: Label = $Control/Panel/VBoxContainer/Lives
@onready var warning_label: Label = $Control/Panel/VBoxContainer/Warning
@onready var continue_button: Button = $Control/Panel/VBoxContainer/Continue

func _ready() -> void:
	continue_button.pressed.connect(_on_continue_pressed)

func setup(completed: bool, score: int, lives_left: int, score_will_submit: bool) -> void:
	title_label.text = "Level Finished" if completed else "You Died"
	score_label.text = "Score: %d" % score
	lives_label.text = "Lives Left: %d" % max(lives_left, 0)

	if score_will_submit:
		warning_label.text = ""
	else:
		warning_label.text = "No lives left: you can keep playing, but this score will not go on the scoreboard."

func _on_continue_pressed() -> void:
	closed.emit()
	queue_free()
