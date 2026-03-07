extends StaticBody2D

@export var disappear_on_earthquake:bool

@onready var disappearing_tile: DisappearingTile = $DisappearingTile

func _ready() -> void:
	disappearing_tile.disappear_on_earthquake=disappear_on_earthquake
