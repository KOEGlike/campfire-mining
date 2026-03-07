extends Camera2D

@onready var wobble: WobbleUtility = $Wobble


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Manager.start_earthquake.connect(wobble.start)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
