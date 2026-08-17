extends Node

const BATTLE_INTRO_SCRIPT = preload("res://scripts/battle_intro.gd")

var failed := false
var expected_scene_name := ""


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	GameState.reset_run()
	GameState.has_started_new_game = true
	GameState.apply_trainer_choice("vanguard")
	_assert(SceneManager.default_options["pattern"] == "diagonal", "ordinary scenes must use the diagonal transition")
	_assert(SceneManager.default_options["pattern"] != BATTLE_INTRO_SCRIPT.BATTLE_REVEAL_TRANSITION["pattern"], "ordinary scenes must not reuse the VS battle curtains")
	_assert(BATTLE_INTRO_SCRIPT.BATTLE_REVEAL_TRANSITION["pattern"] == "clean_curtains", "VS battle reveal must use the clean symmetric curtain mask")
	_assert(BATTLE_INTRO_SCRIPT.BATTLE_REVEAL_TRANSITION["color"] == Color.BLACK, "VS closing curtains and plugin reveal must use the same pure black")
	await _verify_transition("res://trainer_select.tscn", "TrainerSelect")
	await _verify_transition("res://map.tscn", "RunMap")
	if not failed:
		print("SCENE_TRANSITION_TEST: PASS")
	get_tree().quit(1 if failed else 0)


func _verify_transition(path: String, expected_name: String) -> void:
	expected_scene_name = expected_name
	SceneManager.change_scene(path, {"on_ready": _on_target_ready})
	await get_tree().create_timer(0.22).timeout
	var mid_amount := _dissolve_amount()
	_assert(mid_amount > 0.001 and mid_amount < 0.999, "%s fade-out must progress continuously (amount %.3f)" % [expected_name, mid_amount])
	await _capture("res://transition_%s_fade_mid.png" % expected_name.to_snake_case())
	await SceneManager.fade_complete
	await _capture("res://transition_%s_covered.png" % expected_name.to_snake_case())
	await SceneManager.transition_finished
	_assert(get_tree().current_scene != null and get_tree().current_scene.name == expected_name, "%s must become the current scene" % expected_name)
	_assert(_dissolve_amount() < 0.001, "%s fade-in must finish fully transparent" % expected_name)
	await _capture("res://transition_%s_complete.png" % expected_name.to_snake_case())


func _on_target_ready(scene: Node) -> void:
	_assert(scene.name == expected_scene_name, "unexpected scene became ready during transition")
	_assert(_dissolve_amount() > 0.999, "%s scene swap must remain fully covered" % expected_scene_name)


func _dissolve_amount() -> float:
	var overlay := SceneManager.get_node("CanvasLayer/ColorRect") as ColorRect
	return float((overlay.material as ShaderMaterial).get_shader_parameter("dissolve_amount"))


func _capture(path: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await get_tree().process_frame
	await get_tree().process_frame
	var image := get_viewport().get_texture().get_image()
	_assert(image.save_png(path) == OK, "failed to save transition capture %s" % path)


func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	failed = true
	push_error("SCENE_TRANSITION_TEST: %s" % message)
