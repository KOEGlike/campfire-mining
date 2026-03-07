extends StaticBody2D

@export var disappear:bool

@onready var disappearing_tile: DisappearingTile = $DisappearingTile

func _ready() -> void:
	if disappear:
		Manager.surface_ground_fall.connect(disappearing_tile.disappear)
