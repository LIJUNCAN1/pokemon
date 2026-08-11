extends Node

const SILENT_DB := -48.0
const DEFAULT_DB := -12.0

var _players: Array[AudioStreamPlayer] = []
var _active_index := -1
var _current_path := ""
var _transition: Tween


func _ready() -> void:
	_ensure_music_bus()
	for index in 2:
		var player := AudioStreamPlayer.new()
		player.name = "MusicLayer%d" % (index + 1)
		player.bus = "Music"
		player.volume_db = SILENT_DB
		add_child(player)
		_players.append(player)


func play_music(path: String, fade_seconds := 1.2, target_db := DEFAULT_DB) -> void:
	if path.is_empty() or not ResourceLoader.exists(path):
		return
	if _current_path == path and _active_index >= 0 and _players[_active_index].playing:
		_fade_active_to(target_db, fade_seconds)
		return
	var next_index := 0 if _active_index != 0 else 1
	var next_player := _players[next_index]
	var stream := load(path) as AudioStream
	if stream == null:
		return
	if stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = true
	next_player.stop()
	next_player.stream = stream
	next_player.volume_db = SILENT_DB
	next_player.play()
	if _transition and _transition.is_valid():
		_transition.kill()
	_transition = create_tween().set_parallel(true)
	_transition.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_transition.tween_property(next_player, "volume_db", target_db, maxf(fade_seconds, 0.05))
	if _active_index >= 0:
		var old_player := _players[_active_index]
		_transition.tween_property(old_player, "volume_db", SILENT_DB, maxf(fade_seconds, 0.05))
		_transition.chain().tween_callback(_stop_if_inactive.bind(old_player, next_player))
	_active_index = next_index
	_current_path = path


func fade_out(fade_seconds := 0.5) -> void:
	if _active_index < 0:
		return
	if _transition and _transition.is_valid():
		_transition.kill()
	var player := _players[_active_index]
	_transition = create_tween()
	_transition.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_transition.tween_property(player, "volume_db", SILENT_DB, maxf(fade_seconds, 0.05))
	_transition.tween_callback(_stop_all)


func current_track() -> String:
	return _current_path


func _fade_active_to(target_db: float, fade_seconds: float) -> void:
	if _transition and _transition.is_valid():
		_transition.kill()
	_transition = create_tween()
	_transition.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_transition.tween_property(_players[_active_index], "volume_db", target_db, maxf(fade_seconds, 0.05))


func _stop_if_inactive(old_player: AudioStreamPlayer, active_player: AudioStreamPlayer) -> void:
	if old_player != active_player:
		old_player.stop()
		old_player.stream = null


func _stop_all() -> void:
	for player in _players:
		player.stop()
		player.stream = null
	_active_index = -1
	_current_path = ""


func _ensure_music_bus() -> void:
	if AudioServer.get_bus_index("Music") >= 0:
		return
	AudioServer.add_bus()
	AudioServer.set_bus_name(AudioServer.bus_count - 1, "Music")
