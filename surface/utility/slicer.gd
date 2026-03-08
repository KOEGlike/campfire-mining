class_name GroundSlicer
extends  Node

@export var enabled: bool = false
@export var slice_angle: float = 110.0
@export var slice_speed: float = 200.0

var _slicing: bool = false
var _target_rotation: float = 0.0

func _ready() -> void:
	if enabled:
		Manager.surface_ground_fall.connect(start_slice)

func start_slice() -> void:
	_target_rotation = slice_angle
	_slicing = true

func _process(delta: float) -> void:
	if not _slicing:
		return
	
	var parent = get_parent()
	if parent == null:
		return
	
	var current = parent.rotation_degrees
	var direction = sign(_target_rotation - current)
	parent.rotation_degrees += direction * slice_speed * delta
	
	if abs(parent.rotation_degrees - _target_rotation) < 1.0:
		parent.rotation_degrees = _target_rotation
		_slicing = false
