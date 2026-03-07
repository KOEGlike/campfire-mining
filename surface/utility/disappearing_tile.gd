class_name DisappearingTile

extends Node

@export var disappear_on_earthquake: bool
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
	if disappear_on_earthquake:
		Manager.start_earthquake.connect(disappear)
	

func disappear():
	wobble_node.start();
	await wobble_node.finished
	_remove()

func _remove():
	collision_shape_2d.queue_free()
	icon.queue_free()
	cpu_particles_2d.restart()
	await cpu_particles_2d.finished
	node.queue_free()
