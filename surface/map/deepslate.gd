extends StaticBody2D


@onready var disappearing_tile: DisappearingTile = $DisappearingTile

@export var disappear_on_stand:bool=false


func _on_area_2d_body_entered(body: Node2D) -> void:
	if disappear_on_stand and body is Player:
		await get_tree().create_timer(2).timeout
		disappearing_tile.disappear()
