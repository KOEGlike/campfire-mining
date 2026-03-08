class_name GameManager

extends Node

signal start_earthquake()
signal surface_tree_fall()
signal surface_ground_fall()

signal the_hole_start()
signal the_hole_open()




func _ready():
	await get_tree().create_timer(2).timeout
	start_earthquake.emit()
	surface_tree_fall.emit()
	surface_ground_fall.emit()
