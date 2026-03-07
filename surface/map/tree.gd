extends StaticBody2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var fall_left:bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Manager.surface_tree_fall.connect(
		func ():
			if fall_left:
				animation_player.play("tree fall left")
			else:
				animation_player.play("tree fall")
	)
