extends Node2D

@onready var collision_shape_2d: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var collision_shape_2d_1: CollisionShape2D = $Area2D/CollisionShape2D
@onready var collision_shape_2d_4: CollisionShape2D = $Area2D/CollisionShape2D4
@onready var collision_shape_2d_3: CollisionShape2D = $Area2D/CollisionShape2D3
@onready var collision_shape_2d_2: CollisionShape2D = $Area2D/CollisionShape2D2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collision_shape_2d.set_deferred("disabled", true)
	collision_shape_2d_1.set_deferred("disabled", true)
	collision_shape_2d_2.set_deferred("disabled", true)
	collision_shape_2d_3.set_deferred("disabled", true)
	collision_shape_2d_4.set_deferred("disabled", true)
	Manager.surface_tree_fall.connect(_enable_shapes)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _enable_shapes():
	await get_tree().create_timer(0.5).timeout
	collision_shape_2d_1.set_deferred("disabled", false)
	collision_shape_2d_2.set_deferred("disabled", false)
	collision_shape_2d_3.set_deferred("disabled", false)
	collision_shape_2d_4.set_deferred("disabled", false)


func _on_button_pressed() -> void:
	Manager.restart(false)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		collision_shape_2d.set_deferred("disabled", false)
