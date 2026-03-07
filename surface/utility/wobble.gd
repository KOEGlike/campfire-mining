class_name WobbleUtility

extends Node

@export var node:Node2D
@export var wobble := 8.0
@export var wobble_time := 3

signal finished

var wobbling := false
var wobble_elapsed := 0.0
var origin_position := Vector2.ZERO
var rand_freq_x := 1.0
var rand_freq_y := 1.0
var rand_freq_rot := 1.0
var rand_phase_x := 0.0
var rand_phase_y := 0.0
var rand_phase_rot := 0.0

func start():
	origin_position=node.global_position
	wobbling=true
	await get_tree().create_timer(wobble_time).timeout
	wobbling=false
	finished.emit()

func _process(delta: float) -> void:
	if wobbling:
		wobble_elapsed += delta
		var intensity := (wobble_elapsed / wobble_time) * wobble
		node.rotation = deg_to_rad(sin(wobble_elapsed * 20.0 * rand_freq_rot + rand_phase_rot) * intensity)
		var shake := intensity * 0.5
		node.global_position = origin_position + Vector2(
			sin(wobble_elapsed * 37.0 * rand_freq_x + rand_phase_x) * shake,
			cos(wobble_elapsed * 29.0 * rand_freq_y + rand_phase_y) * shake
		)
