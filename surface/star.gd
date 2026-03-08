extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body is Player or body.is_in_group("player"):
		Manager.add_star()
		queue_free() # csillag eltűnik
