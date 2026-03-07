extends StaticBody2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Manager.surface_tree_fall.connect(
		func ():
			animation_player.play("tree fall")
	)
