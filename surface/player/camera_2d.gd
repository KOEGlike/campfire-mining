extends Camera2D

@onready var wobble: WobbleUtility = $Wobble


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Manager.start_earthquake.connect(wobble.start)
	Manager.the_hole_open.connect(wobble.start)
	Manager.mine_end.connect(wobble.start)
