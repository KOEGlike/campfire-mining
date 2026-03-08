extends Node2D

@export var item:Node2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Manager.the_hole_start.connect(_start)
	Manager.the_hole_open.connect(_end)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _start():
	pass
func _end():
	pass
