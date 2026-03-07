extends Area2D

@export var jump_height: float = 60.0
@export var jump_speed: float = 3.0
@export var pause_time: float = 1.5
@export var fall_speed: float = 150.0
@onready var sprite = $Lavaburslongt  # <-- Írd ide a sprite node nevét!

var _start_y: float
var _current_y: float
var _time: float = 0.0
var _paused: bool = true
var _pause_timer: float = 0.0
var _falling: bool = false

func _ready() -> void:
	_start_y = global_position.y
	body_entered.connect(_on_body_entered)
	_pause_timer = pause_time

func _process(delta: float) -> void:
	if _paused:
		scale.y = 1.0
		global_position.y = _start_y
		_pause_timer -= delta
		if _pause_timer <= 0.0:
			_paused = false
			_falling = false
			_time = 0.0
		return

	if _falling:
		scale.y = -1.0
		_current_y += fall_speed * delta
		global_position.y = _current_y
		if global_position.y >= _start_y:
			global_position.y = _start_y
			scale.y = 1.0
			_paused = true
			_pause_timer = pause_time
		return

	scale.y = 1.0
	_time += delta * jump_speed

	if _time >= PI / 2.0:
		_falling = true
		_current_y = global_position.y
	else:
		global_position.y = _start_y - sin(_time) * jump_height

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_tree().reload_current_scene()
