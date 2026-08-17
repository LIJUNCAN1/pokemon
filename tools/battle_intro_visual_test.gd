extends Node

const INTRO_SCENE: PackedScene = preload("res://battle_intro.tscn")
const INTRO_SCRIPT: Script = preload("res://scripts/battle_intro.gd")

var failed := false


func _ready() -> void:
	GameState.trainer_id = "vanguard"
	GameState.current_map_node = 0
	GameState.region = 1
	var intro := INTRO_SCENE.instantiate()
	intro.auto_advance = false
	add_child(intro)
	await get_tree().process_frame
	_assert(intro.size == intro.SOURCE_SIZE and intro.scale == intro.VIEWPORT_SCALE, "intro must render the 1920x1080 PSD in its native coordinate system")
	var black_background := intro.get_node("BlackBackground") as ColorRect
	_assert(black_background != null and black_background.color == Color.BLACK, "uncovered intro background must remain pure black")
	_assert(intro.left_group.position.x < 0.0 and intro.right_group.position.x > 0.0, "combatant groups must begin one half-screen outside")
	_assert(intro.left_light_clip.clip_contents and intro.right_light_clip.clip_contents, "all moving light copies must be clipped")
	_assert(intro.left_light_clip.position == Vector2(0, intro.CONTENT_TOP) and intro.left_light_clip.size == Vector2(1154, intro.CONTENT_HEIGHT), "left light clip must cover the complete authored blue panel before alpha masking")
	_assert(intro.right_light_clip.position == Vector2(787, intro.CONTENT_TOP) and intro.right_light_clip.size == Vector2(1133, intro.CONTENT_HEIGHT), "right light clip must begin at the authored purple panel bound instead of the old x=960 seam")
	_assert(intro.blue_center_border.z_index > intro.left_light_clip.z_index and intro.purple_center_border.z_index > intro.right_light_clip.z_index, "updated diagonal black edges must cover moving lights")
	_assert(intro.top_bar.z_index > intro.blue_center_border.z_index and intro.bottom_bar.z_index > intro.purple_center_border.z_index, "horizontal black bars must remain the uppermost PSD layers")
	_assert(intro.left_portrait.position.y == 188.0 - intro.CONTENT_TOP and intro.right_portrait.position.y == 188.0 - intro.CONTENT_TOP, "new portraits must retain the authored top alignment")
	_assert(intro.left_portrait.position.y + intro.left_portrait.size.y > intro.left_portrait_clip.size.y, "left portrait excess must be cropped below the content boundary")
	_assert(intro.right_portrait.position.y + intro.right_portrait.size.y > intro.right_portrait_clip.size.y, "right portrait excess must be cropped below the content boundary")
	_assert(intro.left_portrait.texture.resource_path.ends_with("portrait_vanguard.png"), "selected trainer portrait must appear on the left")
	_assert(intro.right_portrait.texture.resource_path != intro.left_portrait.texture.resource_path, "opponent portrait must use a different trainer")
	_assert(intro.left_name_label.position == Vector2(27, 809) and intro.left_name_label.size == Vector2(297, 83), "left trainer name must retain the updated PSD guide bounds")
	_assert(intro.right_name_label.position == Vector2(1595, 809) and intro.right_name_label.size == Vector2(297, 83), "right trainer name must retain the updated PSD guide bounds")
	_assert(intro.left_name_label.text == "赤城" and not intro.right_name_label.text.is_empty(), "trainer names must be written dynamically inside the authored plates")
	_verify_clean_curtain_mask()
	var initial_light_positions: Array[Vector2] = []
	for light in intro.light_nodes:
		initial_light_positions.append(light.position)
	await _capture("res://battle_intro_start.png")
	await get_tree().create_timer(0.55).timeout
	_assert(absf(intro.left_group.position.x) < intro.GROUP_START_OFFSET, "left group must animate toward center")
	_assert(absf(intro.right_group.position.x) < intro.GROUP_START_OFFSET, "right group must animate toward center")
	var light_moved := false
	for index in intro.light_nodes.size():
		var light: TextureRect = intro.light_nodes[index]
		_assert(light.material is ShaderMaterial, "every moving light must use the authored panel alpha as a clipping mask")
		light_moved = light_moved or not light.position.is_equal_approx(initial_light_positions[index])
		if bool(light.get_meta("moves_right")):
			_assert(light.position.x > initial_light_positions[index].x, "blue light streaks must loop from left to right")
		else:
			_assert(light.position.x < initial_light_positions[index].x, "purple light streaks must loop from right to left")
		_assert(light.position.y >= 0.0 and light.position.y + light.size.y <= intro.CONTENT_HEIGHT, "moving lights must stay below the top bar and above the bottom bar")
	_assert(light_moved, "copied light layers must move horizontally")
	await _capture("res://battle_intro_mid.png")
	await intro.flash_started
	await get_tree().create_timer(0.065).timeout
	_assert(intro.flash_rect.color.a > 0.75, "the convergence impact must flash the full screen white")
	await _capture("res://battle_intro_flash.png")
	await intro.vs_started
	await get_tree().create_timer(0.36).timeout
	_assert(intro.left_group.position.is_equal_approx(Vector2.ZERO) and intro.right_group.position.is_equal_approx(Vector2.ZERO), "both groups must finish at authored PSD coordinates")
	_assert(intro.vs_texture.modulate.a > 0.95, "VS must appear after both groups converge")
	await _capture("res://battle_intro_final.png")
	intro._play_exit_transition(0.42)
	await get_tree().create_timer(0.21).timeout
	_assert(intro.exit_curtains.size() == 2, "ending transition must create two closing black curtains")
	_assert(intro.exit_curtains[0].position.x > -960.0 and intro.exit_curtains[1].position.x < 1920.0, "ending curtains must move inward from both sides")
	await _capture("res://battle_intro_exit.png")
	await get_tree().create_timer(0.27).timeout
	_assert(intro.exit_curtains[0].position.x == 0.0 and intro.exit_curtains[1].position.x == 960.0, "ending transition must finish on a fully black screen")
	var reveal_options := SceneManager._get_final_options(INTRO_SCRIPT.BATTLE_REVEAL_TRANSITION)
	SceneManager._set_fully_covered(reveal_options)
	# A real scene swap frees the two authored closing curtains before the
	# persistent SceneManager overlay reveals the battle scene.
	for curtain in intro.exit_curtains:
		curtain.visible = false
	SceneManager.fade_in(INTRO_SCRIPT.BATTLE_REVEAL_TRANSITION)
	await get_tree().create_timer(0.32).timeout
	var overlay := SceneManager.get_node("CanvasLayer/ColorRect") as ColorRect
	var reveal_amount := float((overlay.material as ShaderMaterial).get_shader_parameter("dissolve_amount"))
	_assert(reveal_amount > 0.1 and reveal_amount < 0.9, "clean battle curtains must progress continuously while opening")
	await _capture("res://battle_intro_reveal_mid.png")
	await SceneManager.transition_finished
	if not failed:
		print("BATTLE_INTRO_VISUAL_TEST: PASS")
	get_tree().quit(1 if failed else 0)


func _capture(path: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await get_tree().process_frame
	await get_tree().process_frame
	var image := get_viewport().get_texture().get_image()
	var error := image.save_png(path)
	_assert(error == OK, "failed to save %s" % path)


func _verify_clean_curtain_mask() -> void:
	var texture := SceneManager._load_pattern(INTRO_SCRIPT.BATTLE_REVEAL_TRANSITION["pattern"]) as Texture2D
	_assert(texture != null, "clean VS curtain mask must load as a texture")
	if texture == null:
		return
	var image := texture.get_image()
	var width := image.get_width()
	var height := image.get_height()
	var previous := -1.0
	for x in range(int(width / 2.0) + 1):
		var value := image.get_pixel(x, height / 2).r
		_assert(absf(value - image.get_pixel(x, height / 4).r) < 0.005, "VS curtain mask must not contain vertical pixel noise")
		_assert(value + 0.005 >= previous, "VS curtain mask must progress monotonically toward the center")
		_assert(absf(value - image.get_pixel(width - 1 - x, height / 2).r) < 0.01, "VS curtain mask must remain horizontally symmetric")
		previous = value


func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	failed = true
	push_error("BATTLE_INTRO_VISUAL_TEST: %s" % message)
