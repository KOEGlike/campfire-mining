extends StaticBody2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D

@export var fall_left:bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Manager.surface_tree_fall.connect(
		func ():
			if fall_left:
				animation_player.play("tree fall left")
			else:
				animation_player.play("tree fall")
	)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	cpu_particles_2d.restart()


func _on_button_pressed() -> void:
	pass # Replace with function body.
