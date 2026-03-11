extends Node2D

@export var item: PackedScene
@export var fall_speed: float = 300.0
@export var wait_time: float = 5

var _falling: bool = false
var _spawned_item: Node2D = null
var _waiting: bool = false
var _wait_timer: float = 0.0

func _ready() -> void:
	Manager.the_hole_start.connect(_start)

func _start():
	if item == null:
		return
	_waiting = true
	_wait_timer = 0.0

func _process(delta: float) -> void:
	# Várakozás
	if _waiting:
		_wait_timer += delta
		if _wait_timer >= wait_time:
			_waiting = false
			_spawned_item = item.instantiate()
			add_child(_spawned_item)
			_spawned_item.position = Vector2.ZERO
			_falling = true
		return
	
	if _spawned_item == null:
		return
	
	# Leesés
	if _falling:
		_spawned_item.position.y += fall_speed * delta
		fall_speed += 100.0 * delta
		_spawned_item.rotation += delta * 2.0
