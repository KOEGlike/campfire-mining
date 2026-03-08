extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		Manager.add_star()
		queue_free()  # csillag eltűnik
