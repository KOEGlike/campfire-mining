extends Control

@onready var line_edit: LineEdit = $LineEdit
@onready var button: Button = $Button

func _ready() -> void:
	button.pressed.connect(_on_submit)
	Manager.registered.connect(_on_registered)
	Manager.load_user_data()

	# Ha már van mentett user, skip registration
	if Manager.user_id != -1:
		print("[Register] Already registered as: ", Manager.user_name)
		visible = false
		call_deferred("_resume_with_saved_user")

func _resume_with_saved_user() -> void:
	Manager.registered.emit()

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
