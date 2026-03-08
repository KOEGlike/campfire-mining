class_name Minecart

extends CharacterBody2D

const SPEED = 800.0

@export var goleft: bool

func _physics_process(delta):
	if goleft:
		velocity.x = - SPEED
	else:
		velocity.x = SPEED
	velocity.y = 0
	
	move_and_slide()
	
	# Minden collision-t figyelmen kívül hagy - visszatolja a másikat
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is CharacterBody2D:
			collider.velocity += collision.get_normal() * -SPEED

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		var player: Player = body
		if goleft:
			player.apply_knockback(Vector2(-1300, 70))
		else:
			player.apply_knockback(Vector2(1300, 70))
