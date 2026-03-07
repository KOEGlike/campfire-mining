class_name GameManager

extends Node

signal start_earthquake
signal surface_tree_fall
signal surface_ground_fall


func _ready():
	await get_tree().create_timer(2).timeout
	start_earthquake.emit()
	surface_tree_fall.emit()
