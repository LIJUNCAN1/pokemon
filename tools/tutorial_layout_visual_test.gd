extends Node

const MAP_SCENE: PackedScene = preload("res://map.tscn")


func _ready() -> void:
	GameState.tutorial_completed = true
	var map := MAP_SCENE.instantiate()
	add_child(map)
	await get_tree().process_frame
	await get_tree().process_frame
	map._show_tutorial()
	await get_tree().process_frame
	_assert(map.tutorial_dialogue_panel.size == Vector2(1000, 166), "tutorial dialogue must use the compact height")
	_assert(map.tutorial_professor_frame.size.y == map.tutorial_dialogue_panel.size.y, "portrait and dialogue must share a row")
	_assert(map.tutorial_professor_frame.get_child(map.tutorial_professor_frame.get_child_count() - 1) is Panel, "portrait frame must render above the portrait")
	await _capture("res://tutorial_layout_step_1.png")
	map._advance_tutorial(map.tutorial_next_button)
	await get_tree().create_timer(0.4).timeout
	_assert(is_equal_approx(map.tutorial_dialogue_panel.position.y, 18.0), "middle map focus must move the dialogue to the top")
	await _capture("res://tutorial_layout_step_2.png")
	map._advance_tutorial(map.tutorial_next_button)
	await get_tree().create_timer(0.4).timeout
	_assert(is_equal_approx(map.tutorial_dialogue_panel.position.y, 18.0), "bottom focus must keep the dialogue above the highlighted area")
	await _capture("res://tutorial_layout_step_3.png")
	map._advance_tutorial(map.tutorial_next_button)
	await get_tree().create_timer(0.4).timeout
	_assert(is_equal_approx(map.tutorial_dialogue_panel.position.y, 536.0), "top focus must move the dialogue below the highlighted area")
	await _capture("res://tutorial_layout_step_4.png")
	print("TUTORIAL_LAYOUT_VISUAL_TEST: PASS")
	get_tree().quit()


func _capture(path: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await get_tree().process_frame
	await get_tree().process_frame
	var error := get_viewport().get_texture().get_image().save_png(ProjectSettings.globalize_path(path))
	_assert(error == OK, "failed to save %s" % path)


func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	push_error("TUTORIAL_LAYOUT_VISUAL_TEST: %s" % message)
	get_tree().quit(1)
