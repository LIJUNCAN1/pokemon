extends Control

const SOURCE_HAN_FONT: FontFile = preload("res://assets/fonts/SourceHanSansSC-Heavy.otf")
const STAT_PIXEL_FONT: FontFile = preload("res://assets/fonts/ark-pixel-12px-proportional-zh_cn.ttf")
const CATALOG = preload("res://scripts/creature_catalog.gd")
const ITEM_CATALOG = preload("res://scripts/item_catalog.gd")
const BACKGROUND_SHADER: Shader = preload("res://shaders/battle_prep_background.gdshader")
const STAT_BADGE_SHADER: Shader = preload("res://shaders/stat_badge.gdshader")
const DEX_OVERLAY_SCENE: PackedScene = preload("res://dex_overlay.tscn")
const SETTINGS_OVERLAY_SCENE: PackedScene = preload("res://settings_overlay.tscn")
const INVENTORY_POPUP_SCENE: PackedScene = preload("res://inventory_popup.tscn")
const DESIGN_SIZE := Vector2(1280, 720)
const FULL_HD_SCALE := Vector2(0.5, 0.5)
const UI := "res://素材/主菜单/"
const POKEMON := "res://素材/宝可梦图/"
const SHOP_PANEL_ASSET := "res://素材/事件/aseprite_export/shop_table/runtime/shop_panel.png"
const SHOP_CARD_FRAME_ASSET := "res://素材/事件/aseprite_export/shop_table/runtime/shop_card_frame.png"
const SHOP_CARD_TEMPLATE_ASSET := "res://素材/事件/aseprite_export/shop_table/runtime/shop_card_template.png"
const SHOP_ATTRIBUTE_FRAME_ASSET := "res://素材/事件/aseprite_export/shop_table/runtime/attribute_swatch.png"
const DETAIL_ICON := "res://素材/主菜单/deteai2l.png"
const DETAIL_ICON_PRESSED := "res://素材/主菜单/deteail.png"
const LOCK_ICON := "res://素材/主菜单/lock.png"
const LOCK_ICON_PRESSED := "res://素材/主菜单/lock2.png"
const STAR_ICON: Texture2D = preload("res://素材/事件/精灵图-0007.png")
const SOLD_OUT_ICON: Texture2D = preload("res://素材/事件/sold out.png")
const HEALTH_FRAMES: Array[Texture2D] = [
	preload("res://素材/主菜单/aseprite_export/health/runtime/heart_0.png"),
	preload("res://素材/主菜单/aseprite_export/health/runtime/heart_1.png"),
	preload("res://素材/主菜单/aseprite_export/health/runtime/heart_2.png"),
	preload("res://素材/主菜单/aseprite_export/health/runtime/heart_3.png"),
	preload("res://素材/主菜单/aseprite_export/health/runtime/heart_4.png"),
]
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
const SHOP_RARITY_NAMES: Array[String] = ["普通", "稀有", "史诗"]
const SHOP_RARITY_COLORS: Array[Color] = [Color("737983"), Color("3e95d8"), Color("c45ad9")]
const SHOP_RARITY_PRICES: Array[int] = [1, 2, 3]
const SHOP_CARD_COUNT := 5
const SHOP_ITEM_CHANCE := 0.58
const SHOP_ACCESSORY_CHANCE := 0.46
const TRAIT_ICON_PATHS: Dictionary = {
	"自然": UI + "图层 8.png",
	"火": "res://assets/ui/synergy_fire.png",
	"雷": "res://assets/ui/synergy_water.png",
	"岩": UI + "图层 4.png",
	"植物": UI + "图层 7.png",
	"虫群": UI + "图层 2.png",
	"龙族": UI + "图层 3.png",
	"机械": UI + "图层 5.png",
	"亡灵": UI + "图层 6.png",
}
const TRAIT_COLORS: Dictionary = {
	"自然": Color("a8c957"),
	"火": Color("ef6a3a"),
	"雷": Color("4fa6dc"),
	"岩": Color("aab0b8"),
	"植物": Color("5fae55"),
	"虫群": Color("91b83e"),
	"龙族": Color("7954aa"),
	"机械": Color("768392"),
	"亡灵": Color("474357"),
}

var source_han_font: FontFile
var stat_pixel_font: FontFile
var creature_buttons: Array[Button] = []
var creature_sprites: Array[TextureRect] = []
var creature_level_labels: Array[Label] = []
var creature_star_rows: Array[Control] = []
var creature_hp_labels: Array[Label] = []
var creature_special_labels: Array[Label] = []
var creature_hp_badges: Array[TextureRect] = []
var creature_special_badges: Array[TextureRect] = []
var creature_element_icons: Array[TextureRect] = []
var creature_race_icons: Array[TextureRect] = []
var creature_extra_trait_icons: Array[TextureRect] = []
var creature_trait_backgrounds: Array[TextureRect] = []
var creature_masks: Array[ColorRect] = []
var creature_selection_frames: Array[TextureRect] = []
var creature_data: Array[String] = []
var creature_levels: Array[int] = []
var selected_slot := -1
var drag_source_slot := -1
var shop_sprites: Array[TextureRect] = []
var shop_buttons: Array[Button] = []
var shop_hp_labels: Array[Label] = []
var shop_special_labels: Array[Label] = []
var shop_hp_badges: Array[TextureRect] = []
var shop_special_badges: Array[TextureRect] = []
var shop_level_labels: Array[Label] = []
var shop_star_rows: Array[Control] = []
var shop_element_icons: Array[TextureRect] = []
var shop_race_icons: Array[TextureRect] = []
var shop_extra_trait_icons: Array[TextureRect] = []
var shop_trait_backgrounds: Array[TextureRect] = []
var shop_attribute_layers: Array[TextureRect] = []
var shop_creature_overlays: Array[TextureRect] = []
var shop_outer_layers: Array[TextureRect] = []
var shop_name_labels: Array[Label] = []
var shop_price_labels: Array[Label] = []
var shop_sold_out_overlays: Array[TextureRect] = []
var shop_card_outlines: Array[Panel] = []
var shop_lock_overlays: Array[TextureRect] = []
var shop_detail_icons: Array[TextureRect] = []
var shop_element_icon_backgrounds: Array[TextureRect] = []
var shop_extra_icon_backgrounds: Array[TextureRect] = []
var shop_race_icon_backgrounds: Array[TextureRect] = []
var shop_data: Array[Dictionary] = []
var notice_label: Label
var coin_label: Label
var lock_label: Label
var lock_button_texture: TextureRect
var inventory_count_label: Label
var coins := 5
var shop_locked := false
var lock_button: Button
var health_icons: Array[TextureRect] = []
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
var synergy_scroll: ScrollContainer
var synergy_list: Control
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
	coins = GameState.coins
	source_han_font = SOURCE_HAN_FONT.duplicate() as FontFile
	source_han_font.antialiasing = TextServer.FONT_ANTIALIASING_GRAY
	source_han_font.multichannel_signed_distance_field = true
	source_han_font.msdf_pixel_range = 8
	source_han_font.msdf_size = 64
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
	_build_interface()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		if not is_instance_valid(settings_overlay):
			get_viewport().set_input_as_handled()
			_on_settings_pressed()


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
	_resolve_all_creature_merges()
	_build_synergy()
	_build_shop()
	_build_footer_actions()
	notice_label = _add_label(self, "拖动角色即可在队伍与备战席之间换位", Rect2(338, 516, 604, 20), 11, Color(0.82, 0.96, 1.0), HORIZONTAL_ALIGNMENT_CENTER)
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
	_build_health_display()
	_add_label(self, "第 1 天", Rect2(525, 7, 230, 54), 38, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	_add_static_icon_button("res://assets/ui/collection_book_icon.png", Rect2(1073, 7, 52, 52), _open_dex, "打开图鉴")
	_add_icon_button(UI + "02_切图_2.png", Rect2(1138, 6, 56, 56), _on_settings_pressed, "设置")
	_add_icon_button(UI + "01_切图_1.png", Rect2(1207, 5, 58, 58), _open_inventory, "打开物品栏")
	inventory_count_label = _add_label(self, "", Rect2(1240, 43, 24, 24), 18, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	_refresh_inventory_count()


func _build_health_display() -> void:
	health_icons.clear()
	for index in 3:
		var filled := index < GameState.run_lives
		var heart := _add_texture(self, HEALTH_FRAMES[0 if filled else 4].resource_path, Rect2(365 + index * 46, 17, 42, 36))
		heart.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		health_icons.append(heart)
	if GameState.pending_life_loss_animation and GameState.run_lives < 3:
		var lost_index := clampi(GameState.run_lives, 0, 2)
		health_icons[lost_index].texture = HEALTH_FRAMES[0]
		_play_life_loss_animation.call_deferred(lost_index)


func _play_life_loss_animation(index: int) -> void:
	GameState.pending_life_loss_animation = false
	await get_tree().create_timer(0.28).timeout
	for frame_index in range(1, HEALTH_FRAMES.size()):
		health_icons[index].texture = HEALTH_FRAMES[frame_index]
		await get_tree().create_timer(0.09).timeout


func _build_trainer_panel() -> void:
	_add_texture(self, UI + "角色框.png", Rect2(6, 82, 240, 403), TextureRect.STRETCH_SCALE)
	_add_label(self, "训练家 · 晴", Rect2(18, 89, 216, 28), 16, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	_add_texture(self, "res://assets/ui/trainer_avatar_transparent.png", Rect2(18, 127, 216, 192))
	_add_label(self, "+300 最大生命", Rect2(23, 334, 206, 138), 15, Color(0.22, 0.24, 0.3), HORIZONTAL_ALIGNMENT_CENTER)


func _build_bench() -> void:
	_add_texture(self, UI + "备战框.png", Rect2(341, 82, 590, 155), TextureRect.STRETCH_SCALE)
	_add_label(self, "备战席", Rect2(353, 88, 120, 26), 15, Color.WHITE)
	var rects := [Rect2(352, 116, 136, 108), Rect2(498, 116, 136, 108), Rect2(644, 116, 136, 108), Rect2(790, 116, 136, 108)]
	for index in rects.size():
		var saved_texture := GameState.player_bench[index] if index < GameState.player_bench.size() else ""
		var saved_level := GameState.player_bench_levels[index] if index < GameState.player_bench_levels.size() else 1
		_create_creature_slot(rects[index], saved_texture, "备战 %d" % (index + 1), saved_level)


func _build_team() -> void:
	_add_texture(self, UI + "10_切图_10.png", Rect2(414, 246, 442, 270), TextureRect.STRETCH_SCALE)
	_add_label(self, "队伍", Rect2(432, 251, 170, 27), 17, Color.WHITE)
	var rects := [
		Rect2(435, 296, 119, 86), Rect2(574, 296, 121, 86), Rect2(715, 296, 120, 86),
		Rect2(435, 405, 119, 87), Rect2(574, 405, 121, 87), Rect2(715, 405, 120, 87),
	]
	for index in rects.size():
		var saved_texture := GameState.player_team[index] if index < GameState.player_team.size() else ""
		var saved_level := GameState.player_team_levels[index] if index < GameState.player_team_levels.size() else 1
		_create_creature_slot(rects[index], saved_texture, "上阵 %d" % (index + 1), saved_level)


func _build_synergy() -> void:
	_add_texture(self, UI + "羁绊框.png", Rect2(979, 82, 272, 433), TextureRect.STRETCH_SCALE)
	_add_label(self, "羁 绊", Rect2(991, 89, 248, 36), 24, Color(0.95, 0.87, 1.0), HORIZONTAL_ALIGNMENT_CENTER)
	synergy_scroll = ScrollContainer.new()
	synergy_scroll.position = Vector2(986, 136)
	synergy_scroll.size = Vector2(258, 368)
	synergy_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	synergy_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	synergy_scroll.clip_contents = true
	add_child(synergy_scroll)
	synergy_list = Control.new()
	synergy_list.custom_minimum_size = Vector2(244, 368)
	synergy_list.size = synergy_list.custom_minimum_size
	synergy_scroll.add_child(synergy_list)
	for index in CATALOG.SYNERGY_ORDER.size():
		var synergy: String = CATALOG.SYNERGY_ORDER[index]
		var y := index * 61.0
		var icon := _add_texture(synergy_list, TRAIT_ICON_PATHS[synergy], Rect2(8, y + 10, 38, 38))
		var name_label := _add_label(synergy_list, synergy, Rect2(50, y + 4, 112, 26), 16, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
		var count_label := _add_label(synergy_list, "", Rect2(174, y + 4, 62, 26), 16, Color("f3a62f"), HORIZONTAL_ALIGNMENT_CENTER)
		synergy_icons[synergy] = icon
		synergy_name_labels[synergy] = name_label
		synergy_count_labels[synergy] = count_label
		var thresholds: Array = CATALOG.THRESHOLDS[synergy]
		var boxes: Array[ColorRect] = []
		var step_labels: Array[Label] = []
		for step_index in thresholds.size():
			var step_x := 57.0 + step_index * 31.0
			var active_box := ColorRect.new()
			active_box.position = Vector2(step_x, y + 33)
			active_box.size = Vector2(25, 19)
			active_box.color = TRAIT_COLORS[synergy]
			active_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
			active_box.visible = false
			synergy_list.add_child(active_box)
			boxes.append(active_box)
			var step_label := _add_label(synergy_list, "%d" % thresholds[step_index], Rect2(step_x, y + 33, 25, 19), 11, Color("777b83"), HORIZONTAL_ALIGNMENT_CENTER)
			step_labels.append(step_label)
		synergy_step_boxes[synergy] = boxes
		synergy_step_labels[synergy] = step_labels
		var hover := Button.new()
		hover.position = Vector2(0, y)
		hover.size = Vector2(244, 60)
		hover.flat = true
		hover.focus_mode = Control.FOCUS_NONE
		hover.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		hover.mouse_entered.connect(_show_synergy_tooltip.bind(synergy))
		hover.mouse_exited.connect(_hide_synergy_tooltip)
		synergy_list.add_child(hover)
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
	var row_y := float(synergy_row_positions.get(synergy, 136.0)) - float(synergy_scroll.scroll_vertical)
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
		var row_y := visible_row * 61.0
		var icon: TextureRect = synergy_icons[synergy]
		var name_label: Label = synergy_name_labels[synergy]
		var count_label: Label = synergy_count_labels[synergy]
		var hover: Button = synergy_hover_buttons[synergy]
		icon.visible = row_visible
		name_label.visible = row_visible
		count_label.visible = row_visible
		hover.visible = row_visible
		if row_visible:
			icon.position = Vector2(8, row_y + 10)
			name_label.position = Vector2(50, row_y + 4)
			count_label.position = Vector2(174, row_y + 4)
			hover.position = Vector2(0, row_y)
			synergy_row_positions[synergy] = 136.0 + row_y
			visible_row += 1
		var thresholds: Array = CATALOG.THRESHOLDS[synergy]
		count_label.text = "%d/%d" % [count, thresholds[thresholds.size() - 1]]
		count_label.add_theme_color_override("font_color", Color("f3a62f") if count >= thresholds[0] else Color("777b83"))
		var boxes: Array = synergy_step_boxes[synergy]
		var step_labels: Array = synergy_step_labels[synergy]
		for index in boxes.size():
			var step_x := 57.0 + index * 31.0
			var box := boxes[index] as ColorRect
			var step_label := step_labels[index] as Label
			box.position = Vector2(step_x, row_y + 33)
			step_label.position = Vector2(step_x, row_y + 33)
			box.visible = row_visible and count >= thresholds[index]
			step_label.visible = row_visible
			step_label.add_theme_color_override("font_color", Color.WHITE if count >= thresholds[index] else Color("777b83"))
	synergy_list.custom_minimum_size = Vector2(244, maxf(368.0, visible_row * 61.0))
	synergy_list.size = synergy_list.custom_minimum_size
	if not hovered_synergy.is_empty():
		if int(synergy_current_counts.get(hovered_synergy, 0)) > 0:
			_show_synergy_tooltip(hovered_synergy)
		else:
			_hide_synergy_tooltip()


func _build_shop() -> void:
	_add_texture(self, SHOP_PANEL_ASSET, Rect2(242, 526, 796, 190))
	_add_label(self, "商店", Rect2(260, 528, 86, 25), 18, Color.WHITE)
	var rarity_labels := [
		_add_label(self, "普通 60%", Rect2(348, 530, 88, 21), 10, SHOP_RARITY_COLORS[0], HORIZONTAL_ALIGNMENT_CENTER),
		_add_label(self, "稀有 30%", Rect2(436, 530, 88, 21), 10, SHOP_RARITY_COLORS[1], HORIZONTAL_ALIGNMENT_CENTER),
		_add_label(self, "史诗 10%", Rect2(524, 530, 88, 21), 10, SHOP_RARITY_COLORS[2], HORIZONTAL_ALIGNMENT_CENTER),
	]
	shop_data = _roll_shop_entries(false)
	for entry in shop_data:
		_mark_shop_creature_seen(entry)
	var card_width := 145.0
	var card_gap := 9.0
	var card_start_x := 264.0
	var card_height := 130.0
	for index in SHOP_CARD_COUNT:
		_create_shop_card(index, Rect2(card_start_x + index * (card_width + card_gap), 574, card_width, card_height))
	_add_texture(self, UI + "04_切图_4.png", Rect2(871, 529, 22, 22))
	coin_label = _add_label(self, "%dG" % coins, Rect2(895, 528, 58, 24), 14, Color("e4aa2f"), HORIZONTAL_ALIGNMENT_RIGHT)
	lock_button_texture = _add_texture(self, LOCK_ICON, Rect2(1000, 530, 18, 18))
	lock_button = Button.new()
	lock_button.position = Vector2(954, 526)
	lock_button.size = Vector2(70, 28)
	lock_button.flat = true
	lock_button.tooltip_text = "锁定商店"
	lock_button.focus_mode = Control.FOCUS_NONE
	add_child(lock_button)
	lock_button.button_down.connect(_set_lock_button_pressed.bind(true))
	lock_button.button_up.connect(_set_lock_button_pressed.bind(false))
	lock_button.mouse_exited.connect(_set_lock_button_pressed.bind(false))
	lock_button.pressed.connect(_on_lock_pressed)
	lock_label = _add_label(self, "锁定", Rect2(954, 528, 43, 24), 12, Color("596575"), HORIZONTAL_ALIGNMENT_CENTER)
	_apply_stat_pixel_font(lock_label)


func _build_footer_actions() -> void:
	var reroll := _add_texture_button(UI + "攻击力 (1).png", Rect2(5, 597, 198, 119), "刷新商店")
	reroll.focus_mode = Control.FOCUS_NONE
	reroll.pressed.connect(_on_reroll_pressed)
	_add_label(reroll, "刷新", Rect2(0, 23, 198, 36), 25, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	_add_label(reroll, "$1", Rect2(0, 62, 198, 32), 21, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	var shop_node := GameState.map_initialized and GameState.current_map_node_type() == "shop"
	var battle := _add_texture_button(UI + "血量.png", Rect2(1075, 598, 198, 118), "离开商店" if shop_node else "进入战斗")
	battle.focus_mode = Control.FOCUS_NONE
	if shop_node:
		battle.pressed.connect(_leave_shop)
	else:
		battle.pressed.connect(_on_battle_pressed)
	_add_label(battle, "返回地图" if shop_node else "战斗！", Rect2(0, 38, 198, 42), 27, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)


func _create_creature_slot(rect: Rect2, texture_path: String, slot_name: String, saved_level: int = 1) -> void:
	var compact_card := rect.size.y < 100.0
	var button := Button.new()
	button.position = rect.position
	button.size = rect.size
	button.flat = true
	button.focus_mode = Control.FOCUS_NONE
	button.tooltip_text = ""
	button.add_theme_stylebox_override("normal", _slot_style(Color(0, 0, 0, 0), Color(0, 0, 0, 0)))
	button.add_theme_stylebox_override("hover", _slot_style(Color(0.1, 0.65, 0.8, 0.08), Color(0.3, 0.9, 1.0, 0.8), 2))
	add_child(button)
	var trait_background := TextureRect.new()
	trait_background.position = Vector2(3, 3)
	trait_background.size = rect.size - Vector2(6, 6)
	trait_background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	trait_background.stretch_mode = TextureRect.STRETCH_SCALE
	trait_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	trait_background.modulate = Color(1, 1, 1, 0.72)
	trait_background.visible = false
	button.add_child(trait_background)
	var sprite := TextureRect.new()
	sprite.position = Vector2(24, 10) if compact_card else Vector2(30, 18)
	sprite.size = Vector2(rect.size.x - 48, rect.size.y - 36) if compact_card else Vector2(rect.size.x - 60, rect.size.y - 48)
	sprite.pivot_offset = sprite.size * 0.5
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(sprite)
	var level_label := _add_label(button, "", Rect2(5, 2, 48, 17) if compact_card else Rect2(7, 3, 54, 19), 9 if compact_card else 10, Color.WHITE)
	level_label.visible = false
	var star_row := _create_star_row(button, Rect2(5, 2, 48, 17) if compact_card else Rect2(7, 3, 54, 19))
	var badge_width := 30.0 if compact_card else 34.0
	var badge_gap := 3.0
	var badge_x := (rect.size.x - badge_width * 2.0 - badge_gap) * 0.5
	var badge_height := 21.0 if compact_card else 24.0
	var badge_y := rect.size.y - (23.0 if compact_card else 27.0)
	var hp_badge := _add_stat_badge(button, Rect2(badge_x, badge_y, badge_width, badge_height), Color("ef3f67"))
	var special_badge := _add_stat_badge(button, Rect2(badge_x + badge_width + badge_gap, badge_y, badge_width, badge_height), Color("3184a4"))
	var hp_label := _add_label(button, "", Rect2(badge_x, badge_y + 1, badge_width, badge_height - 3), 9 if compact_card else 10, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	var special_label := _add_label(button, "", Rect2(badge_x + badge_width + badge_gap, badge_y + 1, badge_width, badge_height - 3), 9 if compact_card else 10, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	_apply_stat_pixel_font(hp_label)
	_apply_stat_pixel_font(special_label)
	var trait_icon_size := 18.0 if compact_card else 22.0
	var trait_icon_x := rect.size.x - (23.0 if compact_card else 28.0)
	var element_icon := _add_texture(button, TRAIT_ICON_PATHS["自然"], Rect2(trait_icon_x, 4 if compact_card else 5, trait_icon_size, trait_icon_size))
	var extra_trait_icon := _add_texture(button, TRAIT_ICON_PATHS["雷"], Rect2(trait_icon_x, 24 if compact_card else 31, trait_icon_size, trait_icon_size))
	var race_icon := _add_texture(button, TRAIT_ICON_PATHS["机械"], Rect2(trait_icon_x, 44 if compact_card else 57, trait_icon_size, trait_icon_size))
	element_icon.visible = false
	extra_trait_icon.visible = false
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
	creature_star_rows.append(star_row)
	creature_hp_labels.append(hp_label)
	creature_special_labels.append(special_label)
	creature_hp_badges.append(hp_badge)
	creature_special_badges.append(special_badge)
	creature_element_icons.append(element_icon)
	creature_race_icons.append(race_icon)
	creature_extra_trait_icons.append(extra_trait_icon)
	creature_trait_backgrounds.append(trait_background)
	creature_masks.append(replace_mask)
	creature_selection_frames.append(selection_frame)
	creature_data.append(texture_path)
	creature_levels.append(0 if texture_path.is_empty() else clampi(saved_level, 1, 3))
	var slot_index := creature_buttons.size() - 1
	button.set_drag_forwarding(
		_get_creature_drag_data.bind(slot_index),
		_can_drop_creature_data.bind(slot_index),
		_drop_creature_data.bind(slot_index)
	)
	button.mouse_entered.connect(_show_creature_selection_frame.bind(slot_index))
	button.mouse_exited.connect(_hide_card_tooltip)
	button.mouse_exited.connect(_hide_creature_selection_frame.bind(slot_index))
	button.gui_input.connect(_on_creature_card_gui_input.bind(slot_index))
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
	shop_buttons.append(button)
	var top_height := 100.0
	var content_layer := _add_texture(button, SHOP_CARD_TEMPLATE_ASSET, Rect2(Vector2.ZERO, rect.size), TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	var trait_background := TextureRect.new()
	trait_background.position = Vector2(6, 6)
	trait_background.size = Vector2(133, 94)
	trait_background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	trait_background.stretch_mode = TextureRect.STRETCH_SCALE
	trait_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	trait_background.modulate = Color(1, 1, 1, 0.78)
	trait_background.visible = false
	button.add_child(trait_background)
	var creature_overlay := TextureRect.new()
	creature_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(creature_overlay)
	var sprite := TextureRect.new()
	sprite.position = Vector2(28, 7)
	sprite.size = Vector2(rect.size.x - 56, top_height - 13)
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(sprite)
	var element_background := _add_shop_icon_background(button, Rect2(8, 77, 21, 21))
	var extra_background := _add_shop_icon_background(button, Rect2(33, 77, 21, 21))
	var race_background := _add_shop_icon_background(button, Rect2(58, 77, 21, 21))
	var element_icon := _add_texture(button, TRAIT_ICON_PATHS["自然"], Rect2(10, 79, 17, 17))
	var extra_trait_icon := _add_texture(button, TRAIT_ICON_PATHS["雷"], Rect2(35, 79, 17, 17))
	var race_icon := _add_texture(button, TRAIT_ICON_PATHS["机械"], Rect2(60, 79, 17, 17))
	element_background.visible = false
	extra_background.visible = false
	race_background.visible = false
	element_icon.visible = false
	extra_trait_icon.visible = false
	race_icon.visible = false
	var stat_width := 34.0
	var stat_gap := 4.0
	var stat_x := (rect.size.x - stat_width * 2.0 - stat_gap) * 0.5
	var stat_y := top_height - 27.0
	var hp_label := _add_label(button, "", Rect2(stat_x, stat_y, stat_width, 18), 9, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	var special_label := _add_label(button, "", Rect2(stat_x + stat_width + stat_gap, stat_y, stat_width, 18), 9, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	var hp_badge := _add_stat_badge(button, Rect2(stat_x, stat_y - 1, stat_width, 21), Color("ef3f67"))
	var special_badge := _add_stat_badge(button, Rect2(stat_x + stat_width + stat_gap, stat_y - 1, stat_width, 21), Color("3184a4"))
	hp_label.visible = false
	special_label.visible = false
	hp_badge.visible = false
	special_badge.visible = false
	hp_label.move_to_front()
	special_label.move_to_front()
	_apply_stat_pixel_font(hp_label)
	_apply_stat_pixel_font(special_label)
	var detail_icon := _add_texture(button, DETAIL_ICON, Rect2(7, top_height + 8, 16, 16))
	detail_icon.z_index = 28
	var name_label := _add_label(button, "", Rect2(27, top_height + 4, 108, 29), 11, Color("f4f5f6"))
	var price_label := _add_label(button, "", Rect2(rect.size.x - 50, top_height + 4, 43, 29), 12, Color("e4aa2f"), HORIZONTAL_ALIGNMENT_RIGHT)
	var card_outline := Panel.new()
	card_outline.position = Vector2.ZERO
	card_outline.size = rect.size
	card_outline.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_outline.add_theme_stylebox_override("panel", _slot_style(Color(0, 0, 0, 0), Color(0.66, 0.67, 0.72, 1.0), 3))
	button.add_child(card_outline)
	var outer_layer := _add_texture(button, SHOP_CARD_FRAME_ASSET, Rect2(Vector2.ZERO, rect.size))
	outer_layer.visible = false
	card_outline.move_to_front()
	var shop_level := _add_label(button, "", Rect2(8, 5, 64, 20), 9, Color.WHITE)
	shop_level.visible = false
	shop_level.add_theme_color_override("font_color", LEVEL_COLORS[0])
	var shop_stars := _create_star_row(button, Rect2(8, 5, 64, 20))
	var sold_out := _add_texture(button, SOLD_OUT_ICON.resource_path, Rect2((rect.size.x - 160.0) * 0.5, (top_height - 60.0) * 0.5, 160, 60))
	sold_out.pivot_offset = sold_out.size * 0.5
	sold_out.rotation = deg_to_rad(30.0)
	sold_out.visible = false
	sold_out.z_index = 30
	var lock_overlay := _add_texture(button, LOCK_ICON, Rect2((rect.size.x - 26.0) * 0.5, (top_height - 26.0) * 0.5, 26, 26))
	lock_overlay.visible = false
	lock_overlay.z_index = 40
	shop_sprites.append(sprite)
	shop_hp_labels.append(hp_label)
	shop_special_labels.append(special_label)
	shop_hp_badges.append(hp_badge)
	shop_special_badges.append(special_badge)
	shop_level_labels.append(shop_level)
	shop_star_rows.append(shop_stars)
	shop_element_icons.append(element_icon)
	shop_race_icons.append(race_icon)
	shop_extra_trait_icons.append(extra_trait_icon)
	shop_trait_backgrounds.append(trait_background)
	shop_attribute_layers.append(content_layer)
	shop_creature_overlays.append(creature_overlay)
	shop_outer_layers.append(outer_layer)
	shop_name_labels.append(name_label)
	shop_price_labels.append(price_label)
	shop_sold_out_overlays.append(sold_out)
	shop_card_outlines.append(card_outline)
	shop_lock_overlays.append(lock_overlay)
	shop_detail_icons.append(detail_icon)
	shop_element_icon_backgrounds.append(element_background)
	shop_extra_icon_backgrounds.append(extra_background)
	shop_race_icon_backgrounds.append(race_background)
	button.pressed.connect(_on_shop_card_pressed.bind(index))
	button.mouse_entered.connect(_shake_shop_card.bind(button))
	button.mouse_exited.connect(_hide_card_tooltip)
	button.mouse_exited.connect(_reset_shop_detail_icon.bind(index))
	button.gui_input.connect(_on_shop_card_gui_input.bind(index))
	_render_shop_card(index)


func _add_shop_icon_background(parent: Control, rect: Rect2) -> TextureRect:
	var background := _add_texture(parent, SHOP_ATTRIBUTE_FRAME_ASSET, rect, TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	background.modulate = Color.WHITE
	return background


func _build_card_tooltip() -> void:
	card_tooltip = Panel.new()
	card_tooltip.size = Vector2(292, 331)
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
	card_tooltip_race_icon = _add_texture(card_tooltip_race_panel, TRAIT_ICON_PATHS["机械"], Rect2(9, 7, 30, 30))
	card_tooltip_race = _add_label(card_tooltip_race_panel, "", Rect2(42, 4, 66, 36), 14, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	card_tooltip_info_panel = Panel.new()
	card_tooltip_info_panel.position = Vector2(16, 199)
	card_tooltip_info_panel.size = Vector2(258, 116)
	card_tooltip_info_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_tooltip_info_panel.add_theme_stylebox_override("panel", _slot_style(Color(0.99, 0.99, 1.0, 1.0), Color(0.68, 0.69, 0.74, 1.0), 3))
	card_tooltip.add_child(card_tooltip_info_panel)
	card_tooltip_cooldown = _add_label(card_tooltip_info_panel, "", Rect2(12, 7, 78, 53), 17, Color("252631"), HORIZONTAL_ALIGNMENT_CENTER)
	card_tooltip_damage = _add_label(card_tooltip_info_panel, "", Rect2(93, 7, 153, 32), 15, Color("ef3f64"))
	card_tooltip_extra = _add_label(card_tooltip_info_panel, "", Rect2(93, 36, 153, 72), 11, Color("5579b9"))
	card_tooltip_extra.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART


func _show_creature_card_tooltip(index: int) -> void:
	if index < 0 or index >= creature_data.size() or creature_data[index].is_empty():
		_hide_card_tooltip()
		return
	_show_card_tooltip(creature_data[index], creature_levels[index])


func _on_creature_card_gui_input(event: InputEvent, index: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		_show_creature_card_tooltip(index)
		creature_buttons[index].accept_event()


func _show_shop_card_tooltip(index: int) -> void:
	if index < 0 or index >= shop_data.size() or shop_data[index].is_empty():
		_hide_card_tooltip()
		return
	var entry: Dictionary = shop_data[index]
	if entry["kind"] != "creature":
		_show_item_card_tooltip(entry)
	else:
		_show_card_tooltip(entry["path"], 1)


func _on_shop_card_gui_input(event: InputEvent, index: int) -> void:
	if not event is InputEventMouseButton or event.button_index != MOUSE_BUTTON_RIGHT:
		return
	shop_detail_icons[index].texture = load(DETAIL_ICON_PRESSED if event.pressed else DETAIL_ICON) as Texture2D
	if event.pressed:
		_show_shop_card_tooltip(index)
	shop_buttons[index].accept_event()


func _reset_shop_detail_icon(index: int) -> void:
	if index >= 0 and index < shop_detail_icons.size():
		shop_detail_icons[index].texture = load(DETAIL_ICON) as Texture2D


func _show_card_tooltip(texture_path: String, level: int) -> void:
	var data_index := maxi(CREATURE_TEXTURES.find(texture_path), 0)
	var elements: PackedStringArray = CATALOG.elements_for_texture(texture_path)
	var races: PackedStringArray = CATALOG.races_for_texture(texture_path)
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
	card_tooltip_element_icon.texture = load(TRAIT_ICON_PATHS[elements[0]]) as Texture2D
	card_tooltip_element.text = "/".join(elements)
	card_tooltip_element_panel.add_theme_stylebox_override("panel", _slot_style(TRAIT_COLORS[elements[0]], TRAIT_COLORS[elements[0]].lightened(0.18), 1))
	card_tooltip_race_icon.texture = load(TRAIT_ICON_PATHS[races[0]]) as Texture2D
	card_tooltip_race.text = races[0]
	card_tooltip_race_panel.add_theme_stylebox_override("panel", _slot_style(TRAIT_COLORS[races[0]], TRAIT_COLORS[races[0]].lightened(0.18), 1))
	var rarity_multiplier := CATALOG.RARITY_STAT_MULTIPLIERS[rarity_index]
	var cooldown := (3.0 + float(data_index % 5) * 0.5) / CATALOG.RARITY_CHARGE_MULTIPLIERS[rarity_index]
	var damage := roundi((15 + data_index * 2) * maxi(level, 1) * rarity_multiplier)
	card_tooltip_cooldown.text = "%.1f\n秒" % cooldown
	card_tooltip_damage.text = "造成 %d 点伤害" % damage
	card_tooltip_extra.text = "定位：%s · 品级加成 +%d%%\n%s" % [CATALOG.combat_role_name(texture_path), roundi((rarity_multiplier - 1.0) * 100.0), _creature_extra_text(texture_path, rarity_index)]
	_position_card_tooltip()


func _show_item_card_tooltip(entry: Dictionary) -> void:
	card_tooltip_element_panel.visible = false
	card_tooltip_race_panel.visible = false
	card_tooltip_name.text = _shop_entry_name(entry)
	card_tooltip_rarity.text = SHOP_RARITY_NAMES[int(entry["rarity"])]
	card_tooltip_sprite.texture = load(entry["path"]) as Texture2D
	card_tooltip_cooldown.text = "饰品" if entry["kind"] == "accessory" else "道具"
	card_tooltip_damage.text = "售价 $%d" % int(entry["price"])
	card_tooltip_extra.text = String(entry["effect"])
	_position_card_tooltip()


func _position_card_tooltip() -> void:
	var mouse := get_local_mouse_position()
	var desired := Vector2(mouse.x - card_tooltip.size.x * 0.5, mouse.y + 18.0)
	if desired.y + card_tooltip.size.y > DESIGN_SIZE.y - 8:
		desired.y = mouse.y - card_tooltip.size.y - 18
	card_tooltip.position = Vector2(clampf(desired.x, 8.0, DESIGN_SIZE.x - card_tooltip.size.x - 8.0), clampf(desired.y, 8.0, DESIGN_SIZE.y - card_tooltip.size.y - 8.0))
	card_tooltip.visible = true
	card_tooltip.move_to_front()


func _creature_extra_text(texture_path: String, rarity_index: int) -> String:
	var releases := 1 + rarity_index
	var races: PackedStringArray = CATALOG.races_for_texture(texture_path)
	var race := races[0] if not races.is_empty() else ""
	match race:
		"植物": return "多重释放：%d\n战斗中持续成长" % releases
		"机械": return "多重释放：%d\n获得额外护甲" % releases
		"虫群": return "多重释放：%d\n为同族加速充能" % releases
		"龙族": return "多重释放：%d\n技能伤害与溅射强化" % releases
		"亡灵": return "多重释放：%d\n吸血并具有复生能力" % releases
		_: return "多重释放：%d\n羁绊能力强化" % releases


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
	_swap_creature_slots(selected_slot, index)
	selected_slot = -1
	_update_selection()
	_set_notice("角色位置已交换")


func _get_creature_drag_data(_at_position: Vector2, slot_index: int) -> Variant:
	if slot_index < 0 or slot_index >= creature_data.size() or creature_data[slot_index].is_empty():
		return null
	_hide_card_tooltip()
	drag_source_slot = slot_index
	CursorManager.set_dragging(true)
	_show_drag_exchange_targets(slot_index)
	var preview := Panel.new()
	preview.size = Vector2(92, 92)
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	preview.add_theme_stylebox_override("panel", _slot_style(Color(0.05, 0.08, 0.12, 0.94), Color("ffd45f"), 3))
	var portrait := _add_texture(preview, creature_data[slot_index], Rect2(10, 10, 72, 64))
	portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var preview_stars := _create_star_row(preview, Rect2(8, 68, 76, 18))
	_set_star_level(preview_stars, creature_levels[slot_index])
	creature_buttons[slot_index].set_drag_preview(preview)
	return {"kind": "creature_slot", "source_index": slot_index}


func _can_drop_creature_data(_at_position: Vector2, data: Variant, slot_index: int) -> bool:
	if not data is Dictionary or String(data.get("kind", "")) != "creature_slot":
		return false
	var source_index := int(data.get("source_index", -1))
	return source_index >= 0 and source_index < creature_data.size() and source_index != slot_index


func _drop_creature_data(_at_position: Vector2, data: Variant, slot_index: int) -> void:
	if not _can_drop_creature_data(_at_position, data, slot_index):
		return
	var source_index := int(data.get("source_index", -1))
	_swap_creature_slots(source_index, slot_index)
	_clear_drag_exchange_targets()
	var destination := "队伍" if slot_index >= 4 else "备战席"
	_set_notice("角色已拖动到%s" % destination)


func _show_drag_exchange_targets(source_index: int) -> void:
	for index in creature_masks.size():
		creature_masks[index].visible = index != source_index and not creature_data[index].is_empty()
		creature_selection_frames[index].visible = false


func _clear_drag_exchange_targets() -> void:
	drag_source_slot = -1
	CursorManager.set_dragging(false)
	for mask in creature_masks:
		mask.visible = false


func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END and drag_source_slot >= 0:
		_clear_drag_exchange_targets()


func _swap_creature_slots(first_index: int, second_index: int) -> void:
	if first_index == second_index:
		return
	var held_path := creature_data[first_index]
	var held_level := creature_levels[first_index]
	creature_data[first_index] = creature_data[second_index]
	creature_levels[first_index] = creature_levels[second_index]
	creature_data[second_index] = held_path
	creature_levels[second_index] = held_level
	_render_creature_slot(first_index)
	_render_creature_slot(second_index)
	_update_synergies()


func _on_shop_card_pressed(index: int) -> void:
	if shop_data[index].is_empty():
		_set_notice("该商品已售出")
		return
	var entry: Dictionary = shop_data[index]
	var price := int(entry["price"])
	if GameState.coins < price:
		_set_notice("金币不足")
		return
	if entry["kind"] == "item" or entry["kind"] == "accessory":
		if not _spend_shop_coins(price):
			_set_notice("金币不足")
			return
		if entry["kind"] == "accessory":
			GameState.add_accessory(entry)
		else:
			GameState.add_item(entry)
		_refresh_inventory_count()
		shop_data[index] = {}
		_render_shop_card(index)
		_hide_card_tooltip()
		_set_notice("%s：%s" % [_shop_entry_name(entry), String(entry["effect"])])
		return
	var texture_path := String(entry["path"])
	if not _can_accept_creature_purchase(texture_path):
		_set_notice("备战席已满，请先拖动角色到队伍")
		return
	var merge_level := _add_purchased_creature(texture_path)
	shop_data[index] = {}
	if not _spend_shop_coins(price):
		_set_notice("金币不足")
		return
	_render_shop_card(index)
	GameState.mark_creature_seen(texture_path)
	GameState.unlock_creature_achievement(texture_path, GameState.ACHIEVEMENT_TROPHY)
	_update_synergies()
	selected_slot = -1
	_update_selection()
	_hide_card_tooltip()
	_set_notice("已自动合成为 %d 星角色" % merge_level if merge_level > 1 else "角色已加入备战席")


func _can_accept_creature_purchase(texture_path: String) -> bool:
	for slot_index in range(0, mini(4, creature_data.size())):
		if creature_data[slot_index].is_empty():
			return true
	return _matching_creature_slots(texture_path, 1).size() >= 2


func _add_purchased_creature(texture_path: String) -> int:
	var target_slot := -1
	for slot_index in range(0, mini(4, creature_data.size())):
		if creature_data[slot_index].is_empty():
			target_slot = slot_index
			break
	if target_slot >= 0:
		creature_data[target_slot] = texture_path
		creature_levels[target_slot] = 1
		_render_creature_slot(target_slot)
	else:
		# Two owned 1-star copies plus the purchased copy form the triple.
		var matches := _matching_creature_slots(texture_path, 1)
		var keep_slot := _preferred_merge_slot(matches)
		matches.erase(keep_slot)
		creature_levels[keep_slot] = 2
		_clear_creature_slot(matches[0])
		_render_creature_slot(keep_slot)
	return _resolve_creature_merges(texture_path)


func _resolve_all_creature_merges() -> void:
	var unique_paths: Dictionary = {}
	for texture_path in creature_data:
		if not texture_path.is_empty():
			unique_paths[texture_path] = true
	for texture_path in unique_paths:
		_resolve_creature_merges(String(texture_path))


func _resolve_creature_merges(texture_path: String) -> int:
	var highest_level := 1
	for level in range(1, 3):
		while true:
			var matches := _matching_creature_slots(texture_path, level)
			if matches.size() < 3:
				break
			var keep_slot := _preferred_merge_slot(matches)
			matches.erase(keep_slot)
			creature_levels[keep_slot] = level + 1
			_clear_creature_slot(matches[0])
			_clear_creature_slot(matches[1])
			_render_creature_slot(keep_slot)
			highest_level = level + 1
	for index in creature_data.size():
		if creature_data[index] == texture_path:
			highest_level = maxi(highest_level, creature_levels[index])
	return highest_level


func _matching_creature_slots(texture_path: String, level: int) -> Array[int]:
	var result: Array[int] = []
	for index in creature_data.size():
		if creature_data[index] == texture_path and creature_levels[index] == level:
			result.append(index)
	return result


func _preferred_merge_slot(matches: Array[int]) -> int:
	for index in matches:
		if index >= 4:
			return index
	return matches[0]


func _clear_creature_slot(index: int) -> void:
	creature_data[index] = ""
	creature_levels[index] = 0
	if selected_slot == index:
		selected_slot = -1
	_render_creature_slot(index)


func _on_reroll_pressed() -> void:
	if shop_locked:
		_set_notice("商店已锁定，无法刷新")
		return
	if GameState.coins < 1:
		_set_notice("金币不足")
		return
	if not _spend_shop_coins(1):
		_set_notice("金币不足")
		return
	shop_data = _roll_shop_entries()
	for entry in shop_data:
		_mark_shop_creature_seen(entry)
	for index in shop_sprites.size():
		_render_shop_card(index)
	_set_notice("商店已刷新")


func _roll_shop_rarity() -> int:
	var roll := rng.randf()
	if roll >= 0.9:
		return 2
	if roll >= 0.6:
		return 1
	return 0


func _draw_creature_shop_entry() -> Dictionary:
	var rarity_index := _roll_shop_rarity()
	var pool: Array = SHOP_RARITY_POOLS[rarity_index]
	var creature_index: int = pool[rng.randi_range(0, pool.size() - 1)]
	return {
		"kind": "creature",
		"path": CREATURE_TEXTURES[creature_index],
		"rarity": rarity_index,
		"price": SHOP_RARITY_PRICES[rarity_index],
	}


func _roll_shop_entries(include_non_creature := true) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for index in SHOP_CARD_COUNT:
		entries.append(_draw_creature_shop_entry())
	if not include_non_creature:
		return entries
	var available_slots: Array[int] = [0, 1, 2, 3, 4]
	if rng.randf() < SHOP_ITEM_CHANCE:
		var item_slot := int(available_slots.pop_at(rng.randi_range(0, available_slots.size() - 1)))
		entries[item_slot] = ITEM_CATALOG.random_entry("item", rng, _roll_shop_rarity())
	if rng.randf() < SHOP_ACCESSORY_CHANCE and not available_slots.is_empty():
		var accessory_slot := int(available_slots.pop_at(rng.randi_range(0, available_slots.size() - 1)))
		entries[accessory_slot] = ITEM_CATALOG.random_entry("accessory", rng, _roll_shop_rarity())
	return entries


func _mark_shop_creature_seen(entry: Dictionary) -> void:
	if not entry.is_empty() and entry["kind"] == "creature":
		GameState.mark_creature_seen(entry["path"])


func _shop_entry_name(entry: Dictionary) -> String:
	if entry["kind"] == "creature":
		var creature_index := CREATURE_TEXTURES.find(entry["path"])
		return CREATURE_NAMES[maxi(creature_index, 0)]
	return String(entry.get("name", "未知物品"))


func _on_lock_pressed() -> void:
	shop_locked = not shop_locked
	lock_label.text = "已锁" if shop_locked else "锁定"
	_set_lock_button_pressed(false)
	for overlay in shop_lock_overlays:
		if shop_locked:
			overlay.visible = true
			overlay.modulate.a = 1.0
		else:
			var fade := create_tween()
			fade.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			fade.tween_property(overlay, "modulate:a", 0.0, 0.45)
			fade.tween_callback(func() -> void:
				overlay.visible = false
				overlay.modulate.a = 1.0
			)
	_set_notice("商店已锁定" if shop_locked else "商店已解锁")


func _set_lock_button_pressed(pressed: bool) -> void:
	if lock_button_texture:
		lock_button_texture.texture = load(LOCK_ICON_PRESSED if pressed or shop_locked else LOCK_ICON) as Texture2D


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
	_refresh_inventory_count()
	if not is_instance_valid(inventory_popup):
		inventory_popup = INVENTORY_POPUP_SCENE.instantiate() as Control
		add_child(inventory_popup)
	else:
		inventory_popup.move_to_front()
		if inventory_popup.has_method("refresh_items"):
			inventory_popup.call("refresh_items")


func _refresh_inventory_count() -> void:
	if not inventory_count_label:
		return
	var item_count := GameState.item_inventory.size() + GameState.accessory_inventory.size()
	inventory_count_label.text = str(item_count)
	inventory_count_label.visible = item_count > 0


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
	_save_current_team()
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


func _leave_shop() -> void:
	_save_current_team()
	GameState.complete_current_map_node()
	get_tree().change_scene_to_file("res://map.tscn")


func _on_back_pressed() -> void:
	if GameState.map_initialized:
		_save_current_team()
		if GameState.current_map_node_type() == "shop":
			GameState.complete_current_map_node()
		get_tree().change_scene_to_file("res://map.tscn")
	else:
		get_tree().change_scene_to_file("res://main.tscn")


func _save_current_team() -> void:
	var saved_bench: Array[String] = []
	var saved_bench_levels: Array[int] = []
	for index in range(0, mini(creature_data.size(), 4)):
		if not creature_data[index].is_empty():
			saved_bench.append(creature_data[index])
			saved_bench_levels.append(creature_levels[index])
	var saved_team: Array[String] = []
	var saved_team_levels: Array[int] = []
	for index in range(4, mini(creature_data.size(), 10)):
		saved_team.append(creature_data[index])
		saved_team_levels.append(creature_levels[index])
	GameState.set_player_bench(saved_bench, saved_bench_levels)
	GameState.set_player_team(saved_team, saved_team_levels)


func _sync_coins() -> void:
	coins = GameState.coins
	if coin_label:
		coin_label.text = "%dG" % coins


func _spend_shop_coins(amount: int) -> bool:
	if not GameState.try_spend_coins(amount):
		return false
	_sync_coins()
	return true


func _create_star_row(parent: Control, rect: Rect2) -> Control:
	var row := Control.new()
	row.position = rect.position
	row.size = rect.size
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.set_meta("star_size", minf(15.0, rect.size.y))
	parent.add_child(row)
	for _index in 3:
		var star := TextureRect.new()
		star.texture = STAR_ICON
		star.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		star.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		star.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		star.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(star)
	_set_star_level(row, 1)
	return row


func _set_star_level(row: Control, level: int) -> void:
	level = clampi(level, 1, 3)
	var star_size := float(row.get_meta("star_size", 15.0))
	var gap := 1.0
	var total_width := star_size * level + gap * (level - 1)
	var start_x := floorf((row.size.x - total_width) * 0.5)
	for index in row.get_child_count():
		var star := row.get_child(index) as TextureRect
		star.visible = index < level
		star.position = Vector2(start_x + index * (star_size + gap), floorf((row.size.y - star_size) * 0.5))
		star.size = Vector2(star_size, star_size)


func _render_creature_slot(index: int) -> void:
	if creature_data[index].is_empty():
		creature_sprites[index].texture = null
		creature_hp_badges[index].visible = false
		creature_special_badges[index].visible = false
		creature_level_labels[index].text = ""
		creature_star_rows[index].visible = false
		creature_hp_labels[index].text = ""
		creature_special_labels[index].text = ""
		creature_element_icons[index].visible = false
		creature_extra_trait_icons[index].visible = false
		creature_race_icons[index].visible = false
		creature_trait_backgrounds[index].visible = false
		return
	creature_hp_badges[index].visible = true
	creature_special_badges[index].visible = true
	creature_sprites[index].texture = load(creature_data[index]) as Texture2D
	var data_index := maxi(CREATURE_TEXTURES.find(creature_data[index]), 0)
	var level := clampi(creature_levels[index], 1, 3)
	creature_star_rows[index].visible = true
	_set_star_level(creature_star_rows[index], level)
	var hp_value := (20 + data_index * 3) * level
	var special_value := (5 + data_index * 2) * level
	creature_hp_labels[index].text = "%d" % hp_value
	creature_special_labels[index].text = "%d" % special_value
	_set_stat_badge_value(creature_hp_badges[index], hp_value, true)
	_set_stat_badge_value(creature_special_badges[index], special_value, false)
	var elements: PackedStringArray = CATALOG.elements_for_texture(creature_data[index])
	var races: PackedStringArray = CATALOG.races_for_texture(creature_data[index])
	creature_element_icons[index].texture = load(TRAIT_ICON_PATHS[elements[0]]) as Texture2D
	creature_race_icons[index].texture = load(TRAIT_ICON_PATHS[races[0]]) as Texture2D
	creature_extra_trait_icons[index].visible = elements.size() > 1
	if elements.size() > 1:
		creature_extra_trait_icons[index].texture = load(TRAIT_ICON_PATHS[elements[1]]) as Texture2D
	creature_element_icons[index].visible = true
	creature_race_icons[index].visible = true
	creature_trait_backgrounds[index].texture = _make_trait_background(elements)
	creature_trait_backgrounds[index].visible = true


func _render_shop_card(index: int) -> void:
	if shop_data[index].is_empty():
		shop_sprites[index].texture = null
		shop_sprites[index].visible = false
		shop_hp_badges[index].visible = false
		shop_special_badges[index].visible = false
		shop_level_labels[index].visible = false
		shop_star_rows[index].visible = false
		shop_sold_out_overlays[index].visible = true
		shop_lock_overlays[index].visible = shop_locked
		shop_detail_icons[index].visible = false
		shop_card_outlines[index].add_theme_stylebox_override("panel", _slot_style(Color(0, 0, 0, 0), Color("737983"), 3))
		shop_element_icons[index].visible = false
		shop_extra_trait_icons[index].visible = false
		shop_race_icons[index].visible = false
		shop_trait_backgrounds[index].visible = false
		shop_hp_labels[index].text = ""
		shop_special_labels[index].text = ""
		shop_name_labels[index].text = ""
		shop_price_labels[index].text = ""
		return
	var entry: Dictionary = shop_data[index]
	shop_sold_out_overlays[index].visible = false
	shop_lock_overlays[index].visible = shop_locked
	shop_detail_icons[index].visible = true
	var is_creature: bool = String(entry["kind"]) == "creature"
	var texture_path: String = entry["path"]
	var rarity_index := int(entry.get("rarity", CATALOG.rarity_for_texture(texture_path)))
	shop_card_outlines[index].add_theme_stylebox_override("panel", _slot_style(Color(0, 0, 0, 0), SHOP_RARITY_COLORS[clampi(rarity_index, 0, 2)], 3))
	shop_sprites[index].texture = load(texture_path) as Texture2D
	shop_sprites[index].visible = true
	shop_name_labels[index].text = _shop_entry_name(entry)
	shop_price_labels[index].text = "$%d" % int(entry["price"])
	shop_creature_overlays[index].visible = is_creature
	shop_attribute_layers[index].texture = load(SHOP_CARD_TEMPLATE_ASSET) as Texture2D
	shop_attribute_layers[index].modulate = Color.WHITE
	shop_outer_layers[index].visible = false
	shop_hp_badges[index].visible = false
	shop_special_badges[index].visible = false
	shop_level_labels[index].visible = false
	shop_star_rows[index].visible = is_creature
	if is_creature:
		_set_star_level(shop_star_rows[index], 1)
	shop_hp_labels[index].visible = false
	shop_special_labels[index].visible = false
	shop_element_icons[index].visible = false
	shop_extra_trait_icons[index].visible = false
	shop_race_icons[index].visible = false
	shop_trait_backgrounds[index].visible = false
	if not is_creature:
		shop_attribute_layers[index].modulate = Color.WHITE
		shop_element_icon_backgrounds[index].visible = false
		shop_extra_icon_backgrounds[index].visible = false
		shop_race_icon_backgrounds[index].visible = false
		shop_hp_labels[index].text = ""
		shop_special_labels[index].text = ""
		return
	var data_index := maxi(CREATURE_TEXTURES.find(texture_path), 0)
	var rarity_multiplier := CATALOG.RARITY_STAT_MULTIPLIERS[clampi(rarity_index, 0, 2)]
	shop_attribute_layers[index].modulate = Color.WHITE
	var hp_value := roundi((20 + data_index * 3) * rarity_multiplier)
	var special_value := roundi((5 + data_index * 2) * rarity_multiplier)
	shop_hp_labels[index].text = "%d" % hp_value
	shop_special_labels[index].text = "%d" % special_value
	_set_stat_badge_value(shop_hp_badges[index], hp_value, true)
	_set_stat_badge_value(shop_special_badges[index], special_value, false)
	var elements: PackedStringArray = CATALOG.elements_for_texture(texture_path)
	var races: PackedStringArray = CATALOG.races_for_texture(texture_path)
	shop_element_icons[index].texture = load(TRAIT_ICON_PATHS[elements[0]]) as Texture2D
	shop_race_icons[index].texture = load(TRAIT_ICON_PATHS[races[0]]) as Texture2D
	var secondary_trait := elements[1] if elements.size() > 1 else races[0]
	shop_extra_trait_icons[index].visible = true
	shop_extra_trait_icons[index].texture = load(TRAIT_ICON_PATHS[secondary_trait]) as Texture2D
	shop_element_icons[index].visible = true
	shop_race_icons[index].visible = false
	shop_trait_backgrounds[index].texture = _make_trait_background(elements)
	shop_trait_backgrounds[index].visible = true
	shop_element_icon_backgrounds[index].modulate = TRAIT_COLORS.get(elements[0], Color("737983"))
	shop_element_icon_backgrounds[index].visible = true
	shop_race_icon_backgrounds[index].modulate = TRAIT_COLORS.get(races[0], Color("737983"))
	shop_race_icon_backgrounds[index].visible = false
	shop_extra_icon_backgrounds[index].visible = true
	shop_extra_icon_backgrounds[index].modulate = TRAIT_COLORS.get(secondary_trait, Color("737983"))


func _update_selection() -> void:
	if selection_pulse_tween and selection_pulse_tween.is_valid():
		selection_pulse_tween.kill()
	for index in creature_buttons.size():
		creature_buttons[index].add_theme_stylebox_override("normal", _slot_style(Color(0, 0, 0, 0), Color(0, 0, 0, 0)))
		creature_masks[index].visible = false
		creature_selection_frames[index].visible = false
		creature_selection_frames[index].scale = Vector2.ONE
	if selected_slot >= 0 and selected_slot < creature_selection_frames.size():
		_show_creature_selection_frame(selected_slot)


func _show_creature_selection_frame(index: int) -> void:
	if index < 0 or index >= creature_selection_frames.size():
		return
	if index >= creature_data.size() or creature_data[index].is_empty():
		return
	if selection_pulse_tween and selection_pulse_tween.is_valid():
		selection_pulse_tween.kill()
	for frame in creature_selection_frames:
		frame.visible = false
		frame.scale = Vector2.ONE
	var frame := creature_selection_frames[index]
	frame.visible = true
	frame.scale = Vector2(0.94, 0.94)
	selection_pulse_tween = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	selection_pulse_tween.tween_property(frame, "scale", Vector2(1.035, 1.035), 0.48)
	selection_pulse_tween.tween_property(frame, "scale", Vector2(0.94, 0.94), 0.48)


func _hide_creature_selection_frame(index: int) -> void:
	if index < 0 or index >= creature_selection_frames.size():
		return
	if selected_slot == index:
		return
	if selection_pulse_tween and selection_pulse_tween.is_valid():
		selection_pulse_tween.kill()
	creature_selection_frames[index].visible = false
	creature_selection_frames[index].scale = Vector2.ONE


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


func _make_trait_background(traits: PackedStringArray) -> GradientTexture2D:
	var colors := PackedColorArray()
	var offsets := PackedFloat32Array()
	var valid_traits: Array[String] = []
	for trait_name in traits:
		if TRAIT_COLORS.has(trait_name):
			valid_traits.append(trait_name)
	if valid_traits.is_empty():
		valid_traits.append("自然")
	for index in valid_traits.size():
		var color: Color = TRAIT_COLORS[valid_traits[index]]
		var section_start := float(index) / float(valid_traits.size())
		var section_end := float(index + 1) / float(valid_traits.size())
		if index > 0:
			section_start += 0.002
		if index < valid_traits.size() - 1:
			section_end -= 0.002
		offsets.append(section_start)
		colors.append(color)
		offsets.append(section_end)
		colors.append(color)
	var gradient := Gradient.new()
	gradient.offsets = offsets
	gradient.colors = colors
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = 128
	texture.height = 128
	texture.fill = GradientTexture2D.FILL_LINEAR
	texture.fill_from = Vector2(0.0, 0.0)
	texture.fill_to = Vector2(1.0, 1.0)
	return texture


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
	label.add_theme_color_override("font_shadow_color", Color("d9dde3") if is_dark_text else Color("3b414b"))
	label.add_theme_constant_override("outline_size", 0)
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
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
