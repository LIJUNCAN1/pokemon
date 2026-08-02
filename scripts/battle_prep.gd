extends Control

const PIXEL_FONT: FontFile = preload("res://assets/fonts/ark-pixel-12px-proportional-zh_cn.ttf")
const BACKGROUND_SHADER: Shader = preload("res://shaders/battle_prep_background.gdshader")
const UI := "res://素材/主菜单/"
const POKEMON := "res://素材/宝可梦图/"
const CREATURE_TEXTURES: Array[String] = [
	POKEMON + "1 (1).png", POKEMON + "1 (2).png", POKEMON + "1 (3).png",
	POKEMON + "1 (4).png", POKEMON + "1 (5).png", POKEMON + "1 (6).png",
	POKEMON + "1 (7).png", POKEMON + "1 (8).png", POKEMON + "1 (9).png",
	POKEMON + "1 (10).png", POKEMON + "图层 2.png", POKEMON + "图层 3.png",
	POKEMON + "图层 4.png", POKEMON + "图层 5.png", POKEMON + "图层 6.png",
]

var pixel_font: FontFile
var creature_buttons: Array[Button] = []
var creature_sprites: Array[TextureRect] = []
var creature_level_labels: Array[Label] = []
var creature_hp_labels: Array[Label] = []
var creature_special_labels: Array[Label] = []
var creature_masks: Array[ColorRect] = []
var creature_data: Array[String] = []
var selected_slot := -1
var shop_sprites: Array[TextureRect] = []
var shop_hp_labels: Array[Label] = []
var shop_special_labels: Array[Label] = []
var shop_data: Array[String] = []
var notice_label: Label
var coin_label: Label
var lock_label: Label
var coins := 27
var shop_locked := false


func _ready() -> void:
	pixel_font = PIXEL_FONT.duplicate() as FontFile
	pixel_font.antialiasing = TextServer.FONT_ANTIALIASING_NONE
	pixel_font.hinting = TextServer.HINTING_NONE
	pixel_font.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	pixel_font.allow_system_fallback = false
	_build_interface()


func _build_interface() -> void:
	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var material := ShaderMaterial.new()
	material.shader = BACKGROUND_SHADER
	background.material = material
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	_build_top_bar()
	_build_trainer_panel()
	_build_bench()
	_build_team()
	_build_synergy()
	_build_shop()
	_build_footer_actions()
	notice_label = _add_label(self, "选择一个角色，再点击另一个位置即可互换", Rect2(338, 543, 604, 24), 12, Color(0.82, 0.96, 1.0), HORIZONTAL_ALIGNMENT_CENTER)
	_play_transition_in.call_deferred()


func _build_top_bar() -> void:
	var bar := ColorRect.new()
	bar.position = Vector2.ZERO
	bar.size = Vector2(1280, 72)
	bar.color = Color(0.02, 0.43, 0.62, 0.96)
	add_child(bar)
	var stripe := ColorRect.new()
	stripe.position = Vector2(0, 61)
	stripe.size = Vector2(1280, 5)
	stripe.color = Color(0.42, 0.9, 1.0, 0.9)
	bar.add_child(stripe)
	_add_texture(self, UI + "01_切图_1.png", Rect2(12, 5, 58, 58))
	_add_label(self, "3", Rect2(5, 48, 28, 22), 18, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	_add_texture(self, UI + "05_切图_5.png", Rect2(405, 12, 48, 45))
	_add_label(self, "10", Rect2(455, 15, 70, 42), 30, Color.WHITE)
	_add_label(self, "第 1 天", Rect2(525, 7, 230, 54), 38, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	_add_texture(self, UI + "04_切图_4.png", Rect2(765, 12, 47, 47))
	_add_label(self, "1/10", Rect2(816, 15, 110, 42), 28, Color.WHITE)
	_add_icon_button(UI + "02_切图_2.png", Rect2(1138, 6, 56, 56), _on_settings_pressed, "设置")
	_add_icon_button(UI + "03_切图_3.png", Rect2(1207, 5, 58, 58), _on_back_pressed, "返回主菜单")


func _build_trainer_panel() -> void:
	_add_texture(self, UI + "角色框.png", Rect2(8, 82, 244, 394), TextureRect.STRETCH_SCALE)
	_add_label(self, "训练家 · 晴", Rect2(24, 89, 212, 28), 16, Color(0.16, 0.12, 0.08), HORIZONTAL_ALIGNMENT_CENTER)
	_add_texture(self, "res://assets/ui/trainer_avatar_transparent.png", Rect2(35, 128, 190, 190))
	_add_label(self, "+300 最大生命", Rect2(29, 334, 202, 128), 15, Color(0.22, 0.24, 0.3), HORIZONTAL_ALIGNMENT_CENTER)
	_add_texture(self, UI + "11_切图_11.png", Rect2(8, 480, 244, 51), TextureRect.STRETCH_SCALE)
	_add_label(self, "900", Rect2(143, 492, 82, 28), 20, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)


func _build_bench() -> void:
	_add_texture(self, UI + "备战框.png", Rect2(335, 82, 610, 160), TextureRect.STRETCH_SCALE)
	_add_label(self, "备战席", Rect2(350, 88, 120, 26), 15, Color(0.18, 0.12, 0.06))
	var rects := [Rect2(352, 121, 135, 104), Rect2(500, 121, 135, 104), Rect2(648, 121, 135, 104), Rect2(796, 121, 135, 104)]
	for index in rects.size():
		_create_creature_slot(rects[index], CREATURE_TEXTURES[index], "备战 %d" % (index + 1))


func _build_team() -> void:
	_add_texture(self, UI + "10_切图_10.png", Rect2(362, 247, 555, 328), TextureRect.STRETCH_SCALE)
	_add_label(self, "队伍", Rect2(408, 252, 170, 30), 17, Color.WHITE)
	var rects := [
		Rect2(382, 292, 158, 119), Rect2(551, 292, 158, 119), Rect2(720, 292, 158, 119),
		Rect2(382, 425, 158, 119), Rect2(551, 425, 158, 119), Rect2(720, 425, 158, 119),
	]
	for index in rects.size():
		_create_creature_slot(rects[index], CREATURE_TEXTURES[index + 4], "上阵 %d" % (index + 1))


func _build_synergy() -> void:
	_add_texture(self, UI + "羁绊框.png", Rect2(975, 82, 295, 493), TextureRect.STRETCH_SCALE)
	_add_label(self, "羁 绊", Rect2(995, 93, 255, 42), 27, Color(0.95, 0.87, 1.0), HORIZONTAL_ALIGNMENT_CENTER)
	var names: Array[String] = ["火焰", "水流", "自然", "猛兽", "虫群", "精神"]
	var counts: Array[String] = ["2/4", "1/4", "2/4", "3/5", "1/3", "1/3"]
	var icon_paths: Array[String] = [
		"res://assets/ui/synergy_fire.png", UI + "图层 6.png", UI + "图层 7.png",
		UI + "图层 8.png", UI + "图层 3.png", UI + "属性.png",
	]
	var milestones: Array = [["2", "4", "6"], ["1", "4", "6"], ["2", "4", "6"], ["2", "3", "5", "7"], ["1", "3"], ["1", "3"]]
	var active_steps: Array[int] = [0, 0, 0, 1, 0, 0]
	var active_colors: Array[Color] = [
		Color(1.0, 0.66, 0.08), Color(0.38, 0.67, 1.0), Color(0.76, 0.84, 0.12),
		Color(0.76, 0.58, 0.34), Color(0.7, 0.82, 0.08), Color(0.62, 0.46, 0.9),
	]
	for index in names.size():
		var y := 150.0 + index * 68.5
		_add_texture(self, icon_paths[index], Rect2(993, y + 4, 42, 42))
		_add_label(self, names[index], Rect2(1041, y - 1, 125, 29), 18, Color.WHITE)
		_add_label(self, counts[index], Rect2(1181, y - 1, 68, 29), 18, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
		var row_milestones: Array = milestones[index]
		for step_index in row_milestones.size():
			var step_x := 1041.0 + step_index * 34.0
			if step_index == active_steps[index]:
				var active_box := ColorRect.new()
				active_box.position = Vector2(step_x, y + 31)
				active_box.size = Vector2(27, 22)
				active_box.color = active_colors[index]
				active_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
				add_child(active_box)
			_add_label(self, row_milestones[step_index], Rect2(step_x, y + 31, 27, 22), 12, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)


func _build_shop() -> void:
	_add_texture(self, UI + "刷新外框.png", Rect2(270, 620, 770, 95), TextureRect.STRETCH_SCALE)
	shop_data.assign([CREATURE_TEXTURES[10], CREATURE_TEXTURES[11], CREATURE_TEXTURES[12], CREATURE_TEXTURES[13], CREATURE_TEXTURES[14]])
	for index in 5:
		_create_shop_card(index, Rect2(281 + index * 150, 627, 141, 81))
	_add_texture(self, UI + "刷新外框.png", Rect2(272, 573, 310, 39), TextureRect.STRETCH_SCALE)
	_add_texture(self, UI + "06_切图_6.png", Rect2(278, 579, 27, 27))
	_add_label(self, "等级4  1★60%  2★30%  3★10%", Rect2(307, 580, 267, 24), 11, Color(0.19, 0.22, 0.3), HORIZONTAL_ALIGNMENT_CENTER)
	var coin_panel := Panel.new()
	coin_panel.position = Vector2(590, 569)
	coin_panel.size = Vector2(112, 49)
	coin_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	coin_panel.add_theme_stylebox_override("panel", _slot_style(Color(0.86, 0.2, 0.38, 1.0), Color(0.92, 0.93, 0.96), 3))
	add_child(coin_panel)
	coin_label = _add_label(self, "$%d" % coins, Rect2(592, 576, 108, 34), 23, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	_add_icon_button(UI + "14_切图_14.png", Rect2(894, 569, 145, 49), _on_lock_pressed, "锁定商店")
	lock_label = _add_label(self, "", Rect2(896, 574, 140, 28), 10, Color(0.25, 0.2, 0.05), HORIZONTAL_ALIGNMENT_CENTER)


func _build_footer_actions() -> void:
	var reroll := Button.new()
	reroll.position = Vector2(9, 590)
	reroll.size = Vector2(214, 125)
	reroll.flat = false
	reroll.focus_mode = Control.FOCUS_NONE
	reroll.tooltip_text = "刷新商店"
	reroll.add_theme_stylebox_override("normal", _slot_style(Color(0.94, 0.58, 0.03, 1.0), Color(0.96, 0.96, 0.98), 4))
	reroll.add_theme_stylebox_override("hover", _slot_style(Color(1.0, 0.7, 0.08, 1.0), Color(1.0, 0.86, 0.28), 4))
	add_child(reroll)
	reroll.pressed.connect(_on_reroll_pressed)
	_add_label(reroll, "刷新", Rect2(0, 25, 214, 36), 25, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	_add_label(reroll, "$3", Rect2(0, 65, 214, 32), 21, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	var battle := Button.new()
	battle.position = Vector2(1063, 595)
	battle.size = Vector2(208, 120)
	battle.flat = false
	battle.focus_mode = Control.FOCUS_NONE
	battle.tooltip_text = "进入战斗"
	battle.add_theme_stylebox_override("normal", _slot_style(Color(0.83, 0.12, 0.29, 1.0), Color(0.96, 0.96, 0.98), 4))
	battle.add_theme_stylebox_override("hover", _slot_style(Color(0.98, 0.2, 0.39, 1.0), Color(1.0, 0.65, 0.72), 4))
	add_child(battle)
	battle.pressed.connect(_on_battle_pressed)
	_add_label(battle, "战斗！", Rect2(0, 39, 208, 42), 27, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)


func _create_creature_slot(rect: Rect2, texture_path: String, slot_name: String) -> void:
	var button := Button.new()
	button.position = rect.position
	button.size = rect.size
	button.flat = true
	button.focus_mode = Control.FOCUS_NONE
	button.tooltip_text = "点击选择或交换 %s" % slot_name
	button.add_theme_stylebox_override("normal", _slot_style(Color(0, 0, 0, 0), Color(0, 0, 0, 0)))
	button.add_theme_stylebox_override("hover", _slot_style(Color(0.1, 0.65, 0.8, 0.08), Color(0.3, 0.9, 1.0, 0.8), 2))
	add_child(button)
	var sprite := TextureRect.new()
	sprite.position = Vector2(30, 18)
	sprite.size = Vector2(rect.size.x - 60, rect.size.y - 48)
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(sprite)
	var level_label := _add_label(button, "", Rect2(7, 3, 54, 19), 10, Color.WHITE)
	var badge_width := 42.0
	var badge_gap := 4.0
	var badge_x := (rect.size.x - badge_width * 2.0 - badge_gap) * 0.5
	_add_texture(button, UI + "血量.png", Rect2(badge_x, rect.size.y - 27, badge_width, 23), TextureRect.STRETCH_SCALE)
	_add_texture(button, UI + "攻击力 (1).png", Rect2(badge_x + badge_width + badge_gap, rect.size.y - 27, badge_width, 23), TextureRect.STRETCH_SCALE)
	var hp_label := _add_label(button, "", Rect2(badge_x, rect.size.y - 26, badge_width, 20), 10, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	var special_label := _add_label(button, "", Rect2(badge_x + badge_width + badge_gap, rect.size.y - 26, badge_width, 20), 10, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	var replace_mask := ColorRect.new()
	replace_mask.position = Vector2(3, 3)
	replace_mask.size = rect.size - Vector2(6, 6)
	replace_mask.color = Color(0, 0, 0, 0.52)
	replace_mask.mouse_filter = Control.MOUSE_FILTER_IGNORE
	replace_mask.visible = false
	button.add_child(replace_mask)
	creature_buttons.append(button)
	creature_sprites.append(sprite)
	creature_level_labels.append(level_label)
	creature_hp_labels.append(hp_label)
	creature_special_labels.append(special_label)
	creature_masks.append(replace_mask)
	creature_data.append(texture_path)
	var slot_index := creature_buttons.size() - 1
	button.pressed.connect(_on_creature_slot_pressed.bind(slot_index))
	_render_creature_slot(slot_index)


func _create_shop_card(index: int, rect: Rect2) -> void:
	var button := Button.new()
	button.position = rect.position
	button.size = rect.size
	button.flat = true
	button.focus_mode = Control.FOCUS_NONE
	button.tooltip_text = "替换当前选中的角色"
	button.add_theme_stylebox_override("normal", _slot_style(Color(0, 0, 0, 0), Color(0, 0, 0, 0)))
	button.add_theme_stylebox_override("hover", _slot_style(Color(1.0, 0.93, 0.66, 0.16), Color(1.0, 0.75, 0.12), 3))
	add_child(button)
	var card_path := UI + ("刷新框 (4).png" if index == 4 else "刷新框 (3).png")
	_add_texture(button, card_path, Rect2(Vector2.ZERO, rect.size), TextureRect.STRETCH_SCALE)
	if index < 4:
		_add_texture(button, UI + "刷新框 (2).png", Rect2(1, rect.size.y - 24, rect.size.x - 2, 23), TextureRect.STRETCH_SCALE)
	var sprite := TextureRect.new()
	sprite.position = Vector2(26, 5)
	sprite.size = Vector2(rect.size.x - 52, rect.size.y - 29)
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sprite.visible = index < 4
	button.add_child(sprite)
	var hp_label := _add_label(button, "", Rect2(52, 40, 30, 18), 9, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	var special_label := _add_label(button, "", Rect2(85, 40, 30, 18), 9, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	if index < 4:
		_add_texture(button, UI + "血量.png", Rect2(52, 39, 30, 20), TextureRect.STRETCH_SCALE)
		_add_texture(button, UI + "攻击力 (1).png", Rect2(85, 39, 30, 20), TextureRect.STRETCH_SCALE)
		hp_label.move_to_front()
		special_label.move_to_front()
	else:
		hp_label.visible = false
		special_label.visible = false
	_add_label(button, "道具券" if index == 4 else "精灵 %d" % (index + 1), Rect2(5, rect.size.y - 22, 88, 18), 9, Color.WHITE)
	_add_label(button, "$5" if index == 4 else "$3", Rect2(rect.size.x - 42, rect.size.y - 22, 35, 18), 9, Color(1.0, 0.86, 0.25), HORIZONTAL_ALIGNMENT_RIGHT)
	var card_outline := Panel.new()
	card_outline.position = Vector2.ZERO
	card_outline.size = rect.size
	card_outline.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_outline.add_theme_stylebox_override("panel", _slot_style(Color(0, 0, 0, 0), Color(0.66, 0.67, 0.72, 1.0), 3))
	button.add_child(card_outline)
	shop_sprites.append(sprite)
	shop_hp_labels.append(hp_label)
	shop_special_labels.append(special_label)
	button.pressed.connect(_on_shop_card_pressed.bind(index))
	_render_shop_card(index)


func _on_creature_slot_pressed(index: int) -> void:
	if selected_slot < 0:
		selected_slot = index
		_update_selection()
		_set_notice("已选择角色，再点击另一个位置进行交换")
		return
	if selected_slot == index:
		selected_slot = -1
		_update_selection()
		_set_notice("已取消选择")
		return
	var held := creature_data[selected_slot]
	creature_data[selected_slot] = creature_data[index]
	creature_data[index] = held
	_render_creature_slot(selected_slot)
	_render_creature_slot(index)
	selected_slot = -1
	_update_selection()
	_set_notice("角色位置已交换")


func _on_shop_card_pressed(index: int) -> void:
	if index == 4:
		if coins < 5:
			_set_notice("金币不足")
			return
		coins -= 5
		coin_label.text = "$%d" % coins
		_set_notice("道具券已放入背包")
		return
	if selected_slot < 0:
		_set_notice("请先选择一个上阵或备战角色")
		return
	if coins < 3:
		_set_notice("金币不足")
		return
	var old_creature := creature_data[selected_slot]
	creature_data[selected_slot] = shop_data[index]
	shop_data[index] = old_creature
	coins -= 3
	coin_label.text = "$%d" % coins
	_render_creature_slot(selected_slot)
	_render_shop_card(index)
	selected_slot = -1
	_update_selection()
	_set_notice("新角色已替换到选中位置")


func _on_reroll_pressed() -> void:
	if shop_locked:
		_set_notice("商店已锁定，无法刷新")
		return
	if coins < 3:
		_set_notice("金币不足")
		return
	coins -= 3
	coin_label.text = "$%d" % coins
	var first: String = shop_data.pop_front()
	shop_data.append(first)
	for index in shop_sprites.size():
		_render_shop_card(index)
	_set_notice("商店已刷新")


func _on_lock_pressed() -> void:
	shop_locked = not shop_locked
	lock_label.text = "已锁定" if shop_locked else ""
	_set_notice("商店已锁定" if shop_locked else "商店已解锁")


func _on_settings_pressed() -> void:
	_set_notice("设置面板将在下一步接入")


func _play_transition_in() -> void:
	var transition := ColorRect.new()
	transition.z_index = 200
	transition.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	transition.color = Color.BLACK
	transition.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(transition)
	var reveal := create_tween()
	reveal.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	reveal.tween_interval(0.12)
	reveal.tween_property(transition, "color:a", 0.0, 0.65)
	reveal.tween_callback(transition.queue_free)


func _on_battle_pressed() -> void:
	var battle_team: Array[String] = []
	for index in range(4, 10):
		battle_team.append(creature_data[index])
	GameState.set_player_team(battle_team)
	_set_notice("队伍已准备完毕 · 正在进入战斗")
	var transition := ColorRect.new()
	transition.z_index = 200
	transition.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	transition.color = Color(0, 0, 0, 0)
	transition.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(transition)
	var fade_out := create_tween()
	fade_out.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	fade_out.tween_property(transition, "color:a", 1.0, 0.55)
	await fade_out.finished
	get_tree().change_scene_to_file("res://battle.tscn")


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")


func _render_creature_slot(index: int) -> void:
	creature_sprites[index].texture = load(creature_data[index]) as Texture2D
	var data_index := maxi(CREATURE_TEXTURES.find(creature_data[index]), 0)
	creature_level_labels[index].text = "Lv.%d" % (1 + data_index % 3)
	creature_hp_labels[index].text = "%d" % (20 + data_index * 3)
	creature_special_labels[index].text = "%d" % (5 + data_index * 2)


func _render_shop_card(index: int) -> void:
	shop_sprites[index].texture = load(shop_data[index]) as Texture2D
	var data_index := maxi(CREATURE_TEXTURES.find(shop_data[index]), 0)
	shop_hp_labels[index].text = "%d" % (20 + data_index * 3)
	shop_special_labels[index].text = "%d" % (5 + data_index * 2)


func _update_selection() -> void:
	for index in creature_buttons.size():
		var border := Color(1.0, 0.82, 0.18, 1.0) if index == selected_slot else Color(0, 0, 0, 0)
		var fill := Color(1.0, 0.8, 0.12, 0.12) if index == selected_slot else Color(0, 0, 0, 0)
		creature_buttons[index].add_theme_stylebox_override("normal", _slot_style(fill, border, 3))
		creature_masks[index].visible = index == selected_slot


func _set_notice(message: String) -> void:
	if notice_label:
		notice_label.text = message


func _add_texture(parent: Control, path: String, rect: Rect2, stretch := TextureRect.STRETCH_KEEP_ASPECT_CENTERED) -> TextureRect:
	var node := TextureRect.new()
	node.position = rect.position
	node.size = rect.size
	node.texture = load(path) as Texture2D
	node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	node.stretch_mode = stretch
	node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(node)
	return node


func _add_texture_button(path: String, rect: Rect2, tooltip: String) -> TextureButton:
	var button := TextureButton.new()
	button.position = rect.position
	button.size = rect.size
	button.texture_normal = load(path) as Texture2D
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_SCALE
	button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	button.tooltip_text = tooltip
	add_child(button)
	return button


func _add_icon_button(path: String, rect: Rect2, callback: Callable, tooltip: String) -> TextureButton:
	var button := _add_texture_button(path, rect, tooltip)
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	button.pressed.connect(callback)
	return button


func _add_label(parent: Control, text: String, rect: Rect2, font_size: int, _color: Color, alignment := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
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
	var shadow_offset := 1 if font_size <= 18 else 2
	label.add_theme_constant_override("shadow_offset_x", shadow_offset)
	label.add_theme_constant_override("shadow_offset_y", shadow_offset)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label


func _slot_style(fill: Color, border: Color, width := 0) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(width)
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_left = 3
	style.corner_radius_bottom_right = 3
	return style
