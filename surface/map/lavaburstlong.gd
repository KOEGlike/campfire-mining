extends Area2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.play("Popup")

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		Manager.restart()
