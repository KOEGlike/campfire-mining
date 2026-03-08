extends Node2D

@onready var side_1: Node2D = $Side1
@onready var side_2: Node2D = $Side2

var is_sliding:bool=false

func _ready() -> void:
	Manager.the_hole_open.connect(start)
	
func start():
	is_sliding=true

func _process(delta: float) -> void:
	if is_sliding:
		var amout:=delta*200
		side_1.position.x+=amout
		side_2.position.x-=amout

	
