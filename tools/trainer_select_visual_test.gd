extends Node

const TRAINER_SELECT_SCENE: PackedScene = preload("res://trainer_select.tscn")

var failures := 0


func _ready() -> void:
	var screen := TRAINER_SELECT_SCENE.instantiate()
	add_child(screen)
	await get_tree().process_frame
	await get_tree().process_frame
	var labels: Array[Label] = []
	_find_labels(screen, labels)
	for label in labels:
		_assert(label.get_theme_constant("outline_size") == 0, "trainer labels must not stack an outline over the guide shadow")
		_assert(label.has_theme_color_override("font_shadow_color"), "trainer labels must locally disable inherited shadows")
		_assert(is_zero_approx(label.get_theme_color("font_shadow_color").a), "trainer label shadow colours must be transparent")
	_assert(screen.confirm_button.get_theme_constant("outline_size") == 0, "confirm text must not stack an outline over the guide shadow")
	_assert(screen.confirm_button.has_theme_color_override("font_shadow_color"), "confirm text must locally disable inherited shadows")
	_assert(is_zero_approx(screen.confirm_button.get_theme_color("font_shadow_color").a), "confirm text shadow colour must be transparent")
	_assert(screen.cards.size() == 3, "trainer selection must build three PSD-backed cards")
	for card in screen.cards:
		_assert(card.size == Vector2(339, 465), "trainer cards must use the proportions measured from the supplied reference")
		_assert(card.pivot_offset == card.size * 0.5, "selected trainer scaling must use the card center")
		var clip := card.get_node("PortraitClip") as Control
		_assert(clip.position == Vector2.ZERO and clip.size == card.size, "PSD-authored portrait crops must share the full card coordinate system")
		_assert(clip.clip_contents, "trainer lower bodies must be clipped at the authored inner frame")
		_assert((clip.get_node("Portrait") as TextureRect).position == Vector2.ZERO, "trainer portraits must use the positions recorded in the PSD")
	var group_left: float = screen.cards[0].position.x
	var group_right: float = screen.cards[2].position.x + screen.cards[2].size.x
	_assert(absf((group_left + group_right) * 0.5 - 640.0) <= 1.0, "the three-card group must be centered in the 1280-wide design")
	_assert(not (screen.cards[0].get_meta("selection") as Panel).visible, "selected trainers must use centered zoom instead of a top frame")
	_assert(screen.confirm_button.position == Vector2(468, 632) and screen.confirm_button.size == Vector2(344, 64), "confirm button must match the supplied reference position")
	_assert(screen.confirm_button.has_node("PixelBackground") and screen.confirm_button.has_node("PixelLabel"), "confirm button must reuse the main-menu pixel button visual")
	var pixel_background := screen.confirm_button.get_node("PixelBackground") as TextureRect
	_assert(pixel_background.texture.resource_path.ends_with("button-normal.png"), "confirm button must start with the main-menu normal texture")
	screen.confirm_button.button_down.emit()
	_assert(pixel_background.texture.resource_path.ends_with("button-pressed.png"), "confirm button must use the main-menu pressed texture")
	screen.confirm_button.button_up.emit()
	var passives: Array[RichTextLabel] = []
	_find_rich_labels(screen, passives)
	_assert(passives.size() == 3, "every trainer card must use a value-aware passive label")
	for passive in passives:
		_assert(is_zero_approx(passive.get_theme_color("font_shadow_color").a), "trainer passive text must remain shadow-free")
	_assert("+2" in passives[0].text and "#4f9d69" in passives[0].text.to_lower(), "initial coin value must use the trainer element colour")
	_assert("+6%" in passives[1].text and "#c94e4e" in passives[1].text.to_lower(), "damage value must use the trainer element colour")
	if DisplayServer.get_name() != "headless":
		await get_tree().process_frame
		var error := get_viewport().get_texture().get_image().save_png(ProjectSettings.globalize_path("res://trainer_select_shadow_preview.png"))
		_assert(error == OK, "failed to save trainer shadow preview")
	if failures == 0:
		print("TRAINER_SELECT_VISUAL_TEST: PASS")
	else:
		push_error("TRAINER_SELECT_VISUAL_TEST: %d assertion(s) failed" % failures)
	get_tree().quit(0 if failures == 0 else 1)


func _find_labels(node: Node, result: Array[Label]) -> void:
	for child in node.get_children():
		if child is Label:
			result.append(child)
		_find_labels(child, result)


func _find_rich_labels(node: Node, result: Array[RichTextLabel]) -> void:
	for child in node.get_children():
		if child is RichTextLabel:
			result.append(child)
		_find_rich_labels(child, result)


func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	failures += 1
	push_error("TRAINER_SELECT_VISUAL_TEST: %s" % message)
