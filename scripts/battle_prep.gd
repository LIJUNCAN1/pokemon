extends Control

const SOURCE_HAN_FONT: FontFile = preload("res://assets/fonts/SourceHanSansSC-Heavy.otf")
const STAT_PIXEL_FONT: FontFile = preload("res://assets/fonts/ark-pixel-12px-proportional-zh_cn.ttf")
const CATALOG = preload("res://scripts/creature_catalog.gd")
const BACKGROUND_SHADER: Shader = preload("res://shaders/battle_prep_background.gdshader")
const STAT_BADGE_SHADER: Shader = preload("res://shaders/stat_badge.gdshader")
const DEX_OVERLAY_SCENE: PackedScene = preload("res://dex_overlay.tscn")
const SETTINGS_OVERLAY_SCENE: PackedScene = preload("res://settings_overlay.tscn")
const INVENTORY_POPUP_SCENE: PackedScene = preload("res://inventory_popup.tscn")
const DESIGN_SIZE := Vector2(1280, 720)
const FULL_HD_SCALE := Vector2(1.5, 1.5)
const UI := "res://素材/主菜单/"
const POKEMON := "res://素材/宝可梦图/"
const CREATURE_TEXTURES: Array[String] = [
	POKEMON + "1 (1).png", POKEMON + "1 (2).png", POKEMON + "1 (3).png",
	POKEMON + "1 (4).png", POKEMON + "1 (5).png", POKEMON + "1 (6).png",
	POKEMON + "1 (7).png", POKEMON + "1 (8).png", POKEMON + "1 (9).png",
	POKEMON + "1 (10).png", POKEMON + "图层 2.png", POKEMON + "图层 3.png",
	POKEMON + "图层 4.png", POKEMON + "图层 5.png", POKEMON + "图层 6.png",
]
const ATTRIBUTE_COLORS: Array[Color] = [
	Color("e59a64"), Color("8eb9d1"), Color("a9b85f"),
	Color("b99b78"), Color("aebd57"), Color("aa91c5"),
]
const CREATURE_ATTRIBUTE_INDEX: Array[int] = [2, 3, 5, 3, 5, 1, 2, 1, 3, 0, 2, 4, 5, 2, 0]
const LEVEL_COLORS: Array[Color] = [Color.WHITE, Color("58d66b"), Color("ef4b52")]
const CREATURE_NAMES: Array[String] = [
	"芽叶兽", "钢甲象", "烛灵", "岩甲龟", "夜翼兽", "冰角鹿", "菌盖兽", "深海贤者",
	"绵云羊", "烈焰犬", "花叶兽", "铁壳蛛", "星云兽", "花甲虫", "熔岩蛛",
]
const SHOP_RARITY_POOLS: Array = [
	[0, 1, 2, 3, 4, 5, 6, 7],
	[8, 9, 10, 11],
	[12, 13, 14],
]
const SHOP_ITEM_CHANCE := 0.20
const SHOP_RARITY_NAMES: Array[String] = ["普通", "稀有", "史诗"]
const ITEM_DIRECTORY := "res://assets/items/64x64"
const TRAIT_ICON_PATHS: Dictionary = {
	"火焰": "res://assets/ui/synergy_fire.png",
	"水流": "res://assets/ui/synergy_water.png",
	"自然": UI + "图层 7.png",
	"猛兽": UI + "图层 8.png",
	"虫群": "res://assets/ui/synergy_bug.png",
	"精神": UI + "属性.png",
}

var source_han_font: FontFile
var stat_pixel_font: FontFile
var creature_buttons: Array[Button] = []
var creature_sprites: Array[TextureRect] = []
var creature_level_labels: Array[Label] = []
var creature_hp_labels: Array[Label] = []
var creature_special_labels: Array[Label] = []
var creature_hp_badges: Array[TextureRect] = []
var creature_special_badges: Array[TextureRect] = []
var creature_element_icons: Array[TextureRect] = []
var creature_race_icons: Array[TextureRect] = []
var creature_masks: Array[ColorRect] = []
var creature_selection_frames: Array[TextureRect] = []
var creature_data: Array[String] = []
var creature_levels: Array[int] = []
var selected_slot := -1
var shop_sprites: Array[TextureRect] = []
var shop_hp_labels: Array[Label] = []
var shop_special_labels: Array[Label] = []
var shop_hp_badges: Array[TextureRect] = []
var shop_special_badges: Array[TextureRect] = []
var shop_level_labels: Array[Label] = []
var shop_element_icons: Array[TextureRect] = []
var shop_race_icons: Array[TextureRect] = []
var shop_attribute_layers: Array[TextureRect] = []
var shop_creature_overlays: Array[TextureRect] = []
var shop_outer_layers: Array[TextureRect] = []
var shop_name_labels: Array[Label] = []
var shop_price_labels: Array[Label] = []
var shop_data: Array[Dictionary] = []
var item_rarity_pools: Array = [[], [], []]
var notice_label: Label
var coin_label: Label
var lock_label: Label
var lock_button_texture: TextureRect
var coins := 8
var shop_locked := false
var dex_overlay: Control
var settings_overlay: Control
var inventory_popup: Control
var rng := RandomNumberGenerator.new()
var synergy_count_labels: Dictionary = {}
var synergy_icons: Dictionary = {}
var synergy_name_labels: Dictionary = {}
var synergy_step_boxes: Dictionary = {}
var synergy_step_labels: Dictionary = {}
var synergy_hover_buttons: Dictionary = {}
var synergy_row_positions: Dictionary = {}
var synergy_current_counts: Dictionary = {}
var synergy_tooltip: Panel
var synergy_tooltip_title: Label
var synergy_tooltip_body: Label
var hovered_synergy := ""
var shop_hover_tweens: Dictionary = {}
var idle_wobble_time := 0.0
var selection_pulse_tween: Tween
var card_tooltip: Panel
var card_tooltip_name: Label
var card_tooltip_rarity: Label
var card_tooltip_sprite: TextureRect
var card_tooltip_element_icon: TextureRect
var card_tooltip_element: Label
var card_tooltip_race_icon: TextureRect
var card_tooltip_race: Label
var card_tooltip_cooldown: Label
var card_tooltip_damage: Label
var card_tooltip_extra: Label
var card_tooltip_element_panel: Panel
var card_tooltip_race_panel: Panel
var card_tooltip_info_panel: Panel


func _ready() -> void:
	_apply_full_hd_layout()
	rng.randomize()
	source_han_font = SOURCE_HAN_FONT.duplicate() as FontFile
	source_han_font.antialiasing = TextServer.FONT_ANTIALIASING_GRAY
	source_han_font.hinting = TextServer.HINTING_NORMAL
	source_han_font.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	source_han_font.oversampling = FULL_HD_SCALE.x
	source_han_font.allow_system_fallback = false
	stat_pixel_font = STAT_PIXEL_FONT.duplicate() as FontFile
	stat_pixel_font.antialiasing = TextServer.FONT_ANTIALIASING_NONE
	stat_pixel_font.hinting = TextServer.HINTING_NONE
	stat_pixel_font.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	stat_pixel_font.oversampling = FULL_HD_SCALE.x
	stat_pixel_font.allow_system_fallback = false
	_build_item_pools()
	_build_interface()


func _process(delta: float) -> void:
	idle_wobble_time += delta
	for index in creature_sprites.size():
		var sprite := creature_sprites[index]
		if sprite.texture == null:
			sprite.rotation = 0.0
			continue
		sprite.rotation = sin(idle_wobble_time * 1.35 + index * 0.72) * deg_to_rad(1.35)


func _apply_full_hd_layout() -> void:
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	position = Vector2.ZERO
	size = DESIGN_SIZE
	scale = FULL_HD_SCALE


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
	notice_label = _add_label(self, "选择一个角色，再点击另一个位置即可互换", Rect2(338, 516, 604, 20), 11, Color(0.82, 0.96, 1.0), HORIZONTAL_ALIGNMENT_CENTER)
	_build_card_tooltip()
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
	_add_icon_button(UI + "01_切图_1.png", Rect2(12, 5, 58, 58), _open_dex, "打开图鉴")
	_add_label(self, "3", Rect2(5, 48, 28, 22), 18, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	_add_texture(self, UI + "05_切图_5.png", Rect2(405, 12, 48, 45))
	_add_label(self, "10", Rect2(455, 15, 70, 42), 30, Color.WHITE)
	_add_label(self, "第 1 天", Rect2(525, 7, 230, 54), 38, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	_add_texture(self, UI + "04_切图_4.png", Rect2(765, 12, 47, 47))
	_add_label(self, "1/10", Rect2(816, 15, 110, 42), 28, Color.WHITE)
	_add_static_icon_button("res://assets/ui/collection_book_icon.png", Rect2(1073, 7, 52, 52), _open_inventory, "打开物品栏")
	_add_icon_button(UI + "02_切图_2.png", Rect2(1138, 6, 56, 56), _on_settings_pressed, "设置")
	_add_icon_button(UI + "03_切图_3.png", Rect2(1207, 5, 58, 58), _on_back_pressed, "返回主菜单")


func _build_trainer_panel() -> void:
	_add_texture(self, UI + "角色框.png", Rect2(6, 82, 240, 403), TextureRect.STRETCH_SCALE)
	_add_label(self, "训练家 · 晴", Rect2(18, 89, 216, 28), 16, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	_add_texture(self, "res://assets/ui/trainer_avatar_transparent.png", Rect2(18, 127, 216, 192))
	_add_label(self, "+300 最大生命", Rect2(23, 334, 206, 138), 15, Color(0.22, 0.24, 0.3), HORIZONTAL_ALIGNMENT_CENTER)
	_add_texture(self, UI + "11_切图_11.png", Rect2(6, 494, 240, 42), TextureRect.STRETCH_SCALE)
	_add_label(self, "900", Rect2(139, 501, 84, 28), 20, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)


func _build_bench() -> void:
	_add_texture(self, UI + "备战框.png", Rect2(341, 82, 590, 155), TextureRect.STRETCH_SCALE)
	_add_label(self, "备战席", Rect2(353, 88, 120, 26), 15, Color.WHITE)
	var rects := [Rect2(352, 116, 136, 108), Rect2(498, 116, 136, 108), Rect2(644, 116, 136, 108), Rect2(790, 116, 136, 108)]
	for index in rects.size():
		_create_creature_slot(rects[index], "", "备战 %d" % (index + 1))


func _build_team() -> void:
	_add_texture(self, UI + "10_切图_10.png", Rect2(414, 246, 442, 270), TextureRect.STRETCH_SCALE)
	_add_label(self, "队伍", Rect2(432, 251, 170, 27), 17, Color.WHITE)
	var rects := [
		Rect2(424, 282, 135, 108), Rect2(568, 282, 135, 108), Rect2(712, 282, 135, 108),
		Rect2(424, 398, 135, 108), Rect2(568, 398, 135, 108), Rect2(712, 398, 135, 108),
	]
	for index in rects.size():
		_create_creature_slot(rects[index], "", "上阵 %d" % (index + 1))


func _build_synergy() -> void:
	_add_texture(self, UI + "羁绊框.png", Rect2(979, 82, 272, 433), TextureRect.STRETCH_SCALE)
	_add_label(self, "羁 绊", Rect2(991, 89, 248, 36), 24, Color(0.95, 0.87, 1.0), HORIZONTAL_ALIGNMENT_CENTER)
	var icon_paths: Array[String] = [
		"res://assets/ui/synergy_fire.png", "res://assets/ui/synergy_water.png", UI + "图层 7.png",
		UI + "图层 8.png", "res://assets/ui/synergy_bug.png", UI + "属性.png",
	]
	var active_colors: Array[Color] = [
		Color(1.0, 0.66, 0.08), Color(0.38, 0.67, 1.0), Color(0.76, 0.84, 0.12),
		Color(0.76, 0.58, 0.34), Color(0.7, 0.82, 0.08), Color(0.62, 0.46, 0.9),
	]
	for index in CATALOG.SYNERGY_ORDER.size():
		var synergy: String = CATALOG.SYNERGY_ORDER[index]
		var y := 137.0 + index * 61.0
		var icon := _add_texture(self, icon_paths[index], Rect2(993, y + 4, 40, 40))
		var name_label := _add_label(self, synergy, Rect2(1039, y - 1, 120, 27), 17, Color.WHITE)
		var count_label := _add_label(self, "", Rect2(1167, y - 1, 70, 27), 17, Color("f3a62f"), HORIZONTAL_ALIGNMENT_CENTER)
		synergy_icons[synergy] = icon
		synergy_name_labels[synergy] = name_label
		synergy_count_labels[synergy] = count_label
		var thresholds: Array = CATALOG.THRESHOLDS[synergy]
		var boxes: Array[ColorRect] = []
		var step_labels: Array[Label] = []
		for step_index in thresholds.size():
			var step_x := 1039.0 + step_index * 31.0
			var active_box := ColorRect.new()
			active_box.position = Vector2(step_x, y + 28)
			active_box.size = Vector2(25, 20)
			active_box.color = active_colors[index]
			active_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
			active_box.visible = false
			add_child(active_box)
			boxes.append(active_box)
			var step_label := _add_label(self, "%d" % thresholds[step_index], Rect2(step_x, y + 28, 25, 20), 11, Color("777b83"), HORIZONTAL_ALIGNMENT_CENTER)
			step_labels.append(step_label)
		synergy_step_boxes[synergy] = boxes
		synergy_step_labels[synergy] = step_labels
		var hover := Button.new()
		hover.position = Vector2(986, y - 3)
		hover.size = Vector2(256, 57)
		hover.flat = true
		hover.focus_mode = Control.FOCUS_NONE
		hover.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		hover.mouse_entered.connect(_show_synergy_tooltip.bind(synergy))
		hover.mouse_exited.connect(_hide_synergy_tooltip)
		add_child(hover)
		synergy_hover_buttons[synergy] = hover
	_build_synergy_tooltip()
	_update_synergies()


func _build_synergy_tooltip() -> void:
	synergy_tooltip = Panel.new()
	synergy_tooltip.position = Vector2(742, 142)
	synergy_tooltip.size = Vector2(224, 174)
	synergy_tooltip.z_index = 90
	synergy_tooltip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	synergy_tooltip.add_theme_stylebox_override("panel", _slot_style(Color(0.055, 0.07, 0.10, 0.97), Color(0.93, 0.93, 0.98, 1.0), 2))
	synergy_tooltip.visible = false
	add_child(synergy_tooltip)
	synergy_tooltip_title = _add_label(synergy_tooltip, "", Rect2(12, 8, 200, 30), 17, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	synergy_tooltip_body = _add_label(synergy_tooltip, "", Rect2(14, 38, 196, 124), 11, Color.WHITE)
	synergy_tooltip_body.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	synergy_tooltip_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART


func _show_synergy_tooltip(synergy: String) -> void:
	hovered_synergy = synergy
	var row_y := float(synergy_row_positions.get(synergy, 137.0))
	synergy_tooltip.position.y = clampf(row_y - 8.0, 112.0, 337.0)
	synergy_tooltip_title.text = "%s羁绊" % synergy
	synergy_tooltip_body.text = CATALOG.tooltip_text(synergy, int(synergy_current_counts.get(synergy, 0)))
	synergy_tooltip.visible = true


func _hide_synergy_tooltip() -> void:
	hovered_synergy = ""
	synergy_tooltip.visible = false


func _update_synergies() -> void:
	var active_team: Array[String] = []
	for index in range(4, mini(creature_data.size(), 10)):
		if not creature_data[index].is_empty():
			active_team.append(creature_data[index])
	synergy_current_counts = CATALOG.count_synergies(active_team)
	var visible_row := 0
	for synergy in CATALOG.SYNERGY_ORDER:
		var count := int(synergy_current_counts.get(synergy, 0))
		var row_visible := count > 0
		var row_y := 137.0 + visible_row * 61.0
		var icon: TextureRect = synergy_icons[synergy]
		var name_label: Label = synergy_name_labels[synergy]
		var count_label: Label = synergy_count_labels[synergy]
		var hover: Button = synergy_hover_buttons[synergy]
		icon.visible = row_visible
		name_label.visible = row_visible
		count_label.visible = row_visible
		hover.visible = row_visible
		if row_visible:
			icon.position = Vector2(993, row_y + 4)
			name_label.position = Vector2(1039, row_y - 1)
			count_label.position = Vector2(1167, row_y - 1)
			hover.position = Vector2(986, row_y - 3)
			synergy_row_positions[synergy] = row_y
			visible_row += 1
		var thresholds: Array = CATALOG.THRESHOLDS[synergy]
		count_label.text = "%d/%d" % [count, thresholds[thresholds.size() - 1]]
		var boxes: Array = synergy_step_boxes[synergy]
		var step_labels: Array = synergy_step_labels[synergy]
		for index in boxes.size():
			var step_x := 1039.0 + index * 31.0
			var box := boxes[index] as ColorRect
			var step_label := step_labels[index] as Label
			box.position = Vector2(step_x, row_y + 28)
			step_label.position = Vector2(step_x, row_y + 28)
			box.visible = row_visible and count >= thresholds[index]
			step_label.visible = row_visible
			step_label.add_theme_color_override("font_color", Color.WHITE if count >= thresholds[index] else Color("777b83"))
	if not hovered_synergy.is_empty():
		if int(synergy_current_counts.get(hovered_synergy, 0)) > 0:
			_show_synergy_tooltip(hovered_synergy)
		else:
			_hide_synergy_tooltip()


func _build_shop() -> void:
	_add_texture(self, UI + "刷新外框.png", Rect2(242, 584, 796, 132), TextureRect.STRETCH_SCALE)
	for index in 5:
		var entry := _draw_shop_entry()
		shop_data.append(entry)
		_mark_shop_creature_seen(entry)
	for index in 5:
		_create_shop_card(index, Rect2(251 + index * 155, 592, 146, 116))
	_add_texture(self, UI + "刷新外框.png", Rect2(248, 537, 309, 42), TextureRect.STRETCH_SCALE)
	_add_texture(self, UI + "06_切图_6.png", Rect2(254, 544, 27, 27))
	_add_label(self, "等级4  1★60%  2★30%  3★10%", Rect2(283, 545, 266, 24), 11, Color(0.19, 0.22, 0.3), HORIZONTAL_ALIGNMENT_CENTER)
	var coin_panel := Panel.new()
	coin_panel.position = Vector2(585, 535)
	coin_panel.size = Vector2(108, 47)
	coin_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	coin_panel.add_theme_stylebox_override("panel", _slot_style(Color(0.86, 0.2, 0.38, 1.0), Color(0.92, 0.93, 0.96), 3))
	add_child(coin_panel)
	coin_label = _add_label(self, "$%d" % coins, Rect2(587, 541, 104, 34), 23, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	lock_button_texture = _add_texture(self, "res://assets/ui/lock_button_normal.png", Rect2(910, 537, 119, 44), TextureRect.STRETCH_SCALE)
	var lock_button := Button.new()
	lock_button.position = Vector2(910, 537)
	lock_button.size = Vector2(119, 44)
	lock_button.flat = true
	lock_button.tooltip_text = "锁定商店"
	lock_button.focus_mode = Control.FOCUS_NONE
	add_child(lock_button)
	lock_button.button_down.connect(_set_lock_button_pressed.bind(true))
	lock_button.button_up.connect(_set_lock_button_pressed.bind(false))
	lock_button.mouse_exited.connect(_set_lock_button_pressed.bind(false))
	lock_button.pressed.connect(_on_lock_pressed)
	lock_label = _add_label(self, "锁定", Rect2(912, 543, 115, 28), 15, Color("222026"), HORIZONTAL_ALIGNMENT_CENTER)
	_apply_stat_pixel_font(lock_label)


func _build_footer_actions() -> void:
	var reroll := _add_texture_button(UI + "攻击力 (1).png", Rect2(5, 597, 198, 119), "刷新商店")
	reroll.focus_mode = Control.FOCUS_NONE
	reroll.pressed.connect(_on_reroll_pressed)
	_add_label(reroll, "刷新", Rect2(0, 23, 198, 36), 25, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	_add_label(reroll, "$3", Rect2(0, 62, 198, 32), 21, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	var battle := _add_texture_button(UI + "血量.png", Rect2(1075, 598, 198, 118), "进入战斗")
	battle.focus_mode = Control.FOCUS_NONE
	battle.pressed.connect(_on_battle_pressed)
	_add_label(battle, "战斗！", Rect2(0, 38, 198, 42), 27, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)


func _create_creature_slot(rect: Rect2, texture_path: String, slot_name: String) -> void:
	var button := Button.new()
	button.position = rect.position
	button.size = rect.size
	button.flat = true
	button.focus_mode = Control.FOCUS_NONE
	button.tooltip_text = ""
	button.add_theme_stylebox_override("normal", _slot_style(Color(0, 0, 0, 0), Color(0, 0, 0, 0)))
	button.add_theme_stylebox_override("hover", _slot_style(Color(0.1, 0.65, 0.8, 0.08), Color(0.3, 0.9, 1.0, 0.8), 2))
	add_child(button)
	var sprite := TextureRect.new()
	sprite.position = Vector2(30, 18)
	sprite.size = Vector2(rect.size.x - 60, rect.size.y - 48)
	sprite.pivot_offset = sprite.size * 0.5
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(sprite)
	var level_label := _add_label(button, "", Rect2(7, 3, 54, 19), 10, Color.WHITE)
	var badge_width := 34.0
	var badge_gap := 3.0
	var badge_x := (rect.size.x - badge_width * 2.0 - badge_gap) * 0.5
	var hp_badge := _add_stat_badge(button, Rect2(badge_x, rect.size.y - 27, badge_width, 24), Color("ef3f67"))
	var special_badge := _add_stat_badge(button, Rect2(badge_x + badge_width + badge_gap, rect.size.y - 27, badge_width, 24), Color("3184a4"))
	var hp_label := _add_label(button, "", Rect2(badge_x, rect.size.y - 26, badge_width, 20), 10, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	var special_label := _add_label(button, "", Rect2(badge_x + badge_width + badge_gap, rect.size.y - 26, badge_width, 20), 10, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	_apply_stat_pixel_font(hp_label)
	_apply_stat_pixel_font(special_label)
	var element_icon := _add_texture(button, TRAIT_ICON_PATHS["自然"], Rect2(rect.size.x - 28, 5, 22, 22))
	var race_icon := _add_texture(button, TRAIT_ICON_PATHS["猛兽"], Rect2(rect.size.x - 28, 31, 22, 22))
	element_icon.visible = false
	race_icon.visible = false
	var replace_mask := ColorRect.new()
	replace_mask.position = Vector2(3, 3)
	replace_mask.size = rect.size - Vector2(6, 6)
	replace_mask.color = Color(0, 0, 0, 0.52)
	replace_mask.mouse_filter = Control.MOUSE_FILTER_IGNORE
	replace_mask.visible = false
	button.add_child(replace_mask)
	var selection_frame := _add_texture(button, "res://素材/图鉴/image-1785681904517-raawndjoah.png", Rect2(Vector2.ZERO, rect.size), TextureRect.STRETCH_SCALE)
	selection_frame.pivot_offset = selection_frame.size * 0.5
	selection_frame.visible = false
	creature_buttons.append(button)
	creature_sprites.append(sprite)
	creature_level_labels.append(level_label)
	creature_hp_labels.append(hp_label)
	creature_special_labels.append(special_label)
	creature_hp_badges.append(hp_badge)
	creature_special_badges.append(special_badge)
	creature_element_icons.append(element_icon)
	creature_race_icons.append(race_icon)
	creature_masks.append(replace_mask)
	creature_selection_frames.append(selection_frame)
	creature_data.append(texture_path)
	creature_levels.append(0 if texture_path.is_empty() else 1)
	var slot_index := creature_buttons.size() - 1
	button.pressed.connect(_on_creature_slot_pressed.bind(slot_index))
	button.mouse_entered.connect(_show_creature_card_tooltip.bind(slot_index))
	button.mouse_exited.connect(_hide_card_tooltip)
	_render_creature_slot(slot_index)


func _create_shop_card(index: int, rect: Rect2) -> void:
	var button := Button.new()
	button.position = rect.position
	button.size = rect.size
	button.flat = true
	button.focus_mode = Control.FOCUS_NONE
	button.tooltip_text = ""
	button.add_theme_stylebox_override("normal", _slot_style(Color(0, 0, 0, 0), Color(0, 0, 0, 0)))
	button.add_theme_stylebox_override("hover", _slot_style(Color(1.0, 0.93, 0.66, 0.16), Color(1.0, 0.75, 0.12), 3))
	add_child(button)
	var top_height := 82.0
	var footer_height := rect.size.y - top_height
	var content_layer := _add_texture(button, UI + "图层 3.png", Rect2(4, 4, rect.size.x - 8, top_height - 7), TextureRect.STRETCH_SCALE)
	var creature_overlay := _add_texture(button, UI + "图层 5.png", Rect2(4, 4, rect.size.x - 8, top_height - 7), TextureRect.STRETCH_SCALE)
	_add_texture(button, UI + "图层 4.png", Rect2(4, top_height - 3, rect.size.x - 8, footer_height), TextureRect.STRETCH_SCALE)
	var sprite := TextureRect.new()
	sprite.position = Vector2(22, 4)
	sprite.size = Vector2(rect.size.x - 44, top_height - 9)
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(sprite)
	var element_icon := _add_texture(button, TRAIT_ICON_PATHS["自然"], Rect2(rect.size.x - 26, 8, 19, 19))
	var race_icon := _add_texture(button, TRAIT_ICON_PATHS["猛兽"], Rect2(rect.size.x - 26, 31, 19, 19))
	element_icon.visible = false
	race_icon.visible = false
	var stat_width := 27.0
	var stat_gap := 3.0
	var stat_x := (rect.size.x - stat_width * 2.0 - stat_gap) * 0.5
	var stat_y := top_height - 21.0
	var hp_label := _add_label(button, "", Rect2(stat_x, stat_y, stat_width, 18), 9, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	var special_label := _add_label(button, "", Rect2(stat_x + stat_width + stat_gap, stat_y, stat_width, 18), 9, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	var hp_badge := _add_stat_badge(button, Rect2(stat_x, stat_y - 1, stat_width, 21), Color("ef3f67"))
	var special_badge := _add_stat_badge(button, Rect2(stat_x + stat_width + stat_gap, stat_y - 1, stat_width, 21), Color("3184a4"))
	hp_label.move_to_front()
	special_label.move_to_front()
	_apply_stat_pixel_font(hp_label)
	_apply_stat_pixel_font(special_label)
	var name_label := _add_label(button, "", Rect2(5, top_height + 5, 96, 22), 9, Color.WHITE)
	var price_label := _add_label(button, "", Rect2(rect.size.x - 42, top_height + 5, 35, 22), 9, Color(1.0, 0.86, 0.25), HORIZONTAL_ALIGNMENT_RIGHT)
	var card_outline := Panel.new()
	card_outline.position = Vector2.ZERO
	card_outline.size = rect.size
	card_outline.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_outline.add_theme_stylebox_override("panel", _slot_style(Color(0, 0, 0, 0), Color(0.66, 0.67, 0.72, 1.0), 3))
	button.add_child(card_outline)
	var outer_layer := _add_texture(button, UI + "图层 6 拷贝.png", Rect2(Vector2.ZERO, rect.size), TextureRect.STRETCH_SCALE)
	outer_layer.move_to_front()
	var shop_level := _add_label(button, "Lv.1", Rect2(8, 5, 48, 18), 9, Color.WHITE)
	shop_level.visible = false
	shop_level.add_theme_color_override("font_color", LEVEL_COLORS[0])
	shop_sprites.append(sprite)
	shop_hp_labels.append(hp_label)
	shop_special_labels.append(special_label)
	shop_hp_badges.append(hp_badge)
	shop_special_badges.append(special_badge)
	shop_level_labels.append(shop_level)
	shop_element_icons.append(element_icon)
	shop_race_icons.append(race_icon)
	shop_attribute_layers.append(content_layer)
	shop_creature_overlays.append(creature_overlay)
	shop_outer_layers.append(outer_layer)
	shop_name_labels.append(name_label)
	shop_price_labels.append(price_label)
	button.pressed.connect(_on_shop_card_pressed.bind(index))
	button.mouse_entered.connect(_shake_shop_card.bind(button))
	button.mouse_entered.connect(_show_shop_card_tooltip.bind(index))
	button.mouse_exited.connect(_hide_card_tooltip)
	_render_shop_card(index)


func _build_card_tooltip() -> void:
	card_tooltip = Panel.new()
	card_tooltip.size = Vector2(292, 315)
	card_tooltip.z_index = 180
	card_tooltip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_tooltip.add_theme_stylebox_override("panel", _slot_style(Color(0.97, 0.97, 0.98, 0.99), Color(0.18, 0.2, 0.24, 1.0), 4))
	card_tooltip.visible = false
	add_child(card_tooltip)
	var header := ColorRect.new()
	header.position = Vector2(8, 8)
	header.size = Vector2(276, 38)
	header.color = Color(0.43, 0.43, 0.48, 1.0)
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_tooltip.add_child(header)
	card_tooltip_name = _add_label(card_tooltip, "", Rect2(18, 8, 165, 38), 19, Color.WHITE)
	card_tooltip_rarity = _add_label(card_tooltip, "", Rect2(180, 8, 94, 38), 16, Color.WHITE, HORIZONTAL_ALIGNMENT_RIGHT)
	var portrait_panel := Panel.new()
	portrait_panel.position = Vector2(16, 58)
	portrait_panel.size = Vector2(128, 128)
	portrait_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait_panel.add_theme_stylebox_override("panel", _slot_style(Color(0.99, 0.99, 1.0, 1.0), Color(0.68, 0.69, 0.74, 1.0), 3))
	card_tooltip.add_child(portrait_panel)
	card_tooltip_sprite = _add_texture(portrait_panel, CREATURE_TEXTURES[0], Rect2(12, 12, 104, 104))
	card_tooltip_element_panel = Panel.new()
	card_tooltip_element_panel.position = Vector2(158, 70)
	card_tooltip_element_panel.size = Vector2(116, 44)
	card_tooltip_element_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_tooltip_element_panel.add_theme_stylebox_override("panel", _slot_style(Color("9eaa38"), Color(0.58, 0.61, 0.22), 1))
	card_tooltip.add_child(card_tooltip_element_panel)
	card_tooltip_element_icon = _add_texture(card_tooltip_element_panel, TRAIT_ICON_PATHS["自然"], Rect2(9, 7, 30, 30))
	card_tooltip_element = _add_label(card_tooltip_element_panel, "", Rect2(42, 4, 66, 36), 14, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	card_tooltip_race_panel = Panel.new()
	card_tooltip_race_panel.position = Vector2(158, 127)
	card_tooltip_race_panel.size = Vector2(116, 44)
	card_tooltip_race_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_tooltip_race_panel.add_theme_stylebox_override("panel", _slot_style(Color("8eafe0"), Color(0.53, 0.64, 0.82), 1))
	card_tooltip.add_child(card_tooltip_race_panel)
	card_tooltip_race_icon = _add_texture(card_tooltip_race_panel, TRAIT_ICON_PATHS["猛兽"], Rect2(9, 7, 30, 30))
	card_tooltip_race = _add_label(card_tooltip_race_panel, "", Rect2(42, 4, 66, 36), 14, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	card_tooltip_info_panel = Panel.new()
	card_tooltip_info_panel.position = Vector2(16, 199)
	card_tooltip_info_panel.size = Vector2(258, 100)
	card_tooltip_info_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_tooltip_info_panel.add_theme_stylebox_override("panel", _slot_style(Color(0.99, 0.99, 1.0, 1.0), Color(0.68, 0.69, 0.74, 1.0), 3))
	card_tooltip.add_child(card_tooltip_info_panel)
	card_tooltip_cooldown = _add_label(card_tooltip_info_panel, "", Rect2(12, 7, 78, 53), 17, Color("252631"), HORIZONTAL_ALIGNMENT_CENTER)
	card_tooltip_damage = _add_label(card_tooltip_info_panel, "", Rect2(93, 7, 153, 32), 15, Color("ef3f64"))
	card_tooltip_extra = _add_label(card_tooltip_info_panel, "", Rect2(93, 39, 153, 47), 13, Color("5579b9"))
	card_tooltip_extra.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART


func _show_creature_card_tooltip(index: int) -> void:
	if index < 0 or index >= creature_data.size() or creature_data[index].is_empty():
		_hide_card_tooltip()
		return
	_show_card_tooltip(creature_data[index], creature_levels[index])


func _show_shop_card_tooltip(index: int) -> void:
	if index < 0 or index >= shop_data.size() or shop_data[index].is_empty():
		_hide_card_tooltip()
		return
	var entry: Dictionary = shop_data[index]
	if entry["kind"] == "item":
		_show_item_card_tooltip(entry)
	else:
		_show_card_tooltip(entry["path"], 1)


func _show_card_tooltip(texture_path: String, level: int) -> void:
	var data_index := maxi(CREATURE_TEXTURES.find(texture_path), 0)
	var traits: PackedStringArray = CATALOG.traits_for_texture(texture_path)
	var rarity_index := 0
	for pool_index in SHOP_RARITY_POOLS.size():
		if data_index in SHOP_RARITY_POOLS[pool_index]:
			rarity_index = pool_index
			break
	card_tooltip_element_panel.visible = true
	card_tooltip_race_panel.visible = true
	card_tooltip_name.text = CREATURE_NAMES[data_index]
	card_tooltip_rarity.text = SHOP_RARITY_NAMES[rarity_index]
	card_tooltip_sprite.texture = load(texture_path) as Texture2D
	card_tooltip_element_icon.texture = load(TRAIT_ICON_PATHS[traits[0]]) as Texture2D
	card_tooltip_element.text = traits[0]
	card_tooltip_race_icon.texture = load(TRAIT_ICON_PATHS[traits[1]]) as Texture2D
	card_tooltip_race.text = traits[1]
	var cooldown := 3.0 + float(data_index % 5) * 0.5
	var damage := (15 + data_index * 2) * maxi(level, 1)
	card_tooltip_cooldown.text = "%.1f\n秒" % cooldown
	card_tooltip_damage.text = "造成 %d 点伤害" % damage
	card_tooltip_extra.text = _creature_extra_text(traits, rarity_index)
	_position_card_tooltip()


func _show_item_card_tooltip(entry: Dictionary) -> void:
	card_tooltip_element_panel.visible = false
	card_tooltip_race_panel.visible = false
	card_tooltip_name.text = _shop_entry_name(entry)
	card_tooltip_rarity.text = SHOP_RARITY_NAMES[int(entry["rarity"])]
	card_tooltip_sprite.texture = load(entry["path"]) as Texture2D
	card_tooltip_cooldown.text = "道具"
	card_tooltip_damage.text = "售价 $%d" % int(entry["price"])
	card_tooltip_extra.text = "购买后放入背包\n可在后续系统中使用"
	_position_card_tooltip()


func _position_card_tooltip() -> void:
	var mouse := get_local_mouse_position()
	var desired := Vector2(mouse.x - card_tooltip.size.x * 0.5, mouse.y + 18.0)
	if desired.y + card_tooltip.size.y > DESIGN_SIZE.y - 8:
		desired.y = mouse.y - card_tooltip.size.y - 18
	card_tooltip.position = Vector2(clampf(desired.x, 8.0, DESIGN_SIZE.x - card_tooltip.size.x - 8.0), clampf(desired.y, 8.0, DESIGN_SIZE.y - card_tooltip.size.y - 8.0))
	card_tooltip.visible = true
	card_tooltip.move_to_front()


func _creature_extra_text(traits: PackedStringArray, rarity_index: int) -> String:
	var releases := 1 + rarity_index
	match traits[1]:
		"猛兽": return "多重释放：%d\n受到伤害降低" % releases
		"虫群": return "多重释放：%d\n技能充能加快" % releases
		_: return "多重释放：%d\n施法后恢复生命" % releases


func _hide_card_tooltip() -> void:
	if card_tooltip:
		card_tooltip.visible = false


func _shake_shop_card(card: Button) -> void:
	var key := card.get_instance_id()
	if shop_hover_tweens.has(key):
		var previous: Tween = shop_hover_tweens[key]
		if previous and previous.is_valid():
			previous.kill()
	card.pivot_offset = card.size * 0.5
	card.rotation = 0.0
	var shake := create_tween()
	shop_hover_tweens[key] = shake
	shake.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	shake.tween_property(card, "rotation", deg_to_rad(-1.8), 0.045)
	shake.tween_property(card, "rotation", deg_to_rad(1.8), 0.07)
	shake.tween_property(card, "rotation", deg_to_rad(-1.0), 0.055)
	shake.tween_property(card, "rotation", 0.0, 0.05)


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
	var held_level := creature_levels[selected_slot]
	creature_data[selected_slot] = creature_data[index]
	creature_levels[selected_slot] = creature_levels[index]
	creature_data[index] = held
	creature_levels[index] = held_level
	_render_creature_slot(selected_slot)
	_render_creature_slot(index)
	_update_synergies()
	selected_slot = -1
	_update_selection()
	_set_notice("角色位置已交换")


func _on_shop_card_pressed(index: int) -> void:
	if shop_data[index].is_empty():
		_set_notice("该商品已售出")
		return
	var entry: Dictionary = shop_data[index]
	var price := int(entry["price"])
	if coins < price:
		_set_notice("金币不足")
		return
	if entry["kind"] == "item":
		coins -= price
		coin_label.text = "$%d" % coins
		GameState.add_item(entry["path"])
		shop_data[index] = {}
		_render_shop_card(index)
		_hide_card_tooltip()
		_set_notice("%s已放入背包" % _shop_entry_name(entry))
		return
	var target_slot := -1
	for slot_index in range(4, 10):
		if creature_data[slot_index].is_empty():
			target_slot = slot_index
			break
	if target_slot < 0:
		for slot_index in range(0, 4):
			if creature_data[slot_index].is_empty():
				target_slot = slot_index
				break
	if target_slot < 0:
		_set_notice("队伍和备战席都已满")
		return
	creature_data[target_slot] = entry["path"]
	creature_levels[target_slot] = 1
	shop_data[index] = {}
	coins -= price
	coin_label.text = "$%d" % coins
	_render_creature_slot(target_slot)
	_render_shop_card(index)
	GameState.mark_creature_seen(creature_data[target_slot])
	GameState.unlock_creature_achievement(creature_data[target_slot], GameState.ACHIEVEMENT_TROPHY)
	_update_synergies()
	selected_slot = -1
	_update_selection()
	_hide_card_tooltip()
	_set_notice("角色已加入%s" % ("队伍" if target_slot >= 4 else "备战席"))


func _on_reroll_pressed() -> void:
	if shop_locked:
		_set_notice("商店已锁定，无法刷新")
		return
	if coins < 3:
		_set_notice("金币不足")
		return
	coins -= 3
	coin_label.text = "$%d" % coins
	for index in 5:
		shop_data[index] = _draw_shop_entry()
		_mark_shop_creature_seen(shop_data[index])
	for index in shop_sprites.size():
		_render_shop_card(index)
	_set_notice("商店已刷新")


func _build_item_pools() -> void:
	for file_name in DirAccess.get_files_at(ITEM_DIRECTORY):
		if not file_name.ends_with(".png"):
			continue
		var item_number := file_name.get_basename().trim_prefix("fc").to_int()
		var rarity_digit := posmod(item_number, 10)
		var rarity_index := 0 if rarity_digit < 6 else (1 if rarity_digit < 9 else 2)
		item_rarity_pools[rarity_index].append("%s/%s" % [ITEM_DIRECTORY, file_name])


func _roll_shop_rarity() -> int:
	var roll := rng.randf()
	if roll >= 0.9:
		return 2
	if roll >= 0.6:
		return 1
	return 0


func _draw_shop_entry() -> Dictionary:
	var rarity_index := _roll_shop_rarity()
	if rng.randf() < SHOP_ITEM_CHANCE and not item_rarity_pools[rarity_index].is_empty():
		var item_pool: Array = item_rarity_pools[rarity_index]
		return {
			"kind": "item",
			"path": item_pool[rng.randi_range(0, item_pool.size() - 1)],
			"rarity": rarity_index,
			"price": 5,
		}
	var pool: Array = SHOP_RARITY_POOLS[rarity_index]
	var creature_index: int = pool[rng.randi_range(0, pool.size() - 1)]
	return {
		"kind": "creature",
		"path": CREATURE_TEXTURES[creature_index],
		"rarity": rarity_index,
		"price": 3,
	}


func _mark_shop_creature_seen(entry: Dictionary) -> void:
	if not entry.is_empty() and entry["kind"] == "creature":
		GameState.mark_creature_seen(entry["path"])


func _shop_entry_name(entry: Dictionary) -> String:
	if entry["kind"] == "creature":
		var creature_index := CREATURE_TEXTURES.find(entry["path"])
		return CREATURE_NAMES[maxi(creature_index, 0)]
	return "道具 %s" % String(entry["path"]).get_file().get_basename().trim_prefix("fc")


func _on_lock_pressed() -> void:
	shop_locked = not shop_locked
	lock_label.text = "已锁定" if shop_locked else "锁定"
	_set_notice("商店已锁定" if shop_locked else "商店已解锁")


func _set_lock_button_pressed(pressed: bool) -> void:
	if lock_button_texture:
		lock_button_texture.texture = load("res://assets/ui/lock_button_pressed.png" if pressed else "res://assets/ui/lock_button_normal.png") as Texture2D


func _on_settings_pressed() -> void:
	if not is_instance_valid(settings_overlay):
		settings_overlay = SETTINGS_OVERLAY_SCENE.instantiate() as Control
		add_child(settings_overlay)
	else:
		settings_overlay.move_to_front()


func _open_dex() -> void:
	if not is_instance_valid(dex_overlay):
		dex_overlay = DEX_OVERLAY_SCENE.instantiate() as Control
		add_child(dex_overlay)
	else:
		dex_overlay.visible = true
		dex_overlay.move_to_front()
	if dex_overlay.has_method("refresh_data"):
		dex_overlay.call("refresh_data")


func _open_inventory() -> void:
	if not is_instance_valid(inventory_popup):
		inventory_popup = INVENTORY_POPUP_SCENE.instantiate() as Control
		add_child(inventory_popup)
	else:
		inventory_popup.move_to_front()
		if inventory_popup.has_method("refresh_items"):
			inventory_popup.call("refresh_items")


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
		if not creature_data[index].is_empty():
			battle_team.append(creature_data[index])
	if battle_team.is_empty():
		_set_notice("队伍为空，请先购买并放置至少一个角色")
		return
	for texture_path in battle_team:
		GameState.unlock_creature_achievement(texture_path, GameState.ACHIEVEMENT_MEDAL)
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
	if creature_data[index].is_empty():
		creature_sprites[index].texture = null
		creature_hp_badges[index].visible = false
		creature_special_badges[index].visible = false
		creature_level_labels[index].text = ""
		creature_hp_labels[index].text = ""
		creature_special_labels[index].text = ""
		creature_element_icons[index].visible = false
		creature_race_icons[index].visible = false
		return
	creature_hp_badges[index].visible = true
	creature_special_badges[index].visible = true
	creature_sprites[index].texture = load(creature_data[index]) as Texture2D
	var data_index := maxi(CREATURE_TEXTURES.find(creature_data[index]), 0)
	var level := clampi(creature_levels[index], 1, 3)
	creature_level_labels[index].text = "Lv.%d" % level
	creature_level_labels[index].add_theme_color_override("font_color", LEVEL_COLORS[level - 1])
	creature_hp_labels[index].text = "%d" % (20 + data_index * 3)
	creature_special_labels[index].text = "%d" % (5 + data_index * 2)
	_set_stat_badge_value(creature_hp_badges[index], 20 + data_index * 3, true)
	_set_stat_badge_value(creature_special_badges[index], 5 + data_index * 2, false)
	var traits: PackedStringArray = CATALOG.traits_for_texture(creature_data[index])
	creature_element_icons[index].texture = load(TRAIT_ICON_PATHS[traits[0]]) as Texture2D
	creature_race_icons[index].texture = load(TRAIT_ICON_PATHS[traits[1]]) as Texture2D
	creature_element_icons[index].visible = true
	creature_race_icons[index].visible = true


func _render_shop_card(index: int) -> void:
	if shop_data[index].is_empty():
		shop_sprites[index].texture = null
		shop_sprites[index].visible = false
		shop_hp_badges[index].visible = false
		shop_special_badges[index].visible = false
		shop_level_labels[index].visible = false
		shop_element_icons[index].visible = false
		shop_race_icons[index].visible = false
		shop_hp_labels[index].text = ""
		shop_special_labels[index].text = ""
		shop_name_labels[index].text = "已售出"
		shop_price_labels[index].text = ""
		return
	var entry: Dictionary = shop_data[index]
	var is_creature := entry["kind"] == "creature"
	var texture_path: String = entry["path"]
	shop_sprites[index].texture = load(texture_path) as Texture2D
	shop_sprites[index].visible = true
	shop_name_labels[index].text = _shop_entry_name(entry)
	shop_price_labels[index].text = "$%d" % int(entry["price"])
	shop_creature_overlays[index].visible = is_creature
	var content_path := UI + "图层 3.png" if is_creature else "res://assets/ui/shop_item_upper.png"
	shop_attribute_layers[index].texture = load(content_path) as Texture2D
	shop_outer_layers[index].texture = load(UI + ("图层 6 拷贝.png" if is_creature else "图层 6.png")) as Texture2D
	shop_hp_badges[index].visible = is_creature
	shop_special_badges[index].visible = is_creature
	shop_level_labels[index].visible = is_creature
	shop_hp_labels[index].visible = is_creature
	shop_special_labels[index].visible = is_creature
	shop_element_icons[index].visible = false
	shop_race_icons[index].visible = false
	if not is_creature:
		shop_attribute_layers[index].modulate = Color.WHITE
		shop_hp_labels[index].text = ""
		shop_special_labels[index].text = ""
		return
	var data_index := maxi(CREATURE_TEXTURES.find(texture_path), 0)
	shop_attribute_layers[index].modulate = ATTRIBUTE_COLORS[CREATURE_ATTRIBUTE_INDEX[data_index]]
	shop_hp_labels[index].text = "%d" % (20 + data_index * 3)
	shop_special_labels[index].text = "%d" % (5 + data_index * 2)
	_set_stat_badge_value(shop_hp_badges[index], 20 + data_index * 3, true)
	_set_stat_badge_value(shop_special_badges[index], 5 + data_index * 2, false)
	var traits: PackedStringArray = CATALOG.traits_for_texture(texture_path)
	shop_element_icons[index].texture = load(TRAIT_ICON_PATHS[traits[0]]) as Texture2D
	shop_race_icons[index].texture = load(TRAIT_ICON_PATHS[traits[1]]) as Texture2D
	shop_element_icons[index].visible = true
	shop_race_icons[index].visible = true


func _update_selection() -> void:
	if selection_pulse_tween and selection_pulse_tween.is_valid():
		selection_pulse_tween.kill()
	for index in creature_buttons.size():
		creature_buttons[index].add_theme_stylebox_override("normal", _slot_style(Color(0, 0, 0, 0), Color(0, 0, 0, 0)))
		creature_masks[index].visible = index == selected_slot
		creature_selection_frames[index].visible = index == selected_slot
		creature_selection_frames[index].scale = Vector2.ONE
	if selected_slot >= 0 and selected_slot < creature_selection_frames.size():
		var frame := creature_selection_frames[selected_slot]
		frame.scale = Vector2(0.94, 0.94)
		selection_pulse_tween = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		selection_pulse_tween.tween_property(frame, "scale", Vector2(1.035, 1.035), 0.48)
		selection_pulse_tween.tween_property(frame, "scale", Vector2(0.94, 0.94), 0.48)


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


func _add_static_icon_button(path: String, rect: Rect2, callback: Callable, tooltip: String) -> Button:
	_add_texture(self, path, rect)
	var button := Button.new()
	button.position = rect.position
	button.size = rect.size
	button.flat = true
	button.focus_mode = Control.FOCUS_NONE
	button.tooltip_text = tooltip
	button.pressed.connect(callback)
	add_child(button)
	return button


func _add_label(parent: Control, text: String, rect: Rect2, font_size: int, color: Color, alignment := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := Label.new()
	label.position = rect.position
	label.size = rect.size
	label.text = text
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", source_han_font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	var is_dark_text := color.get_luminance() < 0.62
	label.add_theme_color_override("font_shadow_color", Color(0.48, 0.49, 0.53, 0.9) if is_dark_text else Color(0, 0, 0, 0.95))
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 1)
	var shadow_offset := 1
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


func _add_stat_badge(parent: Control, rect: Rect2, fill: Color) -> TextureRect:
	var badge := TextureRect.new()
	badge.position = rect.position
	badge.size = rect.size
	badge.texture = load("res://素材/图鉴/image-1785682708652-8ni6x6cdnyo.png") as Texture2D
	badge.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	badge.stretch_mode = TextureRect.STRETCH_SCALE
	badge.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var material := ShaderMaterial.new()
	material.shader = STAT_BADGE_SHADER
	material.set_shader_parameter("badge_color", fill)
	badge.material = material
	parent.add_child(badge)
	return badge


func _set_stat_badge_value(badge: TextureRect, value: int, is_health: bool) -> void:
	if badge == null or not badge.material is ShaderMaterial:
		return
	var base := Color("ef3f67") if is_health else Color("3184a4")
	var intensity := clampf(0.78 + float(value) / (90.0 if is_health else 50.0) * 0.28, 0.78, 1.08)
	var adjusted := Color(base.r * intensity, base.g * intensity, base.b * intensity, 1.0)
	(badge.material as ShaderMaterial).set_shader_parameter("badge_color", adjusted)


func _apply_stat_pixel_font(label: Label) -> void:
	label.add_theme_font_override("font", stat_pixel_font)
	label.add_theme_constant_override("outline_size", 1)
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
