extends CharacterBody2D

const SPEED = 200.0
const BOUNCE_SPEED = -150.0
const PLAYER_KNOCKBACK = Vector2(-400, -200)

@export var goleft:bool


func _physics_process(delta):
	velocity.x = SPEED
	if(goleft):
		velocity.x = -SPEED
	
	
	
	move_and_slide()
	



func _on_area_2d_body_entered(body: Node2D) -> void:
	print("lol", body.name)
	if body is Player:
		var player:Player=body
		if goleft:
			player.apply_knockback(Vector2(-1300, 70))
		else:
			player.apply_knockback(Vector2(1300, -70))
	
			
