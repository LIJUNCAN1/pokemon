extends Control

signal flash_started
signal vs_started

const FONT: FontFile = preload("res://assets/fonts/SourceHanSansSC-Heavy.otf")
const LIGHT_MASK_SHADER: Shader = preload("res://shaders/battle_intro_light_mask.gdshader")
const SOURCE_SIZE := Vector2(1920, 1080)
const VIEWPORT_SCALE := Vector2.ONE / 3.0
const LEFT_PANEL_RECT := Rect2(0, 0, 1154, 1080)
const RIGHT_PANEL_RECT := Rect2(787, 0, 1133, 1080)
const CONTENT_TOP := 165.0
const CONTENT_BOTTOM := 915.0
const CONTENT_HEIGHT := CONTENT_BOTTOM - CONTENT_TOP
const GROUP_START_OFFSET := 960.0
const ASSET_ROOT := "res://assets/ui/battle_intro/"
const TRAINER_IDS: Array[String] = ["researcher", "vanguard", "scout"]
const TRAINER_PORTRAITS := {
	"researcher": ASSET_ROOT + "portrait_researcher.png",
	"vanguard": ASSET_ROOT + "portrait_vanguard.png",
	"scout": ASSET_ROOT + "portrait_scout.png",
}
const TRAINER_NAMES := {
	"researcher": "森野博士",
	"vanguard": "赤城",
	"scout": "紫苑",
}

@export var auto_advance := true

var left_group: Control
var right_group: Control
var left_light_clip: Control
var right_light_clip: Control
var left_portrait_clip: Control
var right_portrait_clip: Control
var left_portrait: TextureRect
var right_portrait: TextureRect
var vs_texture: TextureRect
var top_bar: TextureRect
var bottom_bar: TextureRect
var blue_center_border: TextureRect
var purple_center_border: TextureRect
var left_name_label: Label
var right_name_label: Label
var flash_rect: ColorRect
var light_nodes: Array[TextureRect] = []
var exit_curtains: Array[ColorRect] = []
var intro_tween: Tween
var finishing := false


func _ready() -> void:
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	position = Vector2.ZERO
	size = SOURCE_SIZE
	scale = VIEWPORT_SCALE
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_scene()
	_start_light_motion()
	_play_intro.call_deferred()


func _process(_delta: float) -> void:
	for light in light_nodes:
		if not is_instance_valid(light) or not light.material is ShaderMaterial:
			continue
		var shader_material := light.material as ShaderMaterial
		shader_material.set_shader_parameter("item_position", light.get_parent().position + light.position)


func _unhandled_input(event: InputEvent) -> void:
	if not auto_advance or finishing:
		return
	var should_skip: bool = (
		(event is InputEventKey and event.pressed and not event.echo)
		or (event is InputEventMouseButton and event.pressed)
		or (event is InputEventJoypadButton and event.pressed)
	)
	if should_skip:
		get_viewport().set_input_as_handled()
		_advance_to_battle(true)


func _build_scene() -> void:
	var background := ColorRect.new()
	background.name = "BlackBackground"
	background.position = Vector2.ZERO
	background.size = SOURCE_SIZE
	background.color = Color.BLACK
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.z_index = 0
	add_child(background)
	left_group = _group("LeftCombatantGroup", Vector2(-GROUP_START_OFFSET, 0))
	right_group = _group("RightCombatantGroup", Vector2(GROUP_START_OFFSET, 0))
	_add_texture(left_group, ASSET_ROOT + "blue_background.png", LEFT_PANEL_RECT, 0)
	_add_texture(right_group, ASSET_ROOT + "purple_background.png", RIGHT_PANEL_RECT, 0)

	left_light_clip = _clip("LeftLightClip", left_group, Rect2(LEFT_PANEL_RECT.position.x, CONTENT_TOP, LEFT_PANEL_RECT.size.x, CONTENT_HEIGHT), 4)
	right_light_clip = _clip("RightLightClip", right_group, Rect2(RIGHT_PANEL_RECT.position.x, CONTENT_TOP, RIGHT_PANEL_RECT.size.x, CONTENT_HEIGHT), 4)
	_build_light_copies(left_light_clip, ASSET_ROOT + "blue_light.png", true)
	_build_light_copies(right_light_clip, ASSET_ROOT + "purple_light.png", false)

	left_portrait_clip = _clip("LeftPortraitClip", left_group, Rect2(0, CONTENT_TOP, 1920, CONTENT_HEIGHT), 10)
	right_portrait_clip = _clip("RightPortraitClip", right_group, Rect2(0, CONTENT_TOP, 1920, CONTENT_HEIGHT), 10)
	var player_id := _player_trainer_id()
	var enemy_id := _enemy_trainer_id(player_id)
	left_portrait = _add_scaled_portrait(left_portrait_clip, "LeftPortrait", TRAINER_PORTRAITS[player_id], 146.0, 571.0)
	right_portrait = _add_scaled_portrait(right_portrait_clip, "RightPortrait", TRAINER_PORTRAITS[enemy_id], 1174.0, 652.0)
	left_name_label = _add_name_label(left_group, "LeftTrainerName", TRAINER_NAMES[player_id], Rect2(27, 809, 297, 83))
	right_name_label = _add_name_label(right_group, "RightTrainerName", TRAINER_NAMES[enemy_id], Rect2(1595, 809, 297, 83))

	# The two updated PSD edge layers move with their matching background but
	# remain above every copied light streak.
	blue_center_border = _add_texture(left_group, ASSET_ROOT + "blue_center_border.png", Rect2(782, 0, 372, 1080), 20)
	blue_center_border.name = "BlueCenterBorder"
	purple_center_border = _add_texture(right_group, ASSET_ROOT + "purple_center_border.png", Rect2(787, 0, 371, 1080), 20)
	purple_center_border.name = "PurpleCenterBorder"

	vs_texture = _add_texture(self, ASSET_ROOT + "vs.png", Rect2(780, 422, 354, 249), 40)
	vs_texture.name = "VS"
	vs_texture.pivot_offset = vs_texture.size * 0.5
	vs_texture.scale = Vector2(1.65, 0.08)
	vs_texture.modulate.a = 0.0

	bottom_bar = _add_texture(self, ASSET_ROOT + "bottom_bar.png", Rect2(0, 915, 1920, 165), 50)
	bottom_bar.name = "BottomBlackBar"
	top_bar = _add_texture(self, ASSET_ROOT + "top_bar.png", Rect2(0, 0, 1920, 165), 50)
	top_bar.name = "TopBlackBar"
	flash_rect = ColorRect.new()
	flash_rect.name = "WhiteFlash"
	flash_rect.position = Vector2.ZERO
	flash_rect.size = SOURCE_SIZE
	flash_rect.color = Color(1, 1, 1, 0)
	flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash_rect.z_index = 100
	add_child(flash_rect)


func _build_light_copies(parent: Control, texture_path: String, left_side: bool) -> void:
	var specs := [
		[80.0, 72.0, 380.0, 0.24, 76.0, 1.15],
		[230.0, 232.0, 320.0, 0.32, 92.0, 0.94],
		[390.0, 416.0, 430.0, 0.22, 58.0, 1.28],
		[145.0, 598.0, 360.0, 0.28, 110.0, 1.06],
	]
	for index in specs.size():
		var spec: Array = specs[index]
		var width: float = spec[2]
		var height := width * 114.0 / 613.0
		# Preserve the previous authored on-screen phase after expanding the
		# right rectangular clip from x=960 back to the real panel bound x=787.
		var local_x: float = spec[0] if left_side else spec[0] + 173.0
		var travel: float = spec[4] if left_side else -spec[4]
		var light := _add_texture(parent, texture_path, Rect2(local_x, spec[1], width, height), 0)
		light.name = ("BlueLight%d" if left_side else "PurpleLight%d") % index
		# Sample the authored panel alpha so streaks cannot cross the diagonal
		# divider or either horizontal black bar while moving.
		var light_material := ShaderMaterial.new()
		light_material.shader = LIGHT_MASK_SHADER
		var mask_path := ASSET_ROOT + ("blue_background.png" if left_side else "purple_background.png")
		var mask_origin := Vector2.ZERO if left_side else Vector2(787, 0)
		var mask_texture := load(mask_path) as Texture2D
		light_material.set_shader_parameter("panel_mask", mask_texture)
		light_material.set_shader_parameter("mask_origin", mask_origin)
		light_material.set_shader_parameter("mask_size", mask_texture.get_size())
		light_material.set_shader_parameter("item_position", parent.position + light.position)
		light_material.set_shader_parameter("item_size", light.size)
		light.material = light_material
		light.modulate.a = spec[3] * 1.8
		light.set_meta("moves_right", left_side)
		light.set_meta("motion_speed", absf(travel) / float(spec[5]))
		light_nodes.append(light)


func _start_light_motion() -> void:
	for light in light_nodes:
		var moves_right: bool = light.get_meta("moves_right")
		var speed: float = light.get_meta("motion_speed")
		var parent_clip := light.get_parent() as Control
		var clip_width: float = parent_clip.size.x
		var end_x: float = clip_width + 20.0 if moves_right else -light.size.x - 20.0
		var first_duration := absf(end_x - light.position.x) / speed
		var first_pass := create_tween()
		first_pass.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		first_pass.tween_property(light, "position:x", end_x, first_duration)
		first_pass.tween_callback(_restart_light_pass.bind(light, moves_right, speed))


func _restart_light_pass(light: TextureRect, moves_right: bool, speed: float) -> void:
	if not is_instance_valid(light):
		return
	var parent_clip := light.get_parent() as Control
	var clip_width: float = parent_clip.size.x
	var start_x: float = -light.size.x - 20.0 if moves_right else clip_width + 20.0
	var end_x: float = clip_width + 20.0 if moves_right else -light.size.x - 20.0
	light.position.x = start_x
	var pass_tween := create_tween()
	pass_tween.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	pass_tween.tween_property(light, "position:x", end_x, absf(end_x - start_x) / speed)
	pass_tween.tween_callback(_restart_light_pass.bind(light, moves_right, speed))


func _play_intro() -> void:
	intro_tween = create_tween().set_parallel(true)
	intro_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	intro_tween.tween_property(left_group, "position", Vector2.ZERO, 1.24)
	intro_tween.tween_property(right_group, "position", Vector2.ZERO, 1.24)
	await intro_tween.finished
	if finishing:
		return
	flash_started.emit()
	var flash := create_tween()
	flash.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	flash.tween_property(flash_rect, "color:a", 1.0, 0.07)
	flash.tween_property(flash_rect, "color:a", 0.0, 0.16)
	await flash.finished
	if finishing:
		return
	vs_started.emit()
	var impact := create_tween().set_parallel(true)
	impact.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	impact.tween_property(vs_texture, "scale", Vector2.ONE, 0.32)
	impact.tween_property(vs_texture, "modulate:a", 1.0, 0.12)
	await impact.finished
	if finishing:
		return
	if not auto_advance or finishing:
		return
	await get_tree().create_timer(1.0).timeout
	if not finishing:
		_advance_to_battle(false)


func _advance_to_battle(skipped: bool) -> void:
	if finishing:
		return
	finishing = true
	if is_instance_valid(intro_tween):
		intro_tween.kill()
	await _play_exit_transition(0.12 if skipped else 0.42)
	await SceneManager.change_scene("res://battle.tscn", {"skip_fade_out": true})


func _play_exit_transition(duration: float) -> void:
	var left_curtain := ColorRect.new()
	left_curtain.position = Vector2(-960, 0)
	left_curtain.size = Vector2(960, 1080)
	left_curtain.color = Color.BLACK
	left_curtain.mouse_filter = Control.MOUSE_FILTER_STOP
	left_curtain.z_index = 200
	add_child(left_curtain)
	var right_curtain := ColorRect.new()
	right_curtain.position = Vector2(1920, 0)
	right_curtain.size = Vector2(960, 1080)
	right_curtain.color = Color.BLACK
	right_curtain.mouse_filter = Control.MOUSE_FILTER_STOP
	right_curtain.z_index = 200
	add_child(right_curtain)
	exit_curtains = [left_curtain, right_curtain]
	var close := create_tween().set_parallel(true)
	close.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	close.tween_property(left_curtain, "position:x", 0.0, duration)
	close.tween_property(right_curtain, "position:x", 960.0, duration)
	await close.finished


func _player_trainer_id() -> String:
	return GameState.trainer_id if TRAINER_IDS.has(GameState.trainer_id) else "vanguard"


func _enemy_trainer_id(player_id: String) -> String:
	var player_index := TRAINER_IDS.find(player_id)
	var variation := posmod(GameState.current_map_node + GameState.region, 2)
	return TRAINER_IDS[(player_index + 1 + variation) % TRAINER_IDS.size()]


func _add_scaled_portrait(parent: Control, node_name: String, path: String, x: float, width: float) -> TextureRect:
	var texture := load(path) as Texture2D
	var native_size := texture.get_size()
	var height := width * native_size.y / native_size.x
	var portrait := _add_texture(parent, path, Rect2(x, 188.0 - CONTENT_TOP, width, height), 0)
	portrait.name = node_name
	portrait.set_meta("source_aspect", native_size.x / native_size.y)
	return portrait


func _add_name_label(parent: Control, node_name: String, trainer_name: String, rect: Rect2) -> Label:
	var label := Label.new()
	label.name = node_name
	label.position = rect.position
	label.size = rect.size
	label.text = trainer_name
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", FONT)
	label.add_theme_font_size_override("font_size", 38)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.78))
	label.add_theme_constant_override("shadow_offset_x", 3)
	label.add_theme_constant_override("shadow_offset_y", 3)
	label.add_theme_constant_override("shadow_outline_size", 1)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.z_index = 31
	parent.add_child(label)
	return label


func _group(node_name: String, start_position: Vector2) -> Control:
	var group := Control.new()
	group.name = node_name
	group.position = start_position
	group.size = SOURCE_SIZE
	group.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(group)
	return group


func _clip(node_name: String, parent: Control, rect: Rect2, z_index: int) -> Control:
	var clip := Control.new()
	clip.name = node_name
	clip.position = rect.position
	clip.size = rect.size
	clip.clip_contents = true
	clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip.z_index = z_index
	parent.add_child(clip)
	return clip


func _add_texture(parent: Control, path: String, rect: Rect2, z_index: int) -> TextureRect:
	var texture_rect := TextureRect.new()
	texture_rect.position = rect.position
	texture_rect.size = rect.size
	texture_rect.texture = load(path) as Texture2D
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_rect.z_index = z_index
	parent.add_child(texture_rect)
	return texture_rect
