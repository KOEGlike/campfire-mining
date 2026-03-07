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
	_spawn_cart(goleft)

func _spawn_cart(left: bool) -> void:
	var cart: Minecart = MINECART.instantiate()
	
	
	cart.goleft = left
	add_sibling(cart)
	cart.global_position = self.global_position	
	if left:
		cart.scale.x *= -1
	
