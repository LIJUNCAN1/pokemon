extends Control

class Fighter:
	var sprite: TextureRect
	var charge_frame: Panel
	var charge_fill: ColorRect
	var hp_label: Label
	var hp: int
	var max_hp: int
	var charge := 0.0
	var charge_rate: float
	var player_side: bool
	var alive := true
	var home_position: Vector2
	var base_scale := Vector2.ONE


const PIXEL_FONT: FontFile = preload("res://assets/fonts/ark-pixel-12px-proportional-zh_cn.ttf")
const SCENE_ASSETS := "res://素材/场景/"
const POKEMON := "res://素材/宝可梦图/"
const FALLBACK_TEAM: Array[String] = [
	POKEMON + "1 (5).png", POKEMON + "1 (6).png", POKEMON + "1 (7).png",
	POKEMON + "1 (8).png", POKEMON + "1 (9).png", POKEMON + "1 (10).png",
]
const ENEMY_TEAM: Array[String] = [
	POKEMON + "图层 2.png", POKEMON + "图层 3.png", POKEMON + "图层 4.png",
	POKEMON + "图层 5.png", POKEMON + "图层 6.png", POKEMON + "图层 7.png",
]
const TOP_X_POSITIONS: Array[float] = [230.0, 392.0, 550.0, 730.0, 892.0, 1050.0]
const BOTTOM_X_POSITIONS: Array[float] = [194.0, 356.0, 518.0, 761.0, 923.0, 1085.0]
const ROW_POSITIONS: Array[float] = [335.0, 438.0]

var pixel_font: FontFile
var fighters: Array[Fighter] = []
var rng := RandomNumberGenerator.new()
var battle_over := false
var status_label: Label


func _ready() -> void:
	rng.randomize()
	pixel_font = PIXEL_FONT.duplicate() as FontFile
	pixel_font.antialiasing = TextServer.FONT_ANTIALIASING_NONE
	pixel_font.hinting = TextServer.HINTING_NONE
	pixel_font.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	pixel_font.allow_system_fallback = false
	_build_battlefield()
	_play_transition_in.call_deferred()


func _process(delta: float) -> void:
	if battle_over:
		return
	for fighter in fighters:
		if not fighter.alive:
			continue
		fighter.charge = minf(fighter.charge + delta * fighter.charge_rate, 1.0)
		_update_charge_bar(fighter)
		if fighter.charge >= 1.0:
			fighter.charge = 0.0
			_perform_skill(fighter)


func _build_battlefield() -> void:
	var sky := _add_texture(SCENE_ASSETS + "图层 2.png", Rect2(0, 0, 1280, 220), 0)
	sky.stretch_mode = TextureRect.STRETCH_SCALE

	_add_texture(SCENE_ASSETS + "图层 5.png", Rect2(0, 215, 1280, 405), 1, TextureRect.STRETCH_SCALE)
	_add_texture(SCENE_ASSETS + "图层 3.png", Rect2(0, 82, 1280, 149), 3, TextureRect.STRETCH_SCALE)
	_build_platforms()
	_spawn_teams()
	_add_texture(SCENE_ASSETS + "图层 1.png", Rect2(0, 400, 1280, 315), 20, TextureRect.STRETCH_SCALE)
	_build_hud()


func _build_platforms() -> void:
	for group_x in [170.0, 670.0]:
		_add_texture(SCENE_ASSETS + "图层 6.png", Rect2(group_x, 307, 440, 52), 4, TextureRect.STRETCH_SCALE)
	_add_texture(SCENE_ASSETS + "图层 7.png", Rect2(135, 410, 446, 55), 4, TextureRect.STRETCH_SCALE)
	_add_texture(SCENE_ASSETS + "图层 7.png", Rect2(702, 410, 446, 55), 4, TextureRect.STRETCH_SCALE)


func _spawn_teams() -> void:
	var player_team: Array[String] = GameState.player_team.duplicate()
	if player_team.size() != 6:
		player_team = FALLBACK_TEAM.duplicate()
	for index in 6:
		var row := index / 3
		var column := index % 3
		var row_x_positions := TOP_X_POSITIONS if row == 0 else BOTTOM_X_POSITIONS
		_create_fighter(player_team[index], Vector2(row_x_positions[column], ROW_POSITIONS[row]), true, index)
		_create_fighter(ENEMY_TEAM[index], Vector2(row_x_positions[column + 3], ROW_POSITIONS[row]), false, index)


func _create_fighter(texture_path: String, center: Vector2, player_side: bool, index: int) -> void:
	var fighter := Fighter.new()
	fighter.player_side = player_side
	fighter.max_hp = 72 + index * 7
	fighter.hp = fighter.max_hp
	fighter.charge_rate = rng.randf_range(0.18, 0.29)

	var sprite := TextureRect.new()
	sprite.position = center + Vector2(-38, -66)
	sprite.size = Vector2(76, 78)
	sprite.texture = load(texture_path) as Texture2D
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sprite.pivot_offset = sprite.size * 0.5
	sprite.scale = Vector2.ONE if player_side else Vector2(-1, 1)
	sprite.z_index = 10
	add_child(sprite)
	fighter.sprite = sprite
	fighter.base_scale = sprite.scale
	fighter.home_position = sprite.position

	var charge_frame := Panel.new()
	charge_frame.position = center + Vector2(-54, -56)
	charge_frame.size = Vector2(12, 66)
	charge_frame.z_index = 11
	charge_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	charge_frame.add_theme_stylebox_override("panel", _panel_style(Color(0.04, 0.07, 0.08, 0.9), Color.WHITE, 2))
	add_child(charge_frame)
	fighter.charge_frame = charge_frame

	var charge_fill := ColorRect.new()
	charge_fill.position = Vector2(3, 61)
	charge_fill.size = Vector2(6, 0)
	charge_fill.color = Color.WHITE
	charge_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	charge_frame.add_child(charge_fill)
	fighter.charge_fill = charge_fill

	var hp_color := Color(0.72, 0.94, 1.0) if player_side else Color(1.0, 0.72, 0.72)
	fighter.hp_label = _add_label("%d/%d" % [fighter.hp, fighter.max_hp], Rect2(center.x - 45, center.y + 11, 90, 20), 11, hp_color, HORIZONTAL_ALIGNMENT_CENTER, 12)
	fighters.append(fighter)


func _build_hud() -> void:
	_add_label("第 1 天 · 战斗", Rect2(430, 7, 420, 48), 30, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, 45)
	_add_label("我方", Rect2(14, 270, 120, 28), 17, Color.WHITE, HORIZONTAL_ALIGNMENT_LEFT, 45)
	_add_label("敌方", Rect2(1146, 270, 120, 28), 17, Color.WHITE, HORIZONTAL_ALIGNMENT_RIGHT, 45)
	status_label = _add_label("技能条充满后自动攻击随机目标", Rect2(360, 665, 560, 34), 14, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, 45)
	var exit_button := Button.new()
	exit_button.position = Vector2(1150, 10)
	exit_button.size = Vector2(110, 45)
	exit_button.text = "撤退"
	exit_button.add_theme_font_override("font", pixel_font)
	exit_button.add_theme_font_size_override("font_size", 16)
	exit_button.add_theme_color_override("font_color", Color.WHITE)
	exit_button.add_theme_stylebox_override("normal", _panel_style(Color(0.6, 0.09, 0.18, 0.95), Color.WHITE, 2))
	exit_button.z_index = 45
	exit_button.pressed.connect(_back_to_prep)
	add_child(exit_button)


func _perform_skill(attacker: Fighter) -> void:
	if battle_over or not attacker.alive:
		return
	var targets := _living_fighters(not attacker.player_side)
	if targets.is_empty():
		_finish_battle(attacker.player_side)
		return
	var target: Fighter = targets[rng.randi_range(0, targets.size() - 1)]
	var damage := rng.randi_range(9, 17)
	target.hp = maxi(target.hp - damage, 0)
	target.hp_label.text = "%d/%d" % [target.hp, target.max_hp]
	status_label.text = "%s发动技能，造成 %d 点伤害" % ["我方" if attacker.player_side else "敌方", damage]
	_play_attack_animation(attacker, target, damage)
	if target.hp <= 0:
		_defeat_fighter(target)
	_check_battle_end()


func _play_attack_animation(attacker: Fighter, target: Fighter, damage: int) -> void:
	var attack_tween := create_tween()
	attack_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	attack_tween.tween_property(attacker.sprite, "scale", attacker.base_scale * 1.28, 0.12)
	attack_tween.tween_property(attacker.sprite, "scale", attacker.base_scale, 0.16)

	var hit_tween := create_tween()
	hit_tween.tween_property(target.sprite, "modulate", Color(1.0, 0.25, 0.25), 0.08)
	hit_tween.tween_property(target.sprite, "modulate", Color.WHITE, 0.18)

	var damage_label := _add_label("-%d" % damage, Rect2(target.sprite.position.x, target.sprite.position.y - 10, 76, 28), 18, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, 30)
	var float_tween := create_tween().set_parallel(true)
	float_tween.tween_property(damage_label, "position:y", damage_label.position.y - 28, 0.55)
	float_tween.tween_property(damage_label, "modulate:a", 0.0, 0.55)
	float_tween.chain().tween_callback(damage_label.queue_free)


func _defeat_fighter(fighter: Fighter) -> void:
	fighter.alive = false
	fighter.charge = 0.0
	_update_charge_bar(fighter)
	fighter.charge_frame.modulate = Color(0.35, 0.35, 0.35, 0.55)
	fighter.hp_label.modulate = Color(0.5, 0.5, 0.5, 0.7)
	var fall := create_tween().set_parallel(true)
	fall.tween_property(fighter.sprite, "modulate:a", 0.28, 0.35)
	fall.tween_property(fighter.sprite, "scale", fighter.base_scale * 0.72, 0.35)


func _update_charge_bar(fighter: Fighter) -> void:
	var fill_height := 58.0 * fighter.charge
	fighter.charge_fill.position.y = 61.0 - fill_height
	fighter.charge_fill.size.y = fill_height


func _living_fighters(player_side: bool) -> Array[Fighter]:
	var living: Array[Fighter] = []
	for fighter in fighters:
		if fighter.player_side == player_side and fighter.alive:
			living.append(fighter)
	return living


func _check_battle_end() -> void:
	if _living_fighters(false).is_empty():
		_finish_battle(true)
	elif _living_fighters(true).is_empty():
		_finish_battle(false)


func _finish_battle(player_won: bool) -> void:
	if battle_over:
		return
	battle_over = true
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0, 0, 0, 0.7)
	shade.z_index = 100
	add_child(shade)
	_add_label("胜 利" if player_won else "战斗失败", Rect2(390, 245, 500, 80), 38, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, 110)
	var retry := _create_result_button("重新战斗", Vector2(435, 350))
	retry.pressed.connect(_restart_battle)
	var back := _create_result_button("返回备战", Vector2(655, 350))
	back.pressed.connect(_back_to_prep)


func _create_result_button(text: String, position: Vector2) -> Button:
	var button := Button.new()
	button.position = position
	button.size = Vector2(190, 52)
	button.text = text
	button.add_theme_font_override("font", pixel_font)
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_stylebox_override("normal", _panel_style(Color(0.05, 0.35, 0.45, 1.0), Color.WHITE, 2))
	button.z_index = 110
	add_child(button)
	return button


func _play_transition_in() -> void:
	var curtain := ColorRect.new()
	curtain.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	curtain.color = Color.BLACK
	curtain.z_index = 200
	curtain.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(curtain)
	var reveal := create_tween()
	reveal.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	reveal.tween_interval(0.12)
	reveal.tween_property(curtain, "color:a", 0.0, 0.65)
	reveal.tween_callback(curtain.queue_free)


func _restart_battle() -> void:
	get_tree().reload_current_scene()


func _back_to_prep() -> void:
	get_tree().change_scene_to_file("res://battle_prep.tscn")


func _add_texture(path: String, rect: Rect2, z: int, stretch := TextureRect.STRETCH_KEEP_ASPECT_CENTERED) -> TextureRect:
	var node := TextureRect.new()
	node.position = rect.position
	node.size = rect.size
	node.texture = load(path) as Texture2D
	node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	node.stretch_mode = stretch
	node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.z_index = z
	add_child(node)
	return node


func _add_label(text: String, rect: Rect2, font_size: int, _color: Color, alignment: HorizontalAlignment, z: int) -> Label:
	var label := Label.new()
	label.position = rect.position
	label.size = rect.size
	label.text = text
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", pixel_font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	label.add_theme_constant_override("shadow_offset_x", 1 if font_size <= 18 else 2)
	label.add_theme_constant_override("shadow_offset_y", 1 if font_size <= 18 else 2)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.z_index = z
	add_child(label)
	return label


func _panel_style(fill: Color, border: Color, width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(width)
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_left = 3
	style.corner_radius_bottom_right = 3
	return style
