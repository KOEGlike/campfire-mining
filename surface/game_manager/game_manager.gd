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
signal full_score_finished(response_code: int, response: Dictionary)

const USER_ID_FILE = "user://user.id"
const END_SCREEN_SCENE: PackedScene = preload("res://ui/EndScreen.tscn")

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
var last_server_score: int = -1

# Melyik request van folyamatban
enum RequestType {NONE, REGISTER, FULL_SCORE}
var current_request: RequestType = RequestType.NONE
var _register_name_pending: String = ""
var _register_url_candidates: Array[String] = []
var _register_url_index: int = 0

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
		
	if Input.is_action_just_pressed("restart"):
		restart(false)
		
	if Input.is_action_just_pressed("full_reset"):
		delete_user_and_restart()

var _time_accumulator: float = 0.0
var _timeline_run_id: int = 0
var _restart_in_progress: bool = false

func _format_time_breakdown(total_seconds: int) -> String:
	var minutes := total_seconds / 60
	var seconds := total_seconds % 60
	return "%02d:%02d (%dm %ds / %ds)" % [minutes, seconds, minutes, seconds, total_seconds]

func start_game_timer() -> void:
	game_time = 0
	is_completed = false
	_time_accumulator = 0.0
	game_running = true
	print("[GameManager] Run started -> time=", _format_time_breakdown(game_time), " stars=", star_count)

func stop_game_timer(completed: bool = false) -> void:
	game_running = false
	is_completed = completed
	print("[GameManager] Run finished -> time=", _format_time_breakdown(game_time), " stars=", star_count, " completed=", is_completed)

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

func delete_user_and_restart() -> void:
	if FileAccess.file_exists(USER_ID_FILE):
		var remove_error := DirAccess.remove_absolute(USER_ID_FILE)
		if remove_error != OK:
			print("[GameManager] Failed to delete user data file: ", error_string(remove_error), " (", remove_error, ")")
		else:
			print("[GameManager] Deleted saved user data file.")

	user_id = -1
	user_name = ""
	user_alive = -1

	_reset_runtime_state()
	_restart_in_progress = false
	print("[GameManager] User reset complete. Reloading scene...")
	get_tree().call_deferred("reload_current_scene")

# ============================================================
#  REGISTER - /CreateUser
# ============================================================

func send_name(player_name: String) -> void:
	_register_name_pending = player_name
	_register_url_candidates = [
		"https://squid-app-azgji.ondigitalocean.app/CreateUser",
		"https://squid-app-azgji.ondigitalocean.app/createuser"
	]
	_register_url_index = 0
	_send_register_request()

func _send_register_request() -> void:
	if _register_url_index >= _register_url_candidates.size():
		print("[GameManager] Register failed: no endpoints left to try.")
		return

	var url = _register_url_candidates[_register_url_index]
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify({
		"name": _register_name_pending
	})

	current_request = RequestType.REGISTER
	var request_error := http_request.request(url, headers, HTTPClient.METHOD_POST, body)
	if request_error != OK:
		print("[GameManager] Register request start failed (", request_error, "): ", error_string(request_error), " endpoint=", url)
		_register_url_index += 1
		_send_register_request()
		return

	print("[GameManager] Register request sent -> ", url)

# ============================================================
#  GAME OVER - /CreateFullScore
# ============================================================

func send_full_score() -> bool:
	if user_id == -1:
		print("[GameManager] No user registered, cannot send score.")
		return false
	if user_alive <= 0:
		print("[GameManager] No more lives!")
		return false

	var url = "https://squid-app-azgji.ondigitalocean.app/createscore"
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify({
		"userId": user_id,
		"time": game_time,
		"starcount": star_count,
		"iscompleted": is_completed
	})
	current_request = RequestType.FULL_SCORE
	http_request.request(url, headers, HTTPClient.METHOD_POST, body)
	print("[GameManager] Sending score -> time=", _format_time_breakdown(game_time), " stars=", star_count, " completed=", is_completed)
	return true

func show_end_screen(completed: bool, score_to_display: int, score_was_submitted: bool) -> void:
	var end_screen := END_SCREEN_SCENE.instantiate() as EndScreen
	get_tree().root.add_child(end_screen)
	end_screen.setup(completed, score_to_display, user_alive, score_was_submitted)
	await end_screen.closed

# ============================================================
#  HTTP RESPONSE KEZELÉS
# ============================================================

func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var body_text = body.get_string_from_utf8()
	print("[GameManager] Response (result=", result, " code=", response_code, "): ", body_text)

	match current_request:
		RequestType.REGISTER:
			_handle_register_response(result, response_code, body_text)
		RequestType.FULL_SCORE:
			var response_data := _handle_full_score_response(result, response_code, body_text)
			full_score_finished.emit(response_code, response_data)

	current_request = RequestType.NONE

func _extract_response_payload(root: Dictionary) -> Dictionary:
	var payload = root.get("Data", root.get("data", root))
	if payload is Dictionary:
		return payload
	return root

func _handle_register_response(result: int, response_code: int, body_text: String) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		print("[GameManager] Register transport error: ", _http_result_to_text(result), " (", result, ")")
		_register_url_index += 1
		if _register_url_index < _register_url_candidates.size():
			print("[GameManager] Retrying register with fallback endpoint...")
			_send_register_request()
			return
		print("[GameManager] Register failed after all endpoints. Last result=", result)
		return

	if response_code != 200:
		print("[GameManager] Register failed: ", response_code)
		_register_url_index += 1
		if _register_url_index < _register_url_candidates.size():
			print("[GameManager] Retrying register with fallback endpoint...")
			_send_register_request()
		return

	var json = JSON.new()
	var error = json.parse(body_text)
	if error != OK:
		print("[GameManager] Failed to parse register response.")
		return

	var root: Dictionary = json.data
	var data := _extract_response_payload(root)
	user_id = int(data.get("id", -1))
	user_name = str(data.get("name", ""))
	user_alive = int(data.get("allive", data.get("alive", -1)))

	if user_id == -1:
		print("[GameManager] Register response missing valid user id.")
		return

	save_user_data()
	print("[GameManager] Registered! id=", user_id, " name=", user_name, " alive=", user_alive)
	registered.emit()
	_register_name_pending = ""
	_register_url_candidates.clear()
	_register_url_index = 0

func _handle_full_score_response(result: int, response_code: int, body_text: String) -> Dictionary:
	if result != HTTPRequest.RESULT_SUCCESS:
		print("[GameManager] Score submit transport error: ", _http_result_to_text(result), " (", result, ")")
		return {}

	var json = JSON.new()
	var error = json.parse(body_text)
	if error != OK:
		print("[GameManager] Failed to parse score response.")
		return {}

	var root: Dictionary = json.data
	var data := _extract_response_payload(root)

	if response_code == 403:
		user_alive = 0
		save_user_data()
		last_server_score = _extract_server_score(data)
		return data

	if response_code != 200:
		last_server_score = _extract_server_score(data)
		return data

	if data.has("remainingLives"):
		user_alive = int(data["remainingLives"])
	else:
		user_alive -= 1
	last_server_score = _extract_server_score(data)
	save_user_data()

	score_submitted.emit(root)
	print("[GameManager] Server: ", root.get("message", data.get("message", "")))
	return data

func _extract_server_score(data: Dictionary) -> int:
	if data.has("score"):
		return int(data["score"])
	if data.has("yourScore"):
		return int(data["yourScore"])
	return -1

func _http_result_to_text(result: int) -> String:
	match result:
		HTTPRequest.RESULT_SUCCESS:
			return "RESULT_SUCCESS"
		HTTPRequest.RESULT_CHUNKED_BODY_SIZE_MISMATCH:
			return "RESULT_CHUNKED_BODY_SIZE_MISMATCH"
		HTTPRequest.RESULT_CANT_CONNECT:
			return "RESULT_CANT_CONNECT"
		HTTPRequest.RESULT_CANT_RESOLVE:
			return "RESULT_CANT_RESOLVE"
		HTTPRequest.RESULT_CONNECTION_ERROR:
			return "RESULT_CONNECTION_ERROR"
		HTTPRequest.RESULT_TLS_HANDSHAKE_ERROR:
			return "RESULT_TLS_HANDSHAKE_ERROR"
		HTTPRequest.RESULT_NO_RESPONSE:
			return "RESULT_NO_RESPONSE"
		HTTPRequest.RESULT_BODY_SIZE_LIMIT_EXCEEDED:
			return "RESULT_BODY_SIZE_LIMIT_EXCEEDED"
		HTTPRequest.RESULT_BODY_DECOMPRESS_FAILED:
			return "RESULT_BODY_DECOMPRESS_FAILED"
		HTTPRequest.RESULT_REQUEST_FAILED:
			return "RESULT_REQUEST_FAILED"
		HTTPRequest.RESULT_DOWNLOAD_FILE_CANT_OPEN:
			return "RESULT_DOWNLOAD_FILE_CANT_OPEN"
		HTTPRequest.RESULT_DOWNLOAD_FILE_WRITE_ERROR:
			return "RESULT_DOWNLOAD_FILE_WRITE_ERROR"
		HTTPRequest.RESULT_REDIRECT_LIMIT_REACHED:
			return "RESULT_REDIRECT_LIMIT_REACHED"
		HTTPRequest.RESULT_TIMEOUT:
			return "RESULT_TIMEOUT"
		_:
			return "RESULT_UNKNOWN"

# ============================================================
#  TIMELINE
# ============================================================

func timeline() -> void:
	_timeline_run_id += 1
	var run_id := _timeline_run_id
	start_game_timer()

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
	await get_tree().create_timer(2).timeout
	if run_id != _timeline_run_id:
		return
	the_hole_start.emit()
	await get_tree().create_timer(15).timeout
	if run_id != _timeline_run_id:
		return
	the_hole_open.emit()

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
	last_server_score = -1
	_time_accumulator = 0.0
	if current_request != RequestType.NONE:
		http_request.cancel_request()
	current_request = RequestType.NONE

func restart(submit_score: bool = true) -> void:
	if _restart_in_progress:
		return
	_restart_in_progress = true
	print("[GameManager] restart() called submit_score=", submit_score, " game_running=", game_running, " is_completed=", is_completed, " user_id=", user_id, " alive=", user_alive)

	var score_was_submitted := false
	var score_to_display := star_count
	if submit_score and not is_completed:
		if game_running:
			stop_game_timer(false)
		print("[GameManager] restart() death flow: trying score submit before reload")
		var request_started := send_full_score()
		score_was_submitted = request_started
		if request_started:
			await full_score_finished
			if last_server_score >= 0:
				score_to_display = last_server_score
		else:
			print("[GameManager] restart() score submit skipped (missing user or no lives)")

	await show_end_screen(is_completed, score_to_display, score_was_submitted)

	_reset_runtime_state()
	_restart_in_progress = false
	get_tree().call_deferred("reload_current_scene")
