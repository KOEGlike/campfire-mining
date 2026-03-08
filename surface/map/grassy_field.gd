extends StaticBody2D

@export var disappear: bool
@export var slice: bool

@onready var disappearing_tile: DisappearingTile = $DisappearingTile

func _ready() -> void:
	if disappear:
		Manager.surface_ground_fall.connect(disappearing_tile.disappear)
