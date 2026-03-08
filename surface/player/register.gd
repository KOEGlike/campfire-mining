extends Control

@onready var line_edit: LineEdit = $LineEdit
@onready var button: Button = $Button

func _ready() -> void:
	button.pressed.connect(_on_submit)
	Manager.registered.connect(_on_registered)

	# Ha már van mentett user, skip registration
	if Manager.has_saved_user():
		print("[Register] Already registered as: ", Manager.user_name)
		visible = false
		Manager.registered.emit()
		Manager.timeline()

func _on_submit() -> void:
	var player_name = line_edit.text.strip_edges()
	if player_name == "":
		return
	button.text = "SENDING..."
	button.disabled = true
	Manager.send_name(player_name)

func _on_registered() -> void:
	visible = false
	Manager.timeline()
