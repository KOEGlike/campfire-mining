extends Node2D

const MINECART = preload("uid://cxl1eu2y35w1e")

@onready var timer: Timer = $Timer
@export var goleft: bool
@export var startdelay: float
@export var frequency: float
@export var other_spawner: NodePath

var spawn_count: int = 0
var _synced: bool = false

func _ready() -> void:
	await get_tree().create_timer(startdelay).timeout
	timer.start(frequency)

func _on_timer_timeout() -> void:
	spawn_count += 1

	if spawn_count >= 5:
		# Saját irányba spawnol
		_spawn_cart(goleft)
		# Másik spawner is spawnoljon most
		if not _synced and other_spawner:
			var other = get_node(other_spawner)
			other._synced = true
			other._spawn_cart(other.goleft)
		_synced = false
	else:
		_spawn_cart(goleft)

func _spawn_cart(left: bool) -> void:
	var cart: Minecart = MINECART.instantiate()
	get_parent().add_child(cart)
	cart.global_position = global_position
	cart.goleft = left
