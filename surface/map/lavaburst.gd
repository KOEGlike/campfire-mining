extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var min_wait: float = 1.0
@export var max_wait: float = 5.0

func _ready() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)
	_start_random_wait()

func _start_random_wait() -> void:
	var wait_time := randf_range(min_wait, max_wait)
	await get_tree().create_timer(wait_time).timeout
	if is_inside_tree():
		animation_player.play("Popup")

func _on_animation_finished(_anim_name: StringName) -> void:
	_start_random_wait()

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		Manager.restart()
