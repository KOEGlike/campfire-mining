extends Button

func _on_pressed() -> void:
	Manager.delete_user_and_restart()
