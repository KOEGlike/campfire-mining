extends StaticBody2D

@export var disappear: bool

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var icon: Sprite2D = $Icon
@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D
@onready var wobble: WobbleUtility = $Wobble


func _ready() -> void:
	if disappear:
		Manager.start_earthquake.connect(fall)


func fall():
	wobble.start();
	await wobble.finished
	remove()

func remove():
	collision_shape_2d.queue_free()
	icon.queue_free()
	cpu_particles_2d.restart()
	await cpu_particles_2d.finished
	queue_free()
