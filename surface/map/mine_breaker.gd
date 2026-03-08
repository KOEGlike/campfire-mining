extends Node2D

var _started: bool = false
var _timer: float = 0.0
var _interval: float = 0.5
var _children: Array = []
var _current_index: int = 0

func _ready() -> void:
	Manager.mine_end.connect(_start)

func _start() -> void:
	_children = get_children().duplicate()
	_children.shuffle()
	_current_index = 0
	_timer = 0.0
	_started = true

func _process(delta: float) -> void:
	if not _started:
		return
	
	if _current_index >= _children.size():
		_started = false
		return
	
	_timer += delta
	if _timer >= _interval:
		_timer = 0.0
		var child = _children[_current_index]
		child.disappearing_tile.disappear()
		_current_index += 1
