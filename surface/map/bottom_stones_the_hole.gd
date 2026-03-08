extends Node2D

@onready var side_1: Node2D = $Side1
@onready var side_2: Node2D = $Side2

var is_sliding: bool = false

@export var open_distance: float = 500.0
@export var duration: float = 1.5

var _time: float = 0.0
var _shake_intensity: float = 5.0
var _shaking: bool = false
var _shake_timer: float = 0.0
var _shake_duration: float = 0.5

func _ready() -> void:
	Manager.the_hole_open.connect(start)

func start():
	# Először rázkódás, aztán nyílik
	_shaking = true
	_shake_timer = 0.0

func _process(delta: float) -> void:
	# 1. Rázkódás fázis - mielőtt szétnyílik
	if _shaking:
		_shake_timer += delta
		var shake = randf_range(-_shake_intensity, _shake_intensity)
		side_1.position.x = shake
		side_2.position.x = shake
		
		# Rázkódás egyre erősebb
		_shake_intensity = lerp(5.0, 15.0, _shake_timer / _shake_duration)
		
		if _shake_timer >= _shake_duration:
			_shaking = false
			is_sliding = true
			_time = 0.0
			side_1.position.x = 0.0
			side_2.position.x = 0.0
		return
	
	# 2. Szétnyílás fázis - ease out
	if is_sliding:
		_time += delta
		var t = clamp(_time / duration, 0.0, 1.0)
		
		# Ease out - gyorsan indul, lassan áll meg
		var eased = 1.0 - pow(1.0 - t, 3.0)
		
		var offset = eased * open_distance
		side_1.position.x = offset
		side_2.position.x = -offset
		
		# Kis rázkódás közben is
		if t < 0.8:
			var micro_shake = randf_range(-2.0, 2.0) * (1.0 - t)
			side_1.position.y = micro_shake
			side_2.position.y = micro_shake
		else:
			side_1.position.y = 0.0
			side_2.position.y = 0.0
		
		if t >= 1.0:
			is_sliding = false
