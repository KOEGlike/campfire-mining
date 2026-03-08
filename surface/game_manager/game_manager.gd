class_name GameManager

extends Node

@onready var http_request: HTTPRequest = $HTTPRequest

signal start_earthquake()
signal surface_tree_fall()
signal surface_ground_fall()

signal the_hole_start()
signal the_hole_open()
signal mine_end()


const USER_ID_FILE="user://user.id"


func _ready() -> void:
	http_request.request_completed.connect(_on_request_completed)
	timeline()
	
func timeline():
	await get_tree().create_timer(2).timeout
	start_earthquake.emit()
	await get_tree().create_timer(1).timeout
	surface_ground_fall.emit()
	await get_tree().create_timer(2).timeout
	surface_tree_fall.emit()
	await get_tree().create_timer(1).timeout
	the_hole_start.emit()
	await get_tree().create_timer(12).timeout
	the_hole_open.emit()
	await get_tree().create_timer(2).timeout
	mine_end.emit()	
func restart():
	get_tree().reload_current_scene()
	timeline()
	
func _on_request_completed(result:int, response_code:int, headers:PackedStringArray, body:PackedByteArray):
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		print("Data received: ", json["title"])
	else:
		print("Error: API returned status code ", response_code)
