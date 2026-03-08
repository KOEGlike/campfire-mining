class_name Player

extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -650.0

var knockback = Vector2.ZERO
var can_move := false
var _death_handled := false
var _touch_left_ids: Dictionary = {}
var _touch_right_ids: Dictionary = {}
var _touch_jump_ids: Dictionary = {}
var _touch_jump_just_pressed := false

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
	_clear_all_touch_input()
	print("[Player] requesting restart with score submit")
	Manager.restart(true)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_screen_touch(event)
	elif event is InputEventScreenDrag:
		_handle_screen_drag(event)

func _physics_process(delta: float) -> void:
	if not can_move:
		return

	# Gravitáció
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	var wants_jump := Input.is_action_just_pressed("jump") or _touch_jump_just_pressed
	_touch_jump_just_pressed = false
	if wants_jump and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Knockback
	if knockback.length() > 10.0:
		velocity.x = knockback.x
		knockback = knockback.move_toward(Vector2.ZERO, 1200 * delta)
	else:
		knockback = Vector2.ZERO

	# Mozgás
	var direction := Input.get_axis("left", "right")
	if direction == 0.0:
		direction = _touch_direction()
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

func _handle_screen_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		_set_touch_zone(event.index, _touch_zone_at(event.position))
	else:
		_clear_touch_id(event.index)

func _handle_screen_drag(event: InputEventScreenDrag) -> void:
	_set_touch_zone(event.index, _touch_zone_at(event.position))

func _touch_zone_at(position: Vector2) -> StringName:
	var viewport_size := get_viewport_rect().size
	if position.y < viewport_size.y * 0.5:
		return &"jump"
	if position.x < viewport_size.x * 0.5:
		return &"left"
	return &"right"

func _set_touch_zone(touch_id: int, zone: StringName) -> void:
	_clear_touch_id(touch_id)
	match zone:
		&"left":
			_touch_left_ids[touch_id] = true
		&"right":
			_touch_right_ids[touch_id] = true
		&"jump":
			_touch_jump_ids[touch_id] = true
			_touch_jump_just_pressed = true

func _clear_touch_id(touch_id: int) -> void:
	_touch_left_ids.erase(touch_id)
	_touch_right_ids.erase(touch_id)
	_touch_jump_ids.erase(touch_id)

func _clear_all_touch_input() -> void:
	_touch_left_ids.clear()
	_touch_right_ids.clear()
	_touch_jump_ids.clear()
	_touch_jump_just_pressed = false

func _touch_direction() -> float:
	var has_left := not _touch_left_ids.is_empty()
	var has_right := not _touch_right_ids.is_empty()
	if has_left == has_right:
		return 0.0
	return -1.0 if has_left else 1.0
