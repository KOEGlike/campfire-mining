extends Area2D

var ladder_scene: PackedScene = preload("res://map/ladder.tscn")
var ladder_spawned: bool = false

func _on_body_entered(body: Node2D) -> void:
	print("VALAMI BELÉPETT: ", body.name, " | típus: ", body.get_class())
	
	if body is Player and not ladder_spawned:
		ladder_spawned = true
		print("PLAYER DETECTED!")
		
		var ladder = ladder_scene.instantiate()
		get_parent().add_child(ladder)
		ladder.global_position = body.global_position - Vector2(0, 30)
		print("LADDER SPAWNED at: ", ladder.global_position)
		
		body.set_physics_process(false)
		body.velocity = Vector2.ZERO
		
		await get_tree().create_timer(2.0).timeout
		
		Manager.stop_game_timer(true)
		var request_started = Manager.send_full_score()
		if request_started:
			await Manager.full_score_finished

		await Manager.show_end_screen(true, request_started)
		
		await get_tree().create_timer(1.0).timeout
		get_tree().paused = true
