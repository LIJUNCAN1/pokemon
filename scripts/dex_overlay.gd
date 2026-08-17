extends Control

const SOURCE_HAN_FONT: FontFile = preload("res://assets/fonts/SourceHanSansSC-Heavy.otf")
const CATALOG = preload("res://scripts/creature_catalog.gd")
const ITEM_CATALOG = preload("res://scripts/item_catalog.gd")
const RARITY_TAG = preload("res://scripts/rarity_tag_style.gd")
const TRAINER_CATALOG = preload("res://scripts/trainer_catalog.gd")
const EQUIPMENT_CATALOG = preload("res://scripts/equipment_catalog.gd")
const BATTLE_RANGED_ICON := "res://素材/战斗场景/图层 3.png"
const BATTLE_MELEE_ICON := "res://素材/战斗场景/图层 4.png"
const DETAIL_TIME_ICON := "res://assets/ui/character_info/time.png"
const SOLID_ICON_TINT_SHADER: Shader = preload("res://shaders/solid_icon_tint.gdshader")
const DEX := "res://素材/图鉴/"
const POKEMON := "res://素材/宝可梦图/"
var CREATURES: Array[String] = []
var NAMES: Array[String] = []
const TAB_NAMES: Array[String] = ["怪兽", "饰品", "道具", "装备", "训练家"]
var TRAINER_TEXTURES: Array[String] = []
var TRAINER_IDS: Array[String] = TRAINER_CATALOG.ids()
var TRAINER_NAMES: Array[String] = []
var TRAINER_SKILLS: Array[String] = []

var source_han_font: FontFile
var tab_buttons: Array[Button] = []
var close_button: Button
var level_buttons: Array[Button] = []
var selected_level_index := 0
var monster_scroll: ScrollContainer
var monster_page: Control
var scroll_track: TextureRect
var scroll_thumb: TextureRect
var scroll_thumb_dragging := false
var empty_label: Label
var detail_root: Control
var detail_inner_panel: Panel
var detail_outer_frame: NinePatchRect
var detail_id: Label
var detail_sprite: TextureRect
var detail_sprite_shadow: Panel
var detail_name: Label
var detail_rarity: Label
var detail_type: Label
var detail_cooldown: Label
var detail_stats: Label
var detail_description: RichTextLabel
var detail_description_title: Label
var detail_unknown: Label
var detail_skill_panel: Panel
var detail_clock_icon: TextureRect
var detail_trait_panels: Array[Panel] = []
var detail_trait_icons: Array[TextureRect] = []
var detail_trait_labels: Array[Label] = []
var detail_role_panel: Panel
var detail_role_icon_backdrop: Panel
var detail_role_icon: TextureRect
var detail_active_label: Label
var detail_section_divider: ColorRect
var detail_achievement_panel: Panel
var detail_achievement_icons: Array[TextureRect] = []
var selection_frames: Array[Control] = []
var creature_cards: Array[Control] = []
var trainer_cards: Array[Control] = []
var trainer_selection_frames: Array[Control] = []
var trainer_sprites: Array[TextureRect] = []
var trainer_name_labels: Array[Label] = []
var accessory_entries: Array[Dictionary] = []
var item_entries: Array[Dictionary] = []
var equipment_entries: Array[Dictionary] = []
var accessory_cards: Array[Control] = []
var item_cards: Array[Control] = []
var equipment_cards: Array[Control] = []
var accessory_sprites: Array[TextureRect] = []
var item_sprites: Array[TextureRect] = []
var equipment_sprites: Array[TextureRect] = []
var accessory_name_labels: Array[Label] = []
var item_name_labels: Array[Label] = []
var equipment_name_labels: Array[Label] = []
var accessory_unknown_labels: Array[Label] = []
var item_unknown_labels: Array[Label] = []
var equipment_unknown_labels: Array[Label] = []
var accessory_rarity_labels: Array[Label] = []
var item_rarity_labels: Array[Label] = []
var equipment_rarity_labels: Array[Label] = []
var accessory_selection_frames: Array[Control] = []
var item_selection_frames: Array[Control] = []
var equipment_selection_frames: Array[Control] = []
var creature_detail_controls: Array[Control] = []
var card_creature_sprites: Array[TextureRect] = []
var card_name_labels: Array[Label] = []
var card_unknown_labels: Array[Label] = []
var card_trophy_icons: Array[TextureRect] = []
var card_medal_icons: Array[TextureRect] = []
var card_star_icons: Array[TextureRect] = []
var counter_labels: Array[Label] = []
var counter_help_buttons: Array[Button] = []
var counter_help_popup: Panel
var counter_help_text: Label
var sidebar_root: Control
var reference_shell: Panel
var collection_panel: Panel
var card_number_labels: Array[Label] = []
var selected_index := 0
var selected_accessory_index := 0
var selected_item_index := 0
var selected_equipment_index := 0
var selected_trainer_index := 0
var current_tab := 0
var trainer_dragging := false
var trainer_drag_last_x := 0.0
var trainer_drag_distance := 0.0
var trainer_drag_suppress_select := false


func _ready() -> void:
	for trainer in TRAINER_CATALOG.all():
		TRAINER_TEXTURES.append(String(trainer["dex_art"]))
		TRAINER_NAMES.append(String(trainer["name"]))
		TRAINER_SKILLS.append(String(trainer["description"]))
	set_meta("disable_text_shadow", true)
	if get_parent() is Control:
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	else:
		position = Vector2.ZERO
		size = Vector2(1280, 720)
		scale = Vector2(1.5, 1.5)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 150
	source_han_font = SOURCE_HAN_FONT.duplicate() as FontFile
	source_han_font.antialiasing = TextServer.FONT_ANTIALIASING_GRAY
	source_han_font.multichannel_signed_distance_field = true
	source_han_font.msdf_pixel_range = 8
	source_han_font.msdf_size = 64
	source_han_font.hinting = TextServer.HINTING_NORMAL
	source_han_font.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	source_han_font.oversampling = 1.5
	source_han_font.allow_system_fallback = false
	CREATURES = _sorted_creatures_by_rarity()
	NAMES.clear()
	for texture_path in CREATURES:
		NAMES.append(CATALOG.name_for_texture(texture_path))
	accessory_entries = _catalog_entries_by_rarity("accessory")
	item_entries = _catalog_entries_by_rarity("item")
	equipment_entries = EQUIPMENT_CATALOG.all()
	selected_index = _first_seen_creature_index()
	selected_accessory_index = _first_seen_entry_index(accessory_entries, "accessory")
	selected_item_index = _first_seen_entry_index(item_entries, "item")
	for equipment_index in equipment_entries.size():
		if GameState.has_seen_equipment(String(equipment_entries[equipment_index]["id"])):
			selected_equipment_index = equipment_index
			break
	_build_interface()
	refresh_data()


func _input(event: InputEvent) -> void:
	if scroll_thumb_dragging and event is InputEventMouseButton:
		var release_event := event as InputEventMouseButton
		if release_event.button_index == MOUSE_BUTTON_LEFT and not release_event.pressed:
			scroll_thumb_dragging = false
	if current_tab != 4:
		return
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			if mouse_event.pressed:
				var local_position := monster_scroll.get_global_transform_with_canvas().affine_inverse() * mouse_event.position
				if not Rect2(Vector2.ZERO, monster_scroll.size).has_point(local_position):
					return
				trainer_dragging = true
				trainer_drag_distance = 0.0
				trainer_drag_suppress_select = false
				trainer_drag_last_x = mouse_event.position.x
			else:
				trainer_dragging = false
				if trainer_drag_distance >= 8.0:
					trainer_drag_suppress_select = true
					_clear_trainer_drag_suppression.call_deferred()
			return
		if mouse_event.pressed and mouse_event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
			var direction := -1 if mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP else 1
			monster_scroll.scroll_horizontal = clampi(monster_scroll.scroll_horizontal + direction * 180, 0, int(monster_page.size.x - monster_scroll.size.x))
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and trainer_dragging:
		var motion := event as InputEventMouseMotion
		var delta_x := motion.position.x - trainer_drag_last_x
		trainer_drag_distance += absf(delta_x)
		monster_scroll.scroll_horizontal = clampi(monster_scroll.scroll_horizontal - roundi(delta_x), 0, int(monster_page.size.x - monster_scroll.size.x))
		trainer_drag_last_x = motion.position.x
		get_viewport().set_input_as_handled()


func _clear_trainer_drag_suppression() -> void:
	trainer_drag_suppress_select = false


func _build_interface() -> void:
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color("e9ecff")
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(shade)

	reference_shell = Panel.new()
	reference_shell.position = Vector2(16, 26)
	reference_shell.size = Vector2(1240, 566)
	reference_shell.add_theme_stylebox_override("panel", _rounded_panel(Color(0.985, 0.99, 1.0, 0.96), Color("d9ddf2"), 1, 22))
	add_child(reference_shell)

	_build_tabs()
	_build_collection_panel()
	_build_detail_panel()
	_build_counters()
	_remove_text_shadows(self)


func _build_detail_panel() -> void:
	detail_root = Control.new()
	detail_root.position = Vector2(860, 88)
	detail_root.size = Vector2(382, 495)
	add_child(detail_root)
	detail_inner_panel = Panel.new()
	detail_inner_panel.size = detail_root.size
	detail_inner_panel.add_theme_stylebox_override("panel", _rounded_panel(Color(0.985, 0.99, 1.0, 0.98), Color("d7dcef"), 1, 18))
	detail_root.add_child(detail_inner_panel)
	detail_outer_frame = _add_nine_patch(detail_root, DEX + "图鉴左栏_外框_九宫格.png", Rect2(Vector2.ZERO, detail_root.size), 8)
	# The source frame contains a rectangular white fill. The rounded runtime
	# panel above is the actual background; keep only that so no square white
	# corners protrude beyond the outer radius.
	detail_outer_frame.visible = false
	var id_badge := Panel.new()
	id_badge.position = Vector2(20, 14)
	id_badge.size = Vector2(54, 28)
	id_badge.add_theme_stylebox_override("panel", _rounded_panel(Color("f43e75"), Color.TRANSPARENT, 0, 10))
	detail_root.add_child(id_badge)
	detail_id = _add_label(id_badge, "001", Rect2(Vector2.ZERO, id_badge.size), 13, HORIZONTAL_ALIGNMENT_CENTER)
	var favorite := _add_label(detail_root, "☆", Rect2(330, 10, 34, 38), 28, HORIZONTAL_ALIGNMENT_CENTER)
	favorite.add_theme_color_override("font_color", Color("8e91ae"))

	detail_sprite_shadow = Panel.new()
	detail_sprite_shadow.position = Vector2(131, 183)
	detail_sprite_shadow.size = Vector2(120, 8)
	detail_sprite_shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	detail_sprite_shadow.add_theme_stylebox_override("panel", _rounded_panel(Color(0.18, 0.22, 0.32, 0.16), Color.TRANSPARENT, 0, 4))
	detail_root.add_child(detail_sprite_shadow)
	detail_sprite = _add_texture(detail_root, CREATURES[0], Rect2(76, 38, 230, 158))
	detail_unknown = _add_label(detail_root, "?", Rect2(76, 38, 230, 158), 42, HORIZONTAL_ALIGNMENT_CENTER)
	_use_dark_text(detail_unknown)
	detail_unknown.visible = false
	detail_name = _add_label(detail_root, "", Rect2(20, 194, 342, 30), 18, HORIZONTAL_ALIGNMENT_CENTER)
	detail_rarity = _add_label(detail_root, "", Rect2(312, 20, 54, 28), 12, HORIZONTAL_ALIGNMENT_CENTER)
	detail_rarity.add_theme_color_override("font_color", Color.WHITE)
	detail_rarity.add_theme_stylebox_override("normal", _rounded_panel(Color("a78bea"), Color.TRANSPARENT, 0, 10))
	_use_dark_text(detail_name)
	detail_type = _add_label(detail_root, "", Rect2(20, 254, 342, 28), 12, HORIZONTAL_ALIGNMENT_CENTER)
	_use_dark_text(detail_type)
	for trait_index in 2:
		var trait_panel := Panel.new()
		trait_panel.position = Vector2(118 + trait_index * 78, 226)
		trait_panel.size = Vector2(70, 28)
		detail_root.add_child(trait_panel)
		var trait_icon := _add_texture(trait_panel, CATALOG.synergy_icon_path("自然"), Rect2(5, 4, 20, 20))
		var trait_icon_material := ShaderMaterial.new()
		trait_icon_material.shader = SOLID_ICON_TINT_SHADER
		trait_icon_material.set_shader_parameter("tint_color", Color.WHITE)
		trait_icon.material = trait_icon_material
		var trait_label := _add_label(trait_panel, "", Rect2(26, 1, 41, 26), 10, HORIZONTAL_ALIGNMENT_CENTER)
		trait_label.add_theme_color_override("font_color", Color.WHITE)
		detail_trait_panels.append(trait_panel)
		detail_trait_icons.append(trait_icon)
		detail_trait_labels.append(trait_label)
	detail_description = RichTextLabel.new()
	detail_description.position = Vector2(92, 309)
	detail_description.size = Vector2(250, 50)
	detail_description.bbcode_enabled = true
	detail_description.fit_content = false
	detail_description.scroll_active = false
	detail_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_description.add_theme_font_override("normal_font", source_han_font)
	detail_description.add_theme_font_size_override("normal_font_size", 10)
	detail_description.add_theme_color_override("default_color", Color("202127"))
	detail_description.mouse_filter = Control.MOUSE_FILTER_IGNORE
	detail_root.add_child(detail_description)
	detail_description_title = _add_label(detail_root, "技能描述", Rect2(92, 277, 210, 28), 13)
	_use_dark_text(detail_description_title)
	detail_description_title.add_theme_color_override("font_color", Color("e53e60"))
	detail_role_panel = Panel.new()
	detail_role_panel.position = Vector2(20, 276)
	detail_role_panel.size = Vector2(58, 82)
	detail_role_panel.add_theme_stylebox_override("panel", _rounded_panel(Color.TRANSPARENT, Color.TRANSPARENT, 0, 10))
	detail_root.add_child(detail_role_panel)
	detail_role_icon_backdrop = Panel.new()
	detail_role_icon_backdrop.position = Vector2(4, 0)
	detail_role_icon_backdrop.size = Vector2(50, 50)
	detail_role_icon_backdrop.add_theme_stylebox_override("panel", _rounded_panel(Color("ef4168"), Color("ffb4c4"), 1, 25))
	detail_role_panel.add_child(detail_role_icon_backdrop)
	detail_role_icon = _add_texture(detail_role_panel, BATTLE_RANGED_ICON, Rect2(6, 2, 46, 46))
	var role_icon_material := ShaderMaterial.new()
	role_icon_material.shader = SOLID_ICON_TINT_SHADER
	role_icon_material.set_shader_parameter("tint_color", Color.WHITE)
	detail_role_icon.material = role_icon_material
	detail_active_label = _add_label(detail_role_panel, "主动技能", Rect2(1, 54, 56, 20), 9, HORIZONTAL_ALIGNMENT_CENTER)
	detail_active_label.add_theme_color_override("font_color", Color("e53e60"))
	detail_active_label.add_theme_stylebox_override("normal", _rounded_panel(Color("ffe1e6"), Color.TRANSPARENT, 0, 6))
	detail_section_divider = _add_color(detail_root, Color("d9dbea"), Rect2(20, 370, 342, 1))
	detail_skill_panel = Panel.new()
	detail_skill_panel.position = Vector2(20, 410)
	detail_skill_panel.size = Vector2(342, 64)
	detail_skill_panel.add_theme_stylebox_override("panel", _rounded_panel(Color("f7f7fb"), Color("dfe1ec"), 1, 12))
	detail_root.add_child(detail_skill_panel)
	detail_clock_icon = _add_texture(detail_skill_panel, DETAIL_TIME_ICON, Rect2(2, 8, 20, 20))
	detail_cooldown = _add_label(detail_skill_panel, "", Rect2(12, 4, 72, 56), 12, HORIZONTAL_ALIGNMENT_CENTER)
	detail_stats = _add_label(detail_skill_panel, "", Rect2(92, 4, 238, 56), 11)
	_use_dark_text(detail_cooldown)
	_use_dark_text(detail_stats)
	detail_achievement_panel = Panel.new()
	detail_achievement_panel.position = Vector2(20, 400)
	detail_achievement_panel.size = Vector2(342, 76)
	detail_achievement_panel.add_theme_stylebox_override("panel", _rounded_panel(Color(1, 1, 1, 0.76), Color("e1e3ef"), 1, 14))
	detail_root.add_child(detail_achievement_panel)
	var achievement_paths := [
		DEX + "image-1785683743659-hcg3y7d2ca2.png",
		DEX + "image-1785683749088-mt9x4axmxfo2.png",
		DEX + "image-1785683749811-6btmw25d8ow2.png",
	]
	for achievement_index in 3:
		var achievement_icon := _add_texture(detail_achievement_panel, achievement_paths[achievement_index], Rect2(42 + achievement_index * 103, 17, 42, 42))
		detail_achievement_icons.append(achievement_icon)

	for index in 4:
		var button := _create_level_button(index)
		creature_detail_controls.append(button)
		button.pressed.connect(_on_level_pressed.bind(index))
		level_buttons.append(button)
		button.visible = false
	_update_level_buttons()


func _build_sidebar() -> void:
	sidebar_root = Control.new()
	sidebar_root.position = Vector2(12, 16)
	sidebar_root.size = Vector2(244, 676)
	add_child(sidebar_root)
	var panel := Panel.new()
	panel.size = sidebar_root.size
	panel.add_theme_stylebox_override("panel", _rounded_panel(Color(0.985, 0.985, 1.0, 0.98), Color("d7d8e6"), 2, 22))
	sidebar_root.add_child(panel)
	var title := _add_label(sidebar_root, "▣  图鉴浏览", Rect2(22, 18, 200, 40), 18)
	_use_dark_text(title)
	var progress_box := Panel.new()
	progress_box.position = Vector2(16, 82)
	progress_box.size = Vector2(212, 214)
	progress_box.add_theme_stylebox_override("panel", _rounded_panel(Color("f7f5fb"), Color.TRANSPARENT, 0, 14))
	sidebar_root.add_child(progress_box)
	var progress_title := _add_label(progress_box, "⚑  发现进度", Rect2(14, 10, 180, 30), 13)
	_use_dark_text(progress_title)
	var labels := ["🏆  已发现", "★  闪光发现", "●  已捕获"]
	for index in 3:
		var row := _add_label(progress_box, labels[index], Rect2(14, 48 + index * 48, 120, 36), 12)
		_use_dark_text(row)
		_add_color(progress_box, Color("e1e2ec"), Rect2(12, 88 + index * 48, 188, 1))
	var filter_box := Panel.new()
	filter_box.position = Vector2(16, 322)
	filter_box.size = Vector2(212, 302)
	filter_box.add_theme_stylebox_override("panel", _rounded_panel(Color("f7f5fb"), Color.TRANSPARENT, 0, 14))
	sidebar_root.add_child(filter_box)
	var filter_title := _add_label(filter_box, "⚑  筛选与设置", Rect2(14, 12, 180, 30), 13)
	_use_dark_text(filter_title)
	var sort := Button.new()
	sort.position = Vector2(12, 56)
	sort.size = Vector2(188, 42)
	sort.text = "编号升序        ▾"
	sort.add_theme_font_override("font", source_han_font)
	sort.add_theme_font_size_override("font_size", 11)
	sort.add_theme_stylebox_override("normal", _rounded_panel(Color.WHITE, Color("dedfea"), 1, 9))
	filter_box.add_child(sort)
	var grid_mode := _add_label(filter_box, "▦       ☷", Rect2(12, 112, 188, 40), 22, HORIZONTAL_ALIGNMENT_CENTER)
	grid_mode.add_theme_color_override("font_color", Color("ed3e70"))
	var level_title := _add_label(filter_box, "图鉴等级", Rect2(14, 160, 160, 26), 12)
	_use_dark_text(level_title)
	_add_label(filter_box, "Lv1    Lv2    Lv3    Lv4", Rect2(12, 194, 188, 38), 12, HORIZONTAL_ALIGNMENT_CENTER).add_theme_color_override("font_color", Color("6c6f91"))
	_add_color(filter_box, Color("e1e2ec"), Rect2(12, 248, 188, 1))
	var shiny := _add_label(filter_box, "✦  闪光筛选                 ○", Rect2(14, 260, 184, 28), 11)
	_use_dark_text(shiny)


func _build_tabs() -> void:
	var tab_positions := [Vector2(34, 39), Vector2(180, 39), Vector2(326, 39), Vector2(472, 39), Vector2(618, 39)]
	for index in 5:
		var button := Button.new()
		button.position = tab_positions[index]
		button.size = Vector2(138, 35)
		button.text = TAB_NAMES[index]
		button.focus_mode = Control.FOCUS_NONE
		button.add_theme_font_override("font", source_han_font)
		button.add_theme_font_size_override("font_size", 15)
		button.add_theme_color_override("font_color", Color("333451"))
		button.add_theme_color_override("font_hover_color", Color("333451"))
		button.add_theme_color_override("font_disabled_color", Color.WHITE)
		button.add_theme_stylebox_override("normal", _rounded_panel(Color(1, 1, 1, 0.90), Color("dfe2ef"), 1, 11))
		button.add_theme_stylebox_override("hover", _rounded_panel(Color("f6f4fb"), Color("dfe2ef"), 1, 11))
		button.add_theme_stylebox_override("pressed", _rounded_panel(Color("ef3f72"), Color.TRANSPARENT, 0, 11))
		button.add_theme_stylebox_override("disabled", _rounded_panel(Color("ef3f72"), Color.TRANSPARENT, 0, 11))
		add_child(button)
		button.pressed.connect(_on_tab_pressed.bind(index))
		tab_buttons.append(button)
	close_button = Button.new()
	close_button.position = Vector2(1189, 36)
	close_button.size = Vector2(42, 42)
	close_button.text = "×"
	close_button.focus_mode = Control.FOCUS_NONE
	close_button.add_theme_font_override("font", source_han_font)
	close_button.add_theme_font_size_override("font_size", 28)
	close_button.add_theme_color_override("font_color", Color("73769b"))
	close_button.add_theme_color_override("font_hover_color", Color("73769b"))
	close_button.add_theme_color_override("font_pressed_color", Color.WHITE)
	var close_style := _rounded_panel(Color.WHITE, Color.TRANSPARENT, 0, 21)
	var close_pressed_style := _rounded_panel(Color("85899b"), Color.TRANSPARENT, 0, 21)
	close_button.add_theme_stylebox_override("normal", close_style)
	close_button.add_theme_stylebox_override("hover", close_style)
	close_button.add_theme_stylebox_override("pressed", close_pressed_style)
	close_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	close_button.pressed.connect(_close)
	add_child(close_button)


func _build_collection_panel() -> void:
	collection_panel = Panel.new()
	collection_panel.position = Vector2(25, 85)
	collection_panel.size = Vector2(821, 500)
	collection_panel.add_theme_stylebox_override("panel", _rounded_panel(Color(0.99, 0.99, 1.0, 0.96), Color("d8dced"), 1, 16))
	add_child(collection_panel)
	monster_scroll = ScrollContainer.new()
	monster_scroll.position = Vector2(37, 99)
	monster_scroll.size = Vector2(797, 474)
	monster_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	monster_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	monster_scroll.clip_contents = true
	add_child(monster_scroll)
	monster_page = Control.new()
	monster_page.custom_minimum_size = Vector2(780, 588)
	monster_page.size = monster_page.custom_minimum_size
	monster_scroll.add_child(monster_page)
	for index in CREATURES.size():
		var column := index % 4
		var row := index / 4
		_create_creature_card(index, Rect2(0 + column * 195, 0 + row * 147, 186, 134))
	for index in accessory_entries.size():
		_create_item_card("accessory", index, _collection_card_rect(index))
	for index in item_entries.size():
		_create_item_card("item", index, _collection_card_rect(index))
	for index in equipment_entries.size():
		_create_item_card("equipment", index, _collection_card_rect(index))
	for index in TRAINER_TEXTURES.size():
		_create_trainer_card(index, Rect2(10 + index * 354, 8, 338, 438))

	var native_scrollbar := monster_scroll.get_v_scroll_bar()
	native_scrollbar.modulate.a = 0.02
	native_scrollbar.mouse_filter = Control.MOUSE_FILTER_STOP
	native_scrollbar.value_changed.connect(_on_collection_scrolled)
	var horizontal_scrollbar := monster_scroll.get_h_scroll_bar()
	horizontal_scrollbar.mouse_filter = Control.MOUSE_FILTER_STOP
	horizontal_scrollbar.custom_minimum_size.y = 12
	horizontal_scrollbar.add_theme_stylebox_override("scroll", _rounded_panel(Color("d9dceb"), Color.TRANSPARENT, 0, 5))
	horizontal_scrollbar.add_theme_stylebox_override("grabber", _rounded_panel(Color("777a9e"), Color.TRANSPARENT, 0, 5))
	horizontal_scrollbar.add_theme_stylebox_override("grabber_highlight", _rounded_panel(Color("ef3f72"), Color.TRANSPARENT, 0, 5))
	horizontal_scrollbar.add_theme_stylebox_override("grabber_pressed", _rounded_panel(Color("d93465"), Color.TRANSPARENT, 0, 5))
	scroll_track = _add_texture(self, DEX + "1.png", Rect2(834, 99, 8, 466), TextureRect.STRETCH_SCALE)
	scroll_thumb = _add_atlas_texture(self, DEX + "2.png", Rect2(835, 101, 6, 76), Rect2(5, 173, 7, 44))
	scroll_thumb.mouse_filter = Control.MOUSE_FILTER_STOP
	scroll_thumb.gui_input.connect(_on_scroll_thumb_gui_input)
	_update_scroll_thumb()

	empty_label = _add_label(self, "", Rect2(120, 310, 640, 80), 20, HORIZONTAL_ALIGNMENT_CENTER)
	_use_dark_text(empty_label)
	empty_label.visible = false


func _create_creature_card(index: int, rect: Rect2) -> void:
	var card := Control.new()
	card.position = rect.position
	card.size = rect.size
	monster_page.add_child(card)
	creature_cards.append(card)
	var card_panel := Panel.new()
	card_panel.size = rect.size
	card_panel.add_theme_stylebox_override("panel", _rounded_panel(Color("fbfbfe"), Color("dedfeb"), 1, 12))
	card.add_child(card_panel)
	var number := _add_label(card, "%03d" % (index + 1), Rect2(12, 6, 52, 22), 11)
	number.add_theme_color_override("font_color", Color("777a9e"))
	card_number_labels.append(number)
	var creature_sprite := _add_texture(card, CREATURES[index], Rect2(28, 22, 130, 82))
	var unknown_label := _add_label(card, "?", Rect2(28, 22, 130, 82), 32, HORIZONTAL_ALIGNMENT_CENTER)
	_use_dark_text(unknown_label)
	# Achievement marks are intentionally kept only as hidden data targets so
	# refresh logic remains compatible; the revised cards show a centered image.
	var trophy := _add_texture(card, DEX + "image-1785683743659-hcg3y7d2ca2.png", Rect2(0, 0, 0, 0))
	var medal := _add_texture(card, DEX + "image-1785683749088-mt9x4axmxfo2.png", Rect2(0, 0, 0, 0))
	var star := _add_texture(card, DEX + "image-1785683749811-6btmw25d8ow2.png", Rect2(0, 0, 0, 0))
	trophy.visible = false
	medal.visible = false
	star.visible = false
	var name_label := _add_label(card, "?", Rect2(12, 108, 162, 22), 10, HORIZONTAL_ALIGNMENT_CENTER)
	_use_dark_text(name_label)
	card_creature_sprites.append(creature_sprite)
	card_unknown_labels.append(unknown_label)
	card_trophy_icons.append(trophy)
	card_medal_icons.append(medal)
	card_star_icons.append(star)
	card_name_labels.append(name_label)
	var selection := _create_card_selection(card, rect.size)
	selection.visible = index == selected_index
	selection_frames.append(selection)
	var hit := Button.new()
	hit.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hit.flat = true
	hit.focus_mode = Control.FOCUS_NONE
	hit.tooltip_text = ""
	hit.pressed.connect(_select_creature.bind(index))
	card.add_child(hit)


func _create_item_card(kind: String, index: int, rect: Rect2) -> void:
	var entries := accessory_entries if kind == "accessory" else (item_entries if kind == "item" else equipment_entries)
	var entry: Dictionary = entries[index]
	var card := Control.new()
	card.position = rect.position
	card.size = rect.size
	card.visible = false
	monster_page.add_child(card)
	var card_panel := Panel.new()
	card_panel.size = rect.size
	card_panel.add_theme_stylebox_override("panel", _rounded_panel(Color("fbfbfe"), Color("dedfeb"), 1, 12))
	card.add_child(card_panel)
	_add_label(card, "%03d" % (index + 1), Rect2(12, 6, 52, 22), 11).add_theme_color_override("font_color", Color("777a9e"))
	var sprite := _add_texture(card, String(entry["path"]), Rect2(28, 22, 130, 82))
	var unknown_label := _add_label(card, "?", Rect2(28, 22, 130, 82), 32, HORIZONTAL_ALIGNMENT_CENTER)
	_use_dark_text(unknown_label)
	var rarity := clampi(int(entry.get("rarity", 0)), 0, ITEM_CATALOG.RARITY_NAMES.size() - 1)
	var rarity_label := _add_label(card, ITEM_CATALOG.RARITY_NAMES[rarity], Rect2(124, 6, 50, 22), 9, HORIZONTAL_ALIGNMENT_RIGHT)
	rarity_label.add_theme_color_override("font_color", _item_rarity_color(rarity))
	var name_label := _add_label(card, "?", Rect2(12, 108, 162, 22), 10, HORIZONTAL_ALIGNMENT_CENTER)
	_use_dark_text(name_label)
	var selection := _create_card_selection(card, rect.size)
	selection.visible = false
	var hit := Button.new()
	hit.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hit.flat = true
	hit.focus_mode = Control.FOCUS_NONE
	hit.tooltip_text = ""
	hit.pressed.connect(_select_item_entry.bind(kind, index))
	card.add_child(hit)
	if kind == "accessory":
		accessory_cards.append(card)
		accessory_sprites.append(sprite)
		accessory_unknown_labels.append(unknown_label)
		accessory_name_labels.append(name_label)
		accessory_rarity_labels.append(rarity_label)
		accessory_selection_frames.append(selection)
	elif kind == "item":
		item_cards.append(card)
		item_sprites.append(sprite)
		item_unknown_labels.append(unknown_label)
		item_name_labels.append(name_label)
		item_rarity_labels.append(rarity_label)
		item_selection_frames.append(selection)
	else:
		equipment_cards.append(card)
		equipment_sprites.append(sprite)
		equipment_unknown_labels.append(unknown_label)
		equipment_name_labels.append(name_label)
		equipment_rarity_labels.append(rarity_label)
		equipment_selection_frames.append(selection)


func _create_trainer_card(index: int, rect: Rect2) -> void:
	var card := Control.new()
	card.position = rect.position
	card.size = rect.size
	card.visible = false
	monster_page.add_child(card)
	trainer_cards.append(card)
	var card_panel := Panel.new()
	card_panel.size = rect.size
	card_panel.add_theme_stylebox_override("panel", _rounded_panel(Color("fbfbfe"), Color("dedfeb"), 1, 12))
	card.add_child(card_panel)
	var trainer_sprite := _add_texture(card, TRAINER_TEXTURES[index], Rect2(8, 6, rect.size.x - 16, rect.size.y - 48))
	var name_label := _add_label(card, TRAINER_NAMES[index], Rect2(10, rect.size.y - 38, rect.size.x - 20, 28), 14, HORIZONTAL_ALIGNMENT_CENTER)
	_use_dark_text(name_label)
	var selection := _create_card_selection(card, rect.size)
	selection.visible = index == 0
	trainer_selection_frames.append(selection)
	trainer_sprites.append(trainer_sprite)
	trainer_name_labels.append(name_label)
	var hit := Button.new()
	hit.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hit.flat = true
	hit.focus_mode = Control.FOCUS_NONE
	hit.tooltip_text = ""
	hit.pressed.connect(_select_trainer.bind(index))
	card.add_child(hit)


func _apply_creature_detail_layout(creature_mode: bool) -> void:
	detail_type.visible = not creature_mode
	for trait_panel in detail_trait_panels:
		trait_panel.visible = creature_mode
	detail_role_panel.visible = creature_mode
	detail_achievement_panel.visible = creature_mode
	detail_clock_icon.visible = creature_mode
	if creature_mode:
		detail_description_title.add_theme_color_override("font_color", Color("e53e60"))
		detail_sprite.position = Vector2(76, 38)
		detail_sprite.size = Vector2(230, 158)
		detail_name.position = Vector2(20, 194)
		detail_name.size = Vector2(342, 30)
		detail_rarity.position = Vector2(312, 20)
		detail_rarity.size = Vector2(54, 28)
		detail_description_title.position = Vector2(92, 277)
		detail_description_title.size = Vector2(196, 28)
		detail_description.position = Vector2(92, 309)
		detail_description.size = Vector2(196, 54)
		detail_section_divider.position = Vector2(20, 370)
		detail_skill_panel.position = Vector2(296, 276)
		detail_skill_panel.size = Vector2(66, 82)
		detail_skill_panel.add_theme_stylebox_override("panel", _rounded_panel(Color.TRANSPARENT, Color.TRANSPARENT, 0, 0))
		detail_clock_icon.position = Vector2(0, 17)
		detail_clock_icon.size = Vector2(20, 20)
		detail_cooldown.position = Vector2(23, 8)
		detail_cooldown.size = Vector2(43, 38)
		detail_stats.visible = false
	else:
		detail_description_title.add_theme_color_override("font_color", Color("202127"))
		detail_sprite.position = Vector2(82, 38)
		detail_sprite.size = Vector2(218, 155)
		detail_name.position = Vector2(20, 194)
		detail_name.size = Vector2(342, 32)
		detail_rarity.position = Vector2(148, 226)
		detail_rarity.size = Vector2(86, 26)
		detail_description_title.position = Vector2(22, 292)
		detail_description_title.size = Vector2(180, 26)
		detail_description.position = Vector2(22, 320)
		detail_description.size = Vector2(338, 66)
		detail_section_divider.position = Vector2(20, 396)
		detail_skill_panel.position = Vector2(20, 410)
		detail_skill_panel.size = Vector2(342, 64)
		detail_skill_panel.add_theme_stylebox_override("panel", _rounded_panel(Color("f7f7fb"), Color("dfe1ec"), 1, 12))
		detail_cooldown.position = Vector2(12, 4)
		detail_cooldown.size = Vector2(72, 56)
		detail_stats.position = Vector2(92, 4)
		detail_stats.size = Vector2(238, 56)
		detail_stats.visible = true


func _select_trainer(index: int) -> void:
	if trainer_drag_suppress_select:
		return
	selected_trainer_index = clampi(index, 0, TRAINER_TEXTURES.size() - 1)
	detail_id.text = "%03d" % (selected_trainer_index + 1)
	_apply_creature_detail_layout(false)
	detail_skill_panel.visible = true
	var unlocked := GameState.has_unlocked_trainer(TRAINER_IDS[selected_trainer_index])
	detail_sprite.texture = load(TRAINER_TEXTURES[selected_trainer_index]) as Texture2D
	detail_unknown.visible = false
	_set_silhouette(detail_sprite, not unlocked)
	detail_name.text = TRAINER_NAMES[selected_trainer_index] if unlocked else "未解锁"
	detail_rarity.add_theme_color_override("font_color", Color.WHITE)
	detail_rarity.text = "训练家" if unlocked else "未解锁"
	detail_rarity.add_theme_stylebox_override("normal", _rounded_panel(Color("8d8fa0"), Color.TRANSPARENT, 0, 9))
	detail_type.text = "训练家" if unlocked else "未知"
	detail_cooldown.text = TRAINER_CATALOG.skill_type_name(TRAINER_IDS[selected_trainer_index]) if unlocked else "--"
	detail_stats.text = "训练家能力" if unlocked else "尚未相遇"
	detail_description_title.text = "%s描述" % TRAINER_CATALOG.skill_type_name(TRAINER_IDS[selected_trainer_index]).trim_suffix("技能")
	detail_description.text = TRAINER_SKILLS[selected_trainer_index] if unlocked else "在新游戏中选择该训练家后解锁资料"
	for frame_index in trainer_selection_frames.size():
		trainer_selection_frames[frame_index].visible = frame_index == selected_trainer_index


func _select_item_entry(kind: String, index: int) -> void:
	var entries := accessory_entries if kind == "accessory" else (item_entries if kind == "item" else equipment_entries)
	if entries.is_empty():
		return
	index = clampi(index, 0, entries.size() - 1)
	if kind == "accessory":
		selected_accessory_index = index
	elif kind == "item":
		selected_item_index = index
	else:
		selected_equipment_index = index
	var entry: Dictionary = entries[index]
	detail_id.text = "%03d" % (index + 1)
	_apply_creature_detail_layout(false)
	# Item/accessory pages intentionally omit the legacy bottom "-- / 未知"
	# status box. Their useful information is already in the effect section.
	detail_skill_panel.visible = false
	var seen := GameState.has_seen_equipment(String(entry["id"])) if kind == "equipment" else GameState.has_seen_item(entry, kind)
	detail_description_title.text = "效果描述"
	var frames := accessory_selection_frames if kind == "accessory" else (item_selection_frames if kind == "item" else equipment_selection_frames)
	for frame_index in frames.size():
		frames[frame_index].visible = frame_index == index
	if not seen:
		detail_sprite.texture = load(String(entry["path"])) as Texture2D
		_set_silhouette(detail_sprite, true)
		detail_unknown.visible = false
		detail_name.text = "未解锁"
		detail_rarity.add_theme_color_override("font_color", Color.WHITE)
		detail_rarity.text = "未发现"
		detail_rarity.add_theme_stylebox_override("normal", _rounded_panel(Color("a6a8b2"), Color.TRANSPARENT, 0, 9))
		detail_type.text = "饰品" if kind == "accessory" else ("道具" if kind == "item" else "装备")
		detail_cooldown.text = "--"
		detail_stats.text = "未知"
		detail_description.text = "获得后解锁详细信息"
		return
	detail_sprite.texture = load(String(entry["path"])) as Texture2D
	_set_silhouette(detail_sprite, false)
	detail_unknown.visible = false
	detail_name.text = String(entry["name"])
	var rarity := clampi(int(entry.get("rarity", 0)), 0, ITEM_CATALOG.RARITY_NAMES.size() - 1)
	RARITY_TAG.apply(detail_rarity, _item_rarity_tag_index(rarity))
	detail_type.text = "饰品" if kind == "accessory" else ("道具" if kind == "item" else "装备")
	detail_cooldown.text = "%dG\n价格" % int(entry.get("price", 0))
	detail_stats.text = "持有时生效" if kind == "accessory" else ("使用后生效" if kind == "item" else "装备后对单个角色生效")
	detail_description.text = String(entry.get("effect", "暂无效果说明"))


func _build_counters() -> void:
	var positions := [Vector2(21, 607), Vector2(431, 607), Vector2(840, 607)]
	var titles := ["图鉴收集", "解锁成就", "闪光图鉴"]
	var icons := [DEX + "image-1785683743659-hcg3y7d2ca.png", DEX + "image-1785683749088-mt9x4axmxfo.png", DEX + "image-1785683749811-6btmw25d8ow.png"]
	var texts := ["0/%d" % CREATURES.size(), "0/%d" % CREATURES.size(), "0/%d" % CREATURES.size()]
	for index in 3:
		var panel := Panel.new()
		panel.position = positions[index]
		panel.size = Vector2(393, 83)
		panel.add_theme_stylebox_override("panel", _rounded_panel(Color(1, 1, 1, 0.92), Color("d9ddf0"), 1, 16))
		add_child(panel)
		_add_texture(panel, icons[index], Rect2(22, 16, 48, 48))
		var title := _add_label(panel, titles[index], Rect2(88, 14, 190, 24), 12)
		_use_dark_text(title)
		var counter := _add_label(panel, texts[index], Rect2(88, 39, 86, 26), 13)
		_use_dark_text(counter)
		counter_labels.append(counter)
		var progress_bg := ColorRect.new()
		progress_bg.position = Vector2(168, 52)
		progress_bg.size = Vector2(146, 6)
		progress_bg.color = Color("e1e4f2")
		progress_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(progress_bg)
		var help := Button.new()
		help.position = Vector2(334, 24)
		help.size = Vector2(34, 34)
		help.text = "?"
		help.focus_mode = Control.FOCUS_NONE
		help.add_theme_font_override("font", source_han_font)
		help.add_theme_font_size_override("font_size", 18)
		help.add_theme_color_override("font_color", Color.WHITE)
		help.add_theme_color_override("font_hover_color", Color.WHITE)
		help.add_theme_color_override("font_pressed_color", Color.WHITE)
		help.add_theme_stylebox_override("normal", _rounded_panel(Color("ffbd36"), Color.TRANSPARENT, 0, 8))
		help.add_theme_stylebox_override("hover", _rounded_panel(Color("ffc94f"), Color.TRANSPARENT, 0, 8))
		help.add_theme_stylebox_override("pressed", _rounded_panel(Color("e8a626"), Color.TRANSPARENT, 0, 8))
		help.pressed.connect(_show_counter_help.bind(index))
		panel.add_child(help)
		counter_help_buttons.append(help)
	counter_help_popup = Panel.new()
	counter_help_popup.position = Vector2(440, 526)
	counter_help_popup.size = Vector2(400, 66)
	counter_help_popup.z_index = 40
	counter_help_popup.mouse_filter = Control.MOUSE_FILTER_STOP
	counter_help_popup.add_theme_stylebox_override("panel", _rounded_panel(Color(0.98, 0.985, 1.0, 0.99), Color("bfc4dc"), 1, 12))
	add_child(counter_help_popup)
	counter_help_text = _add_label(counter_help_popup, "", Rect2(18, 8, 364, 50), 11, HORIZONTAL_ALIGNMENT_CENTER)
	_use_dark_text(counter_help_text)
	counter_help_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	counter_help_popup.visible = false


func _show_counter_help(index: int) -> void:
	var descriptions := [
		"图鉴收集：记录已经发现过的怪兽数量。",
		"解锁成就：记录已经完成图鉴成就的怪兽数量。",
		"闪光图鉴：记录已经发现闪光形态的怪兽数量。",
	]
	index = clampi(index, 0, descriptions.size() - 1)
	counter_help_text.text = descriptions[index]
	counter_help_popup.position.x = clampf(21.0 + index * 409.0, 21.0, 840.0)
	counter_help_popup.visible = true


func _select_creature(index: int) -> void:
	selected_index = index
	detail_id.text = "%03d" % (index + 1)
	_apply_creature_detail_layout(true)
	detail_skill_panel.visible = true
	detail_description_title.text = "技能描述"
	detail_rarity.add_theme_color_override("font_color", Color.WHITE)
	if not GameState.has_seen_creature(CREATURES[index]):
		detail_sprite.texture = load(CREATURES[index]) as Texture2D
		_set_silhouette(detail_sprite, true)
		detail_unknown.visible = false
		detail_name.text = "未解锁"
		detail_rarity.text = "未发现"
		detail_rarity.add_theme_color_override("font_color", Color.WHITE)
		detail_rarity.add_theme_stylebox_override("normal", _rounded_panel(Color("a6a8b2"), Color.TRANSPARENT, 0, 9))
		detail_type.text = "未知"
		detail_cooldown.text = "--\n秒"
		detail_stats.text = "未知"
		detail_description_title.text = "技能尚未解锁"
		detail_description.text = "该技能的详细效果尚未解锁。"
		for trait_index in detail_trait_panels.size():
			detail_trait_panels[trait_index].add_theme_stylebox_override("panel", _rounded_panel(Color("a6a8b2"), Color.TRANSPARENT, 0, 5))
			detail_trait_labels[trait_index].text = "?"
			detail_trait_icons[trait_index].visible = false
		for frame_index in selection_frames.size():
			selection_frames[frame_index].visible = frame_index == index
		return
	detail_sprite.texture = load(CREATURES[index]) as Texture2D
	_set_silhouette(detail_sprite, false)
	detail_unknown.visible = false
	detail_name.text = NAMES[index]
	var rarity := clampi(CATALOG.rarity_for_texture(CREATURES[index]), 0, CATALOG.RARITY_NAMES.size() - 1)
	RARITY_TAG.apply(detail_rarity, rarity)
	var elements: PackedStringArray = CATALOG.elements_for_texture(CREATURES[index])
	var races: PackedStringArray = CATALOG.races_for_texture(CREATURES[index])
	var element_text := "/".join(elements)
	var race_text := races[0] if not races.is_empty() else "未知"
	detail_type.text = "%s·%s" % [element_text, race_text]
	var shown_traits: Array[String] = [String(elements[0]) if not elements.is_empty() else "未知", race_text]
	for trait_index in detail_trait_panels.size():
		var trait_name := shown_traits[trait_index]
		var trait_color := CATALOG.synergy_color(trait_name)
		detail_trait_panels[trait_index].add_theme_stylebox_override("panel", _rounded_panel(trait_color, Color.TRANSPARENT, 0, 5))
		detail_trait_labels[trait_index].text = trait_name
		detail_trait_icons[trait_index].texture = load(CATALOG.synergy_icon_path(trait_name)) as Texture2D
		detail_trait_icons[trait_index].visible = true
	detail_cooldown.text = "攻击间隔\n%.1f 秒" % (CATALOG.cooldown_for_texture(CREATURES[index]) / CATALOG.rarity_charge_multiplier(CREATURES[index]))
	_refresh_creature_level_stats()
	var damage := CATALOG.damage_range_for_texture(CREATURES[index])
	var maximum_damage := roundi(damage.y * CATALOG.rarity_stat_multiplier(CREATURES[index]))
	detail_description_title.text = "%s：最高 %d 点伤害" % [CATALOG.skill_name_for_texture(CREATURES[index]), maximum_damage]
	detail_description.text = _skill_detail_bbcode(CATALOG.skill_detail_for_texture(CREATURES[index]), CATALOG.synergy_color(shown_traits[0]))
	var attack_range := String(CATALOG.data_for_texture(CREATURES[index]).get("range", "ranged"))
	detail_role_icon.texture = load(BATTLE_RANGED_ICON if attack_range == "ranged" else BATTLE_MELEE_ICON) as Texture2D
	var mask := GameState.creature_achievement_mask(CREATURES[index])
	var unlocked_paths := [
		DEX + "image-1785683743659-hcg3y7d2ca.png",
		DEX + "image-1785683749088-mt9x4axmxfo.png",
		DEX + "image-1785683749811-6btmw25d8ow.png",
	]
	var locked_paths := [
		DEX + "image-1785683743659-hcg3y7d2ca2.png",
		DEX + "image-1785683749088-mt9x4axmxfo2.png",
		DEX + "image-1785683749811-6btmw25d8ow2.png",
	]
	for achievement_index in detail_achievement_icons.size():
		var unlocked := bool(mask & (1 << achievement_index))
		detail_achievement_icons[achievement_index].texture = load(unlocked_paths[achievement_index] if unlocked else locked_paths[achievement_index]) as Texture2D
	for frame_index in selection_frames.size():
		selection_frames[frame_index].visible = frame_index == index


func _on_tab_pressed(index: int) -> void:
	current_tab = index
	for button_index in tab_buttons.size():
		tab_buttons[button_index].disabled = button_index == index
	monster_page.visible = true
	for card in creature_cards:
		card.visible = index == 0
	for card in accessory_cards:
		card.visible = index == 1
	for card in item_cards:
		card.visible = index == 2
	for card in equipment_cards:
		card.visible = index == 3
	for card in trainer_cards:
		card.visible = index == 4
	empty_label.visible = false
	for control in creature_detail_controls:
		control.visible = false
	match index:
		0:
			_set_collection_page_height(CREATURES.size())
			_select_creature(selected_index)
		1:
			_set_collection_page_height(accessory_entries.size())
			_select_item_entry("accessory", selected_accessory_index)
		2:
			_set_collection_page_height(item_entries.size())
			_select_item_entry("item", selected_item_index)
		3:
			_set_collection_page_height(equipment_entries.size())
			_select_item_entry("equipment", selected_equipment_index)
		_:
			monster_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
			monster_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
			monster_page.custom_minimum_size = Vector2(maxf(780.0, 20.0 + TRAINER_TEXTURES.size() * 354.0), 455.0)
			monster_page.size = monster_page.custom_minimum_size
			monster_page.update_minimum_size()
			_select_trainer(selected_trainer_index)
	if scroll_track != null:
		scroll_track.visible = index != 4
	if scroll_thumb != null:
		scroll_thumb.visible = index != 4
	_update_counters()
	monster_scroll.scroll_vertical = 0
	if index != 4:
		monster_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		monster_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
		monster_scroll.scroll_horizontal = 0


func _on_collection_scrolled(_value: float) -> void:
	_update_scroll_thumb()


func _update_scroll_thumb() -> void:
	if scroll_thumb == null or monster_scroll == null or current_tab == 4:
		return
	var bar := monster_scroll.get_v_scroll_bar()
	var scroll_range := maxf(bar.max_value - bar.page, 1.0)
	var ratio := clampf(bar.value / scroll_range, 0.0, 1.0)
	scroll_thumb.position.y = 101.0 + ratio * 388.0


func _on_scroll_thumb_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		scroll_thumb_dragging = (event as InputEventMouseButton).pressed
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and scroll_thumb_dragging:
		var motion := event as InputEventMouseMotion
		scroll_thumb.position.y = clampf(scroll_thumb.position.y + motion.relative.y, 101.0, 489.0)
		var ratio := (scroll_thumb.position.y - 101.0) / 388.0
		var bar := monster_scroll.get_v_scroll_bar()
		bar.value = ratio * maxf(bar.max_value - bar.page, 0.0)
		get_viewport().set_input_as_handled()


func _on_level_pressed(level_index: int) -> void:
	if current_tab != 0:
		return
	if not GameState.has_seen_creature(CREATURES[selected_index]):
		return
	selected_level_index = clampi(level_index, 0, level_buttons.size() - 1)
	_update_level_buttons()
	_refresh_creature_level_stats()


func _refresh_creature_level_stats() -> void:
	if selected_index < 0 or selected_index >= CREATURES.size():
		return
	var texture_path := CREATURES[selected_index]
	var level := selected_level_index + 1
	var multiplier := CATALOG.rarity_stat_multiplier(texture_path) * level
	var hp := roundi(CATALOG.base_hp_for_texture(texture_path) * multiplier)
	var damage := CATALOG.damage_range_for_texture(texture_path)
	detail_stats.text = "Lv%d  生命 %d\n伤害 %d-%d" % [level, hp, roundi(damage.x * multiplier), roundi(damage.y * multiplier)]


func _create_level_button(index: int) -> Button:
	var button := Button.new()
	button.position = Vector2(20 + index * 61, 612)
	button.size = Vector2(54, 34)
	button.text = "Lv%d" % (index + 1)
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_override("font", source_han_font)
	button.add_theme_font_size_override("font_size", 12)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color.WHITE)
	button.add_theme_color_override("font_disabled_color", Color.WHITE)
	button.add_theme_stylebox_override("normal", _panel_style(Color("77787c"), Color("34343a"), 3))
	button.add_theme_stylebox_override("hover", _panel_style(Color("8b8c91"), Color("34343a"), 3))
	button.add_theme_stylebox_override("pressed", _panel_style(Color("d9325c"), Color("34343a"), 3))
	detail_root.add_child(button)
	return button


func _update_level_buttons() -> void:
	for index in level_buttons.size():
		var button := level_buttons[index]
		var selected := index == selected_level_index
		button.disabled = selected
		button.add_theme_stylebox_override("disabled", _panel_style(Color("ef3f68"), Color("34343a"), 3))


func refresh_data() -> void:
	for entry in GameState.accessory_inventory:
		GameState.mark_item_seen(entry, "accessory")
	for entry in GameState.item_inventory:
		GameState.mark_item_seen(entry, "item")
	var trophy_count := 0
	var medal_count := 0
	var star_count := 0
	var seen_count := 0
	var owned_count := 0
	for index in CREATURES.size():
		var seen := GameState.has_seen_creature(CREATURES[index])
		var mask := GameState.creature_achievement_mask(CREATURES[index])
		var progress := GameState.creature_progress_for(CREATURES[index])
		seen_count += 1 if seen else 0
		owned_count += 1 if bool(progress.get("owned", false)) else 0
		card_creature_sprites[index].visible = true
		_set_silhouette(card_creature_sprites[index], not seen)
		card_unknown_labels[index].visible = false
		card_name_labels[index].text = NAMES[index] if seen else "未解锁"
		card_trophy_icons[index].texture = load(DEX + ("image-1785683743659-hcg3y7d2ca.png" if mask & GameState.ACHIEVEMENT_TROPHY else "image-1785683743659-hcg3y7d2ca2.png")) as Texture2D
		card_medal_icons[index].texture = load(DEX + ("image-1785683749088-mt9x4axmxfo.png" if mask & GameState.ACHIEVEMENT_MEDAL else "image-1785683749088-mt9x4axmxfo2.png")) as Texture2D
		card_star_icons[index].texture = load(DEX + ("image-1785683749811-6btmw25d8ow.png" if mask & GameState.ACHIEVEMENT_STAR else "image-1785683749811-6btmw25d8ow2.png")) as Texture2D
		trophy_count += 1 if mask & GameState.ACHIEVEMENT_TROPHY else 0
		medal_count += 1 if mask & GameState.ACHIEVEMENT_MEDAL else 0
		star_count += 1 if mask & GameState.ACHIEVEMENT_STAR else 0
	if counter_labels.size() == 3:
		counter_labels[0].text = "%d/%d" % [seen_count, CREATURES.size()]
		counter_labels[1].text = "%d/%d" % [star_count, CREATURES.size()]
		counter_labels[2].text = "%d/%d" % [owned_count, CREATURES.size()]
	for index in accessory_entries.size():
		var seen_accessory := GameState.has_seen_item(accessory_entries[index], "accessory")
		accessory_sprites[index].visible = true
		_set_silhouette(accessory_sprites[index], not seen_accessory)
		accessory_unknown_labels[index].visible = false
		accessory_name_labels[index].text = String(accessory_entries[index]["name"]) if seen_accessory else "未解锁"
		accessory_rarity_labels[index].visible = seen_accessory
	for index in item_entries.size():
		var seen_item := GameState.has_seen_item(item_entries[index], "item")
		item_sprites[index].visible = true
		_set_silhouette(item_sprites[index], not seen_item)
		item_unknown_labels[index].visible = false
		item_name_labels[index].text = String(item_entries[index]["name"]) if seen_item else "未解锁"
		item_rarity_labels[index].visible = seen_item
	for index in equipment_entries.size():
		var seen_equipment := GameState.has_seen_equipment(String(equipment_entries[index]["id"]))
		equipment_sprites[index].visible = true
		_set_silhouette(equipment_sprites[index], not seen_equipment)
		equipment_unknown_labels[index].visible = false
		equipment_name_labels[index].text = String(equipment_entries[index]["name"]) if seen_equipment else "未解锁"
		equipment_rarity_labels[index].visible = seen_equipment
	for index in TRAINER_TEXTURES.size():
		var unlocked := GameState.has_unlocked_trainer(TRAINER_IDS[index])
		_set_silhouette(trainer_sprites[index], not unlocked)
		trainer_name_labels[index].text = TRAINER_NAMES[index] if unlocked else "未解锁"
	_update_counters()
	_on_tab_pressed(current_tab)


func _update_counters() -> void:
	if counter_labels.size() != 3:
		return
	if current_tab in [1, 2, 3]:
		var kind := "accessory" if current_tab == 1 else ("item" if current_tab == 2 else "equipment")
		var entries := accessory_entries if current_tab == 1 else (item_entries if current_tab == 2 else equipment_entries)
		for rarity in 3:
			var total := 0
			var seen := 0
			for entry in entries:
				if int(entry.get("rarity", 0)) != rarity:
					continue
				total += 1
				seen += 1 if (GameState.has_seen_equipment(String(entry["id"])) if kind == "equipment" else GameState.has_seen_item(entry, kind)) else 0
			counter_labels[rarity].text = "%d/%d" % [seen, total]
		return
	var seen_count := 0
	var shiny_count := 0
	var owned_count := 0
	for path in CREATURES:
		seen_count += 1 if GameState.has_seen_creature(path) else 0
		shiny_count += 1 if GameState.creature_achievement_mask(path) & GameState.ACHIEVEMENT_STAR else 0
		owned_count += 1 if bool(GameState.creature_progress_for(path).get("owned", false)) else 0
	counter_labels[0].text = "%d/%d" % [seen_count, CREATURES.size()]
	counter_labels[1].text = "%d/%d" % [shiny_count, CREATURES.size()]
	counter_labels[2].text = "%d/%d" % [owned_count, CREATURES.size()]


func _catalog_entries(kind: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var ids: Array = ITEM_CATALOG.ACCESSORY_IDS if kind == "accessory" else ITEM_CATALOG.CONSUMABLE_IDS
	for id in ids:
		result.append(ITEM_CATALOG.entry_for_id(kind, int(id)))
	return result


func _sorted_creatures_by_rarity() -> Array[String]:
	var result: Array[String] = []
	var catalog_paths: Array[String] = CATALOG.all_textures()
	for rarity in range(CATALOG.RARITY_NAMES.size() - 1, -1, -1):
		for texture_path in catalog_paths:
			if CATALOG.rarity_for_texture(texture_path) == rarity:
				result.append(texture_path)
	return result


func _catalog_entries_by_rarity(kind: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var entries := _catalog_entries(kind)
	for rarity in range(ITEM_CATALOG.RARITY_NAMES.size() - 1, -1, -1):
		for entry in entries:
			if int(entry.get("rarity", 0)) == rarity:
				result.append(entry)
	return result


func _first_seen_creature_index() -> int:
	for index in CREATURES.size():
		if GameState.has_seen_creature(CREATURES[index]):
			return index
	return 0


func _first_seen_entry_index(entries: Array[Dictionary], kind: String) -> int:
	for index in entries.size():
		if GameState.has_seen_item(entries[index], kind):
			return index
	return 0


func _collection_card_rect(index: int) -> Rect2:
	var column := index % 4
	var row := index / 4
	return Rect2(column * 195, row * 147, 186, 134)


func _create_card_selection(card: Control, card_size: Vector2) -> Panel:
	var selection := Panel.new()
	selection.position = Vector2(1, 1)
	selection.size = card_size - Vector2(2, 2)
	selection.mouse_filter = Control.MOUSE_FILTER_IGNORE
	selection.add_theme_stylebox_override("panel", _rounded_panel(Color.TRANSPARENT, Color("f43e75"), 2, 12))
	card.add_child(selection)
	return selection


func _set_collection_page_height(entry_count: int) -> void:
	var rows := maxi(1, ceili(float(entry_count) / 4.0))
	monster_page.custom_minimum_size = Vector2(780, maxf(428.0, rows * 147.0))
	monster_page.size = monster_page.custom_minimum_size


func _item_rarity_color(rarity: int) -> Color:
	return [Color("d7dce4"), Color("55c6e8"), Color("d084ff")][clampi(rarity, 0, 2)]


func _item_rarity_tag_index(rarity: int) -> int:
	return [0, 2, 3][clampi(rarity, 0, 2)]


func _skill_detail_bbcode(text: String, element_color: Color) -> String:
	var value_pattern := RegEx.new()
	value_pattern.compile("([+-]?\\d+(?:\\.\\d+)?%?|\\d+\\s*秒|\\d+\\s*层)")
	return value_pattern.sub(text, "[color=#%s]$1[/color]" % element_color.to_html(false), true)


func _creature_rarity_color(rarity: int) -> Color:
	# Keep the codex identical to the canonical rarity palette used by shop
	# cards and the right-click character panel.
	return [Color("b8bdc5"), Color("58b85f"), Color("3e95d8"), Color("c45ad9"), Color("e3a62f")][clampi(rarity, 0, 4)]


func _set_silhouette(texture: TextureRect, locked: bool) -> void:
	if texture == null:
		return
	# Multiplying RGB by zero preserves every source alpha pixel, producing an
	# exact black silhouette instead of a rectangular black placeholder.
	texture.self_modulate = Color(0, 0, 0, 1) if locked else Color.WHITE


func _close() -> void:
	visible = false


func _add_texture(parent: Control, path: String, rect: Rect2, stretch := TextureRect.STRETCH_KEEP_ASPECT_CENTERED) -> TextureRect:
	var texture := TextureRect.new()
	texture.position = rect.position
	texture.size = rect.size
	texture.texture = load(path) as Texture2D
	texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture.stretch_mode = stretch
	texture.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(texture)
	return texture


func _add_atlas_texture(parent: Control, path: String, rect: Rect2, region: Rect2) -> TextureRect:
	var atlas := AtlasTexture.new()
	atlas.atlas = load(path) as Texture2D
	atlas.region = region
	var texture := TextureRect.new()
	texture.position = rect.position
	texture.size = rect.size
	texture.texture = atlas
	texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture.stretch_mode = TextureRect.STRETCH_SCALE
	texture.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(texture)
	return texture


func _add_texture_button(path: String, rect: Rect2, tooltip: String, parent: Control = null) -> TextureButton:
	var button := TextureButton.new()
	button.position = rect.position
	button.size = rect.size
	button.texture_normal = load(path) as Texture2D
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_SCALE
	button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	button.tooltip_text = ""
	(parent if parent != null else self).add_child(button)
	return button


func _add_color(parent: Control, color: Color, rect: Rect2) -> ColorRect:
	var panel := ColorRect.new()
	panel.position = rect.position
	panel.size = rect.size
	panel.color = color
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(panel)
	return panel


func _add_nine_patch(parent: Control, path: String, rect: Rect2, margin: int) -> NinePatchRect:
	var frame := NinePatchRect.new()
	frame.position = rect.position
	frame.size = rect.size
	frame.texture = load(path) as Texture2D
	frame.patch_margin_left = margin
	frame.patch_margin_top = margin
	frame.patch_margin_right = margin
	frame.patch_margin_bottom = margin
	frame.axis_stretch_horizontal = NinePatchRect.AXIS_STRETCH_MODE_STRETCH
	frame.axis_stretch_vertical = NinePatchRect.AXIS_STRETCH_MODE_STRETCH
	frame.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(frame)
	return frame


func _add_info_frame(parent: Control, rect: Rect2) -> NinePatchRect:
	_add_color(parent, Color(0.99, 0.99, 0.99, 1.0), rect)
	return _add_nine_patch(parent, DEX + "图鉴左栏_信息框_九宫格.png", rect, 14)


func _configure_dex_button(button: Button, font_size: int) -> void:
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_override("font", source_han_font)
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", Color("4d5072"))
	button.add_theme_color_override("font_hover_color", Color("4d5072"))
	button.add_theme_color_override("font_pressed_color", Color("4d5072"))
	button.add_theme_stylebox_override("normal", _rounded_panel(Color(1, 1, 1, 0.90), Color("e0e3ef"), 1, 9))
	button.add_theme_stylebox_override("hover", _rounded_panel(Color("f8f6fc"), Color("d8dced"), 1, 9))
	button.add_theme_stylebox_override("pressed", _rounded_panel(Color("f2eff8"), Color("d8dced"), 1, 9))


func _remove_text_shadows(node: Node) -> void:
	if node is Label or node is Button:
		var control := node as Control
		control.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
		control.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		control.add_theme_constant_override("outline_size", 0)
		control.add_theme_constant_override("shadow_offset_x", 0)
		control.add_theme_constant_override("shadow_offset_y", 0)
	for child in node.get_children():
		_remove_text_shadows(child)


func _add_label(parent: Control, text: String, rect: Rect2, font_size: int, alignment := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := Label.new()
	label.position = rect.position
	label.size = rect.size
	label.text = text
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", source_han_font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	label.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
	label.add_theme_constant_override("outline_size", 0)
	label.add_theme_constant_override("shadow_offset_x", 0)
	label.add_theme_constant_override("shadow_offset_y", 0)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label


func _use_dark_text(label: Label) -> void:
	label.add_theme_color_override("font_color", Color("202127"))
	label.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	label.add_theme_color_override("font_outline_color", Color.TRANSPARENT)


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


func _rounded_panel(fill: Color, border: Color, width: int, radius: int) -> StyleBoxFlat:
	var style := _panel_style(fill, border, width)
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	return style
