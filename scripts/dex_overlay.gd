extends Control

const SOURCE_HAN_FONT: FontFile = preload("res://assets/fonts/SourceHanSansSC-Heavy.otf")
const CATALOG = preload("res://scripts/creature_catalog.gd")
const ITEM_CATALOG = preload("res://scripts/item_catalog.gd")
const DEX := "res://素材/图鉴/"
const POKEMON := "res://素材/宝可梦图/"
var CREATURES: Array[String] = []
var NAMES: Array[String] = []
const TAB_NAMES: Array[String] = ["怪兽", "饰品", "道具", "训练家"]
const INACTIVE_TABS: Array[String] = [DEX + "03_切图_3.png", DEX + "03_切图_3.png", DEX + "04_切图_4.png", DEX + "05_切图_5.png"]
const TRAINER_TEXTURES: Array[String] = [
	"res://assets/characters/trainers/trainer_green.png",
	"res://assets/characters/trainers/trainer_red.png",
	"res://assets/characters/trainers/trainer_yellow.png",
]
const TRAINER_IDS: Array[String] = ["researcher", "vanguard", "scout"]
const TRAINER_NAMES: Array[String] = ["森野博士", "赤城", "紫苑"]
const TRAINER_SKILLS: Array[String] = [
	"野外补给：初始金币 +2",
	"斗志昂扬：本轮全队伤害 +6%",
	"可靠伙伴：初始获得一只普通怪兽",
]

var source_han_font: FontFile
var tab_buttons: Array[TextureButton] = []
var level_buttons: Array[Button] = []
var selected_level_index := 0
var monster_scroll: ScrollContainer
var monster_page: Control
var scroll_thumb: TextureRect
var empty_label: Label
var detail_root: Control
var detail_outer_frame: NinePatchRect
var detail_sprite: TextureRect
var detail_name: Label
var detail_rarity: Label
var detail_type: Label
var detail_cooldown: Label
var detail_stats: Label
var detail_description: Label
var detail_unknown: Label
var selection_frames: Array[TextureRect] = []
var creature_cards: Array[Control] = []
var trainer_cards: Array[Control] = []
var trainer_selection_frames: Array[TextureRect] = []
var trainer_sprites: Array[TextureRect] = []
var trainer_name_labels: Array[Label] = []
var accessory_entries: Array[Dictionary] = []
var item_entries: Array[Dictionary] = []
var accessory_cards: Array[Control] = []
var item_cards: Array[Control] = []
var accessory_sprites: Array[TextureRect] = []
var item_sprites: Array[TextureRect] = []
var accessory_name_labels: Array[Label] = []
var item_name_labels: Array[Label] = []
var accessory_unknown_labels: Array[Label] = []
var item_unknown_labels: Array[Label] = []
var accessory_rarity_labels: Array[Label] = []
var item_rarity_labels: Array[Label] = []
var accessory_selection_frames: Array[TextureRect] = []
var item_selection_frames: Array[TextureRect] = []
var creature_detail_controls: Array[Control] = []
var card_creature_sprites: Array[TextureRect] = []
var card_name_labels: Array[Label] = []
var card_unknown_labels: Array[Label] = []
var card_trophy_icons: Array[TextureRect] = []
var card_medal_icons: Array[TextureRect] = []
var card_star_icons: Array[TextureRect] = []
var counter_labels: Array[Label] = []
var selected_index := 0
var selected_accessory_index := 0
var selected_item_index := 0
var selected_trainer_index := 0
var current_tab := 0


func _ready() -> void:
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
	selected_index = _first_seen_creature_index()
	selected_accessory_index = _first_seen_entry_index(accessory_entries, "accessory")
	selected_item_index = _first_seen_entry_index(item_entries, "item")
	_build_interface()
	refresh_data()


func _build_interface() -> void:
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.025, 0.045, 0.07, 0.96)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(shade)

	var outer := Panel.new()
	outer.position = Vector2(4, 42)
	outer.size = Vector2(1272, 635)
	outer.add_theme_stylebox_override("panel", _panel_style(Color(0.96, 0.96, 0.95), Color(0.23, 0.23, 0.24), 4))
	add_child(outer)

	_build_detail_panel()
	_build_tabs()
	_build_collection_panel()
	_build_counters()


func _build_detail_panel() -> void:
	detail_root = Control.new()
	detail_root.position = Vector2(8, 48)
	detail_root.size = Vector2(300, 613)
	add_child(detail_root)
	_add_color(detail_root, Color(0.98, 0.98, 0.98, 1.0), Rect2(Vector2.ZERO, detail_root.size))
	detail_outer_frame = _add_nine_patch(detail_root, DEX + "图鉴左栏_外框_九宫格.png", Rect2(Vector2.ZERO, detail_root.size), 8)
	_add_color(detail_root, Color("d77d00"), Rect2(8, 8, 284, 35))
	detail_name = _add_label(detail_root, "", Rect2(16, 12, 150, 26), 14)
	detail_rarity = _add_label(detail_root, "稀有", Rect2(198, 12, 84, 26), 13, HORIZONTAL_ALIGNMENT_RIGHT)

	_add_info_frame(detail_root, Rect2(8, 49, 284, 160))
	_add_info_frame(detail_root, Rect2(20, 61, 112, 136))
	detail_sprite = _add_texture(detail_root, CREATURES[0], Rect2(30, 72, 92, 112))
	detail_unknown = _add_label(detail_root, "?", Rect2(30, 72, 92, 112), 42, HORIZONTAL_ALIGNMENT_CENTER)
	_use_dark_text(detail_unknown)
	detail_unknown.visible = false
	_add_texture(detail_root, DEX + "图层 5（合并）.png", Rect2(166, 105, 96, 37), TextureRect.STRETCH_SCALE)
	detail_type = _add_label(detail_root, "", Rect2(166, 109, 96, 28), 13, HORIZONTAL_ALIGNMENT_CENTER)

	_add_info_frame(detail_root, Rect2(8, 217, 284, 102))
	_add_info_frame(detail_root, Rect2(20, 229, 78, 78))
	detail_cooldown = _add_label(detail_root, "", Rect2(26, 238, 66, 60), 14, HORIZONTAL_ALIGNMENT_CENTER)
	detail_stats = _add_label(detail_root, "", Rect2(112, 240, 158, 56), 14, HORIZONTAL_ALIGNMENT_CENTER)
	_use_dark_text(detail_cooldown)
	_use_dark_text(detail_stats)

	_add_info_frame(detail_root, Rect2(8, 327, 284, 110))
	detail_description = _add_label(detail_root, "", Rect2(22, 340, 256, 84), 13, HORIZONTAL_ALIGNMENT_CENTER)
	_use_dark_text(detail_description)
	detail_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	creature_detail_controls.append(_add_info_frame(detail_root, Rect2(8, 445, 284, 36)))
	var shift_hint := _add_label(detail_root, "SHIFT  长按查看更多信息", Rect2(18, 449, 264, 28), 12)
	creature_detail_controls.append(shift_hint)
	_use_dark_text(shift_hint)

	for index in 4:
		var button := _create_level_button(index)
		creature_detail_controls.append(button)
		button.pressed.connect(_on_level_pressed.bind(index))
		level_buttons.append(button)
	_update_level_buttons()
	creature_detail_controls.append(_add_texture(detail_root, DEX + "24_切图_24.png", Rect2(27, 560, 264, 37), TextureRect.STRETCH_SCALE))
	creature_detail_controls.append(_add_label(detail_root, "闪光", Rect2(27, 563, 264, 28), 13, HORIZONTAL_ALIGNMENT_CENTER))


func _build_tabs() -> void:
	for index in 4:
		var button := _add_texture_button(DEX + ("02_切图_2.png" if index == 0 else "%02d_切图_%d.png" % [index + 2, index + 2]), Rect2(397 + index * 208, 48, 199, 43), TAB_NAMES[index])
		button.pressed.connect(_on_tab_pressed.bind(index))
		tab_buttons.append(button)
		_add_label(self, TAB_NAMES[index], Rect2(397 + index * 208, 50, 199, 36), 23, HORIZONTAL_ALIGNMENT_CENTER)
	var close := _add_texture_button(DEX + "06_切图_6.png", Rect2(1228, 48, 43, 43), "关闭")
	close.pressed.connect(_close)


func _build_collection_panel() -> void:
	_add_color(self, Color(0.99, 0.99, 0.99, 1.0), Rect2(317, 101, 953, 500))
	monster_scroll = ScrollContainer.new()
	monster_scroll.position = Vector2(326, 109)
	monster_scroll.size = Vector2(908, 484)
	monster_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	monster_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	monster_scroll.clip_contents = true
	add_child(monster_scroll)
	monster_page = Control.new()
	monster_page.custom_minimum_size = Vector2(892, 690)
	monster_page.size = monster_page.custom_minimum_size
	monster_scroll.add_child(monster_page)
	for index in CREATURES.size():
		var column := index % 4
		var row := index / 4
		_create_creature_card(index, Rect2(12 + column * 221, 10 + row * 171, 205, 152))
	for index in accessory_entries.size():
		_create_item_card("accessory", index, _collection_card_rect(index))
	for index in item_entries.size():
		_create_item_card("item", index, _collection_card_rect(index))
	for index in TRAINER_TEXTURES.size():
		_create_trainer_card(index, Rect2(12 + index * 221, 10, 205, 152))

	var native_scrollbar := monster_scroll.get_v_scroll_bar()
	native_scrollbar.modulate.a = 0.0
	native_scrollbar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	native_scrollbar.value_changed.connect(_on_collection_scrolled)
	_add_nine_patch(self, DEX + "图鉴右栏_外框_前景.png", Rect2(317, 101, 953, 500), 14)
	_add_texture(self, DEX + "1.png", Rect2(1243, 113, 16, 474), TextureRect.STRETCH_SCALE)
	scroll_thumb = _add_atlas_texture(self, DEX + "2.png", Rect2(1248, 118, 7, 82), Rect2(5, 173, 7, 44))
	_update_scroll_thumb()

	empty_label = _add_label(self, "", Rect2(430, 295, 730, 80), 20, HORIZONTAL_ALIGNMENT_CENTER)
	_use_dark_text(empty_label)
	empty_label.visible = false


func _create_creature_card(index: int, rect: Rect2) -> void:
	var card := Control.new()
	card.position = rect.position
	card.size = rect.size
	monster_page.add_child(card)
	creature_cards.append(card)
	_add_texture(card, DEX + "13_切图_13.png", Rect2(Vector2.ZERO, rect.size), TextureRect.STRETCH_SCALE)
	var creature_sprite := _add_texture(card, CREATURES[index], Rect2(18, 15, 125, 98))
	var unknown_label := _add_label(card, "?", Rect2(18, 15, 125, 98), 36, HORIZONTAL_ALIGNMENT_CENTER)
	_use_dark_text(unknown_label)
	var trophy := _add_texture(card, DEX + "image-1785683743659-hcg3y7d2ca2.png", Rect2(151, 16, 32, 32))
	var medal := _add_texture(card, DEX + "image-1785683749088-mt9x4axmxfo2.png", Rect2(154, 55, 27, 32))
	var star := _add_texture(card, DEX + "image-1785683749811-6btmw25d8ow2.png", Rect2(153, 96, 29, 29))
	var name_label := _add_label(card, "?", Rect2(12, 115, 132, 28), 12, HORIZONTAL_ALIGNMENT_CENTER)
	_use_dark_text(name_label)
	card_creature_sprites.append(creature_sprite)
	card_unknown_labels.append(unknown_label)
	card_trophy_icons.append(trophy)
	card_medal_icons.append(medal)
	card_star_icons.append(star)
	card_name_labels.append(name_label)
	var selection := _add_texture(card, DEX + "image-1785681904517-raawndjoah.png", Rect2(2, 2, rect.size.x - 4, rect.size.y - 4), TextureRect.STRETCH_SCALE)
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
	var entries := accessory_entries if kind == "accessory" else item_entries
	var entry: Dictionary = entries[index]
	var card := Control.new()
	card.position = rect.position
	card.size = rect.size
	card.visible = false
	monster_page.add_child(card)
	_add_texture(card, DEX + "13_切图_13.png", Rect2(Vector2.ZERO, rect.size), TextureRect.STRETCH_SCALE)
	var sprite := _add_texture(card, String(entry["path"]), Rect2(24, 12, 112, 104))
	var unknown_label := _add_label(card, "?", Rect2(24, 12, 112, 104), 36, HORIZONTAL_ALIGNMENT_CENTER)
	_use_dark_text(unknown_label)
	var rarity := clampi(int(entry.get("rarity", 0)), 0, ITEM_CATALOG.RARITY_NAMES.size() - 1)
	var rarity_label := _add_label(card, ITEM_CATALOG.RARITY_NAMES[rarity], Rect2(144, 18, 48, 24), 11, HORIZONTAL_ALIGNMENT_CENTER)
	rarity_label.add_theme_color_override("font_color", _item_rarity_color(rarity))
	var name_label := _add_label(card, "?", Rect2(12, 116, 181, 28), 12, HORIZONTAL_ALIGNMENT_CENTER)
	_use_dark_text(name_label)
	var selection := _add_texture(card, DEX + "image-1785681904517-raawndjoah.png", Rect2(2, 2, rect.size.x - 4, rect.size.y - 4), TextureRect.STRETCH_SCALE)
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
	else:
		item_cards.append(card)
		item_sprites.append(sprite)
		item_unknown_labels.append(unknown_label)
		item_name_labels.append(name_label)
		item_rarity_labels.append(rarity_label)
		item_selection_frames.append(selection)


func _create_trainer_card(index: int, rect: Rect2) -> void:
	var card := Control.new()
	card.position = rect.position
	card.size = rect.size
	card.visible = false
	monster_page.add_child(card)
	trainer_cards.append(card)
	_add_texture(card, DEX + "13_切图_13.png", Rect2(Vector2.ZERO, rect.size), TextureRect.STRETCH_SCALE)
	var trainer_sprite := _add_texture(card, TRAINER_TEXTURES[index], Rect2(26, 13, 153, 108))
	var name_label := _add_label(card, TRAINER_NAMES[index], Rect2(16, 116, 173, 28), 14, HORIZONTAL_ALIGNMENT_CENTER)
	_use_dark_text(name_label)
	var selection := _add_texture(card, DEX + "image-1785681904517-raawndjoah.png", Rect2(2, 2, rect.size.x - 4, rect.size.y - 4), TextureRect.STRETCH_SCALE)
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


func _select_trainer(index: int) -> void:
	selected_trainer_index = clampi(index, 0, TRAINER_TEXTURES.size() - 1)
	var unlocked := GameState.has_unlocked_trainer(TRAINER_IDS[selected_trainer_index])
	detail_sprite.texture = load(TRAINER_TEXTURES[selected_trainer_index]) as Texture2D
	detail_unknown.visible = false
	_set_silhouette(detail_sprite, not unlocked)
	detail_name.text = TRAINER_NAMES[selected_trainer_index] if unlocked else "未解锁"
	detail_rarity.add_theme_color_override("font_color", Color.WHITE)
	detail_rarity.text = "训练家" if unlocked else "未解锁"
	detail_type.text = "训练家" if unlocked else "未知"
	detail_cooldown.text = "被动" if unlocked else "--"
	detail_stats.text = "训练家能力" if unlocked else "尚未相遇"
	detail_description.text = TRAINER_SKILLS[selected_trainer_index] if unlocked else "在新游戏中选择该训练家后解锁资料"
	for frame_index in trainer_selection_frames.size():
		trainer_selection_frames[frame_index].visible = frame_index == selected_trainer_index


func _select_item_entry(kind: String, index: int) -> void:
	var entries := accessory_entries if kind == "accessory" else item_entries
	if entries.is_empty():
		return
	index = clampi(index, 0, entries.size() - 1)
	if kind == "accessory":
		selected_accessory_index = index
	else:
		selected_item_index = index
	var entry: Dictionary = entries[index]
	var seen := GameState.has_seen_item(entry, kind)
	var frames := accessory_selection_frames if kind == "accessory" else item_selection_frames
	for frame_index in frames.size():
		frames[frame_index].visible = frame_index == index
	if not seen:
		detail_sprite.texture = load(String(entry["path"])) as Texture2D
		_set_silhouette(detail_sprite, true)
		detail_unknown.visible = false
		detail_name.text = "未解锁"
		detail_rarity.add_theme_color_override("font_color", Color.WHITE)
		detail_rarity.text = "未发现"
		detail_type.text = "饰品" if kind == "accessory" else "道具"
		detail_cooldown.text = "--"
		detail_stats.text = "未知"
		detail_description.text = "获得后解锁详细信息"
		return
	detail_sprite.texture = load(String(entry["path"])) as Texture2D
	_set_silhouette(detail_sprite, false)
	detail_unknown.visible = false
	detail_name.text = String(entry["name"])
	var rarity := clampi(int(entry.get("rarity", 0)), 0, ITEM_CATALOG.RARITY_NAMES.size() - 1)
	detail_rarity.text = ITEM_CATALOG.RARITY_NAMES[rarity]
	detail_rarity.add_theme_color_override("font_color", _item_rarity_color(rarity))
	detail_type.text = "饰品" if kind == "accessory" else "道具"
	detail_cooldown.text = "%dG\n价格" % int(entry.get("price", 0))
	detail_stats.text = "持有时生效" if kind == "accessory" else "使用后生效"
	detail_description.text = String(entry.get("effect", "暂无效果说明"))


func _build_counters() -> void:
	var paths := ["21_切图_21.png", "22_切图_22.png", "23_切图_23.png"]
	var texts := ["0/%d" % CREATURES.size(), "0/%d" % CREATURES.size(), "0/%d" % CREATURES.size()]
	for index in 3:
		var x := 408.0 + index * 260.0
		_add_texture(self, DEX + paths[index], Rect2(x, 611, 245, 55), TextureRect.STRETCH_SCALE)
		var counter := _add_label(self, texts[index], Rect2(x + 62, 618, 126, 38), 23, HORIZONTAL_ALIGNMENT_CENTER)
		_use_dark_text(counter)
		counter_labels.append(counter)


func _select_creature(index: int) -> void:
	selected_index = index
	detail_rarity.add_theme_color_override("font_color", Color.WHITE)
	if not GameState.has_seen_creature(CREATURES[index]):
		detail_sprite.texture = load(CREATURES[index]) as Texture2D
		_set_silhouette(detail_sprite, true)
		detail_unknown.visible = false
		detail_name.text = "未解锁"
		detail_rarity.text = "未发现"
		detail_type.text = "未知"
		detail_cooldown.text = "--"
		detail_stats.text = "未知"
		detail_description.text = "尚未遇见该怪兽"
		for frame_index in selection_frames.size():
			selection_frames[frame_index].visible = frame_index == index
		return
	detail_sprite.texture = load(CREATURES[index]) as Texture2D
	_set_silhouette(detail_sprite, false)
	detail_unknown.visible = false
	detail_name.text = NAMES[index]
	var rarity := clampi(CATALOG.rarity_for_texture(CREATURES[index]), 0, CATALOG.RARITY_NAMES.size() - 1)
	detail_rarity.text = CATALOG.RARITY_NAMES[rarity]
	detail_rarity.add_theme_color_override("font_color", _creature_rarity_color(rarity))
	var elements: PackedStringArray = CATALOG.elements_for_texture(CREATURES[index])
	var races: PackedStringArray = CATALOG.races_for_texture(CREATURES[index])
	var element_text := "/".join(elements)
	var race_text := races[0] if not races.is_empty() else "未知"
	detail_type.text = "%s·%s" % [element_text, race_text]
	detail_cooldown.text = "%.1f\n秒" % (CATALOG.cooldown_for_texture(CREATURES[index]) / CATALOG.rarity_charge_multiplier(CREATURES[index]))
	_refresh_creature_level_stats()
	detail_description.text = "%s\n%s" % [CATALOG.skill_name_for_texture(CREATURES[index]), CATALOG.skill_text_for_texture(CREATURES[index])]
	for frame_index in selection_frames.size():
		selection_frames[frame_index].visible = frame_index == index


func _on_tab_pressed(index: int) -> void:
	current_tab = index
	for button_index in tab_buttons.size():
		tab_buttons[button_index].texture_normal = load(DEX + "02_切图_2.png" if button_index == index else INACTIVE_TABS[button_index]) as Texture2D
	monster_page.visible = true
	for card in creature_cards:
		card.visible = index == 0
	for card in accessory_cards:
		card.visible = index == 1
	for card in item_cards:
		card.visible = index == 2
	for card in trainer_cards:
		card.visible = index == 3
	empty_label.visible = false
	for control in creature_detail_controls:
		control.visible = index == 0
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
		_:
			_set_collection_page_height(TRAINER_TEXTURES.size())
			_select_trainer(selected_trainer_index)
	_update_counters()
	monster_scroll.scroll_vertical = 0


func _on_collection_scrolled(_value: float) -> void:
	_update_scroll_thumb()


func _update_scroll_thumb() -> void:
	if scroll_thumb == null or monster_scroll == null:
		return
	var bar := monster_scroll.get_v_scroll_bar()
	var scroll_range := maxf(bar.max_value - bar.page, 1.0)
	var ratio := clampf(bar.value / scroll_range, 0.0, 1.0)
	scroll_thumb.position.y = 118.0 + ratio * 382.0


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
	button.position = Vector2(27 + index * 68, 510)
	button.size = Vector2(60, 38)
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
	for index in CREATURES.size():
		var seen := GameState.has_seen_creature(CREATURES[index])
		var mask := GameState.creature_achievement_mask(CREATURES[index])
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
		counter_labels[0].text = "%d/%d" % [trophy_count, CREATURES.size()]
		counter_labels[1].text = "%d/%d" % [medal_count, CREATURES.size()]
		counter_labels[2].text = "%d/%d" % [star_count, CREATURES.size()]
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
	for index in TRAINER_TEXTURES.size():
		var unlocked := GameState.has_unlocked_trainer(TRAINER_IDS[index])
		_set_silhouette(trainer_sprites[index], not unlocked)
		trainer_name_labels[index].text = TRAINER_NAMES[index] if unlocked else "未解锁"
	_update_counters()
	_on_tab_pressed(current_tab)


func _update_counters() -> void:
	if counter_labels.size() != 3:
		return
	if current_tab == 1 or current_tab == 2:
		var kind := "accessory" if current_tab == 1 else "item"
		var entries := accessory_entries if current_tab == 1 else item_entries
		for rarity in 3:
			var total := 0
			var seen := 0
			for entry in entries:
				if int(entry.get("rarity", 0)) != rarity:
					continue
				total += 1
				seen += 1 if GameState.has_seen_item(entry, kind) else 0
			counter_labels[rarity].text = "%d/%d" % [seen, total]
		return
	var achievement_flags := [GameState.ACHIEVEMENT_TROPHY, GameState.ACHIEVEMENT_MEDAL, GameState.ACHIEVEMENT_STAR]
	for achievement_index in achievement_flags.size():
		var count := 0
		for path in CREATURES:
			count += 1 if GameState.creature_achievement_mask(path) & achievement_flags[achievement_index] else 0
		counter_labels[achievement_index].text = "%d/%d" % [count, CREATURES.size()]


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
	return Rect2(12 + column * 221, 10 + row * 171, 205, 152)


func _set_collection_page_height(entry_count: int) -> void:
	var rows := maxi(1, ceili(float(entry_count) / 4.0))
	monster_page.custom_minimum_size = Vector2(892, maxf(690.0, 10.0 + rows * 171.0))
	monster_page.size = monster_page.custom_minimum_size


func _item_rarity_color(rarity: int) -> Color:
	return [Color("d7dce4"), Color("55c6e8"), Color("d084ff")][clampi(rarity, 0, 2)]


func _creature_rarity_color(rarity: int) -> Color:
	return [Color("d7dce4"), Color("68cf72"), Color("55b7ed"), Color("d084ff"), Color("f1b640")][clampi(rarity, 0, 4)]


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
	label.add_theme_color_override("font_shadow_color", Color(0.08, 0.09, 0.12, 0.38))
	label.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
	label.add_theme_constant_override("outline_size", 0)
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
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
