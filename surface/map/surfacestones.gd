extends Node2D
@onready var stone: StaticBody2D = $Stone
@onready var stone_2: StaticBody2D = $Stone2
@onready var stone_3: StaticBody2D = $Stone3


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Manager.surface_ground_fall.connect(stone.disappearing_tile.disappear)
	Manager.surface_ground_fall.connect(stone_2.disappearing_tile.disappear)
	Manager.surface_ground_fall.connect(stone_3.disappearing_tile.disappear)
