class_name DisappearingTile

extends Node

@export var starter_signal:Signal

@export var icon: Sprite2D
@export var collision_shape_2d: CollisionShape2D
@export var cpu_particles_2d: CPUParticles2D

@export var node: Node2D
@export var wobble := 8.0
@export var wobble_time := 3


@onready var wobble_node: WobbleUtility = $Wobble

func _ready() -> void:
	await node.ready
	cpu_particles_2d.texture = icon.texture
	wobble_node.node = node
	wobble_node.wobble = wobble
	wobble_node.wobble_time = wobble_time
	

func disappear():
	wobble_node.start();
	await wobble_node.finished
	_remove()

func _remove():
	if collision_shape_2d.is_queued_for_deletion():
		return
	collision_shape_2d.queue_free()
	icon.queue_free()
	cpu_particles_2d.restart()
	await cpu_particles_2d.finished
	node.queue_free()
