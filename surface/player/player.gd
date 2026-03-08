class_name Player

extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -550.0

var knockback = Vector2.ZERO

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _process(delta: float) -> void:
	if _is_crushed():
		get_tree().reload_current_scene()

func _physics_process(delta: float) -> void:
	# Gravitáció
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Knockback
	if knockback.length() > 10.0:
		velocity.x = knockback.x # ← X: balra/jobbra lökés
		knockback = knockback.move_toward(Vector2.ZERO, 1200 * delta)
	else:
		knockback = Vector2.ZERO

	# Mozgás – knockback közben a játékos nem irányíthat
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction and knockback == Vector2.ZERO:
		velocity.x = direction * SPEED
		animated_sprite_2d.flip_h = direction < 0
		if not is_on_floor():
			animated_sprite_2d.play('jump_walk')
		else:
			animated_sprite_2d.play('walk')
	else:
		if not is_on_floor():
			animated_sprite_2d.play('jump')
		else:
			animated_sprite_2d.play("default")
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
func _is_crushed() -> bool:
	if get_slide_collision_count() < 2:
		return false
	
	for i in get_slide_collision_count():
		for j in range(i + 1, get_slide_collision_count()):
			var col_a = get_slide_collision(i)
			var col_b = get_slide_collision(j)
				# If two collision normals point in roughly opposite directions, player is crushed
			if col_a.get_normal().dot(col_b.get_normal()) < -0.5:
				return true
	return false

func apply_knockback(force: Vector2) -> void:
	knockback = force
	velocity = force # ← AZONNAL felfelé löki, nem várja a következő frame-et!
