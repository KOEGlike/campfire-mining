class_name Player

extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -650.0

var knockback = Vector2.ZERO
var can_move := false
var _death_handled := false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("player")
	Manager.registered.connect(func(): can_move = true)

func _process(_delta: float) -> void:
	if _death_handled:
		return
	if _is_crushed():
		die()

func die() -> void:
	if _death_handled:
		return
	print("[Player] die() triggered")
	_death_handled = true
	_handle_death()

func _handle_death() -> void:
	can_move = false
	set_physics_process(false)
	velocity = Vector2.ZERO
	print("[Player] requesting restart with score submit")
	Manager.restart(true)

func _physics_process(delta: float) -> void:
	if not can_move:
		return

	# Gravitáció
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Knockback
	if knockback.length() > 10.0:
		velocity.x = knockback.x
		knockback = knockback.move_toward(Vector2.ZERO, 1200 * delta)
	else:
		knockback = Vector2.ZERO

	# Mozgás
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
			if col_a.get_normal().dot(col_b.get_normal()) < -0.5:
				return true
	return false

func apply_knockback(force: Vector2) -> void:
	knockback = force
	velocity = force
