class_name GameManager

extends Node

@onready var http_request: HTTPRequest = $HTTPRequest

signal start_earthquake()
signal surface_tree_fall()
signal surface_ground_fall()
signal the_hole_start()
signal the_hole_open()
signal mine_end()
signal registered()
signal score_submitted(response: Dictionary)

const USER_ID_FILE = "user://user.id"

# Memóriában tárolt user adatok
var user_id: int = -1
var user_name: String = ""
var user_alive: int = -1

# ============================================================
#  JÁTÉK VÁLTOZÓK
# ============================================================
var game_time: int = 0 # másodpercekben (1mp-ként nő 1-gyel)
var star_count: int = 0 # összegyűjtött csillagok
var is_completed: bool = false # végigcsinálta-e a pályát
var game_running: bool = false # fut-e a timer

# Melyik request van folyamatban
enum RequestType {NONE, REGISTER, FULL_SCORE}
var current_request: RequestType = RequestType.NONE

func _ready() -> void:
	http_request.request_completed.connect(_on_request_completed)
	load_user_data()

# ============================================================
#  TIMER - másodpercenként 1-et növel
# ============================================================

func _process(delta: float) -> void:
	if not game_running:
		return
	_time_accumulator += delta
	while _time_accumulator >= 1.0:
		_time_accumulator -= 1.0
		game_time += 1

var _time_accumulator: float = 0.0
var _timeline_run_id: int = 0

func start_game_timer() -> void:
	game_time = 0
	star_count = 0
	is_completed = false
	_time_accumulator = 0.0
	game_running = true
	print("[GameManager] Game timer started!")

func stop_game_timer(completed: bool = false) -> void:
	game_running = false
	is_completed = completed
	print("[GameManager] Game timer stopped! time=", game_time, "s stars=", star_count, " completed=", is_completed)

# ============================================================
#  CSILLAG GYŰJTÉS - bárhonnan hívható
# ============================================================

func add_star() -> void:
	star_count += 1
	print("[GameManager] Star collected! Total: ", star_count)

# ============================================================
#  FÁJL KEZELÉS - user://user.id
# ============================================================

func save_user_data() -> void:
	var file = FileAccess.open(USER_ID_FILE, FileAccess.WRITE)
	if file:
		var data = {
			"id": user_id,
			"name": user_name,
			"alive": user_alive
		}
		file.store_string(JSON.stringify(data))
		file.close()
		print("[GameManager] User data saved: ", data)

func load_user_data() -> void:
	if not FileAccess.file_exists(USER_ID_FILE):
		print("[GameManager] No saved user data found.")
		return
	var file = FileAccess.open(USER_ID_FILE, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		var json = JSON.new()
		var error = json.parse(content)
		if error == OK:
			var data = json.data
			user_id = int(data.get("id", -1))
			user_name = data.get("name", "")
			user_alive = int(data.get("alive", -1))
			print("[GameManager] User data loaded: ", data)
		else:
			print("[GameManager] Failed to parse user data.")

func has_saved_user() -> bool:
	if user_id == -1 and FileAccess.file_exists(USER_ID_FILE):
		load_user_data()
	return user_id != -1

# ============================================================
#  REGISTER - /CreateUser
# ============================================================

func send_name(player_name: String) -> void:
	var url = "https://squid-app-azgji.ondigitalocean.app/CreateUser"
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify({
		"name": player_name
	})
	current_request = RequestType.REGISTER
	http_request.request(url, headers, HTTPClient.METHOD_POST, body)

# ============================================================
#  GAME OVER - /CreateFullScore
# ============================================================

func send_full_score() -> void:
	if user_id == -1:
		print("[GameManager] No user registered, cannot send score.")
		return
	if user_alive <= 0:
		print("[GameManager] No more lives!")
		return

	var url = "https://squid-app-azgji.ondigitalocean.app/CreateFullScore"
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify({
		"userId": user_id,
		"time": game_time,
		"starcount": star_count,
		"iscompleted": is_completed
	})
	current_request = RequestType.FULL_SCORE
	http_request.request(url, headers, HTTPClient.METHOD_POST, body)
	print("[GameManager] Sending score -> time=", game_time, "s stars=", star_count, " completed=", is_completed)

# ============================================================
#  HTTP RESPONSE KEZELÉS
# ============================================================

func _on_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var body_text = body.get_string_from_utf8()
	print("[GameManager] Response (", response_code, "): ", body_text)

	match current_request:
		RequestType.REGISTER:
			_handle_register_response(response_code, body_text)
		RequestType.FULL_SCORE:
			_handle_full_score_response(response_code, body_text)

	current_request = RequestType.NONE

func _handle_register_response(response_code: int, body_text: String) -> void:
	if response_code != 200:
		print("[GameManager] Register failed: ", response_code)
		return

	var json = JSON.new()
	var error = json.parse(body_text)
	if error != OK:
		print("[GameManager] Failed to parse register response.")
		return

	var data = json.data
	user_id = int(data.get("id", -1))
	user_name = data.get("name", "")
	user_alive = int(data.get("allive", data.get("alive", -1)))

	save_user_data()
	print("[GameManager] Registered! id=", user_id, " name=", user_name, " alive=", user_alive)
	registered.emit()

func _handle_full_score_response(response_code: int, body_text: String) -> void:
	var json = JSON.new()
	var error = json.parse(body_text)
	if error != OK:
		print("[GameManager] Failed to parse score response.")
		return

	var data: Dictionary = json.data

	if response_code == 403:
		user_alive = 0
		save_user_data()
		return

	if response_code != 200:
		return

	if data.has("remainingLives"):
		user_alive = int(data["remainingLives"])
	else:
		user_alive -= 1
	save_user_data()

	score_submitted.emit(data)
	print("[GameManager] Server: ", data.get("message", ""))

# ============================================================
#  TIMELINE
# ============================================================

func timeline() -> void:
	_timeline_run_id += 1
	var run_id := _timeline_run_id

	await get_tree().create_timer(2).timeout
	if run_id != _timeline_run_id:
		return
	start_earthquake.emit()
	await get_tree().create_timer(1).timeout
	if run_id != _timeline_run_id:
		return
	surface_ground_fall.emit()
	await get_tree().create_timer(2).timeout
	if run_id != _timeline_run_id:
		return
	surface_tree_fall.emit()
	await get_tree().create_timer(1).timeout
	if run_id != _timeline_run_id:
		return
	the_hole_start.emit()
	await get_tree().create_timer(12).timeout
	if run_id != _timeline_run_id:
		return
	the_hole_open.emit()

	# >>> ITT INDUL A JÁTÉK TIMER <<<
	start_game_timer()

	await get_tree().create_timer(15).timeout
	if run_id != _timeline_run_id:
		return
	mine_end.emit()

func _reset_runtime_state() -> void:
	_timeline_run_id += 1
	game_running = false
	game_time = 0
	star_count = 0
	is_completed = false
	_time_accumulator = 0.0
	if current_request != RequestType.NONE:
		http_request.cancel_request()
	current_request = RequestType.NONE

func restart() -> void:
	_reset_runtime_state()
	get_tree().call_deferred("reload_current_scene")
