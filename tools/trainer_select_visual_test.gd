extends Node

const TRAINER_SELECT_SCENE: PackedScene = preload("res://trainer_select.tscn")


func _ready() -> void:
	var screen := TRAINER_SELECT_SCENE.instantiate()
	add_child(screen)
	await get_tree().process_frame
	await get_tree().process_frame
	var labels: Array[Label] = []
	_find_labels(screen, labels)
	for label in labels:
		_assert(label.get_theme_constant("outline_size") == 0, "trainer labels must not stack an outline over the guide shadow")
		_assert(label.get_theme_constant("shadow_offset_x") == 1 and label.get_theme_constant("shadow_offset_y") == 1, "trainer labels must use the guide 1px shadow offset")
	_assert(screen.confirm_button.get_theme_constant("outline_size") == 0, "confirm text must not stack an outline over the guide shadow")
	_assert(screen.confirm_button.get_theme_constant("shadow_offset_x") == 1 and screen.confirm_button.get_theme_constant("shadow_offset_y") == 1, "confirm text must use the guide 1px shadow offset")
	if DisplayServer.get_name() != "headless":
		await get_tree().process_frame
		var error := get_viewport().get_texture().get_image().save_png(ProjectSettings.globalize_path("res://trainer_select_shadow_preview.png"))
		_assert(error == OK, "failed to save trainer shadow preview")
	print("TRAINER_SELECT_VISUAL_TEST: PASS")
	get_tree().quit(0)


func _find_labels(node: Node, result: Array[Label]) -> void:
	for child in node.get_children():
		if child is Label:
			result.append(child)
		_find_labels(child, result)


func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	push_error("TRAINER_SELECT_VISUAL_TEST: %s" % message)
	get_tree().quit(1)
