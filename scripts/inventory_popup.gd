extends Control

const SOURCE_HAN_FONT: FontFile = preload("res://assets/fonts/SourceHanSansSC-Heavy.otf")
const ITEM_CATALOG = preload("res://scripts/item_catalog.gd")
const VISIBLE_SLOT_COUNT := 24
const GRID_COLUMNS := 3
const CELL_SIZE := Vector2(157, 68)
const RARITY_COLORS: Array[Color] = [Color("8e929b"), Color("3e95d8"), Color("c45ad9")]

var source_han_font: FontFile
var item_grid: GridContainer
var count_label: Label
var accessory_tab: Button
var item_tab: Button
var item_info_panel: Panel
var item_info_icon: TextureRect
var item_info_name: Label
var item_info_rarity: Label
var item_info_effect: Label
var item_info_rule: Label
var active_kind := "accessory"


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index = 190
	mouse_filter = Control.MOUSE_FILTER_STOP
	source_han_font = SOURCE_HAN_FONT.duplicate() as FontFile
	source_han_font.antialiasing = TextServer.FONT_ANTIALIASING_GRAY
	source_han_font.multichannel_signed_distance_field = true
	source_han_font.msdf_pixel_range = 8
	source_han_font.msdf_size = 64
	source_han_font.hinting = TextServer.HINTING_NORMAL
	source_han_font.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	source_han_font.oversampling = 1.5
	source_han_font.allow_system_fallback = false
	_build_interface()
	refresh_items()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		get_viewport().set_input_as_handled()
		queue_free()


func _build_interface() -> void:
	var outside := Button.new()
	outside.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	outside.flat = true
	outside.focus_mode = Control.FOCUS_NONE
	outside.mouse_default_cursor_shape = Control.CURSOR_ARROW
	outside.add_theme_stylebox_override("normal", _panel_style(Color(0.01, 0.02, 0.04, 0.46), Color.TRANSPARENT, 0))
	outside.add_theme_stylebox_override("hover", _panel_style(Color(0.01, 0.02, 0.04, 0.46), Color.TRANSPARENT, 0))
	outside.add_theme_stylebox_override("pressed", _panel_style(Color(0.01, 0.02, 0.04, 0.52), Color.TRANSPARENT, 0))
	outside.pressed.connect(queue_free)
	add_child(outside)

	var frame := Panel.new()
	frame.position = Vector2(365, 50)
	frame.size = Vector2(550, 620)
	frame.mouse_filter = Control.MOUSE_FILTER_STOP
	frame.add_theme_stylebox_override("panel", _panel_style(Color(0.965, 0.965, 0.98, 1.0), Color(0.18, 0.2, 0.25, 1.0), 4))
	add_child(frame)

	var header := Panel.new()
	header.position = Vector2(12, 12)
	header.size = Vector2(526, 48)
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_theme_stylebox_override("panel", _panel_style(Color("4e4a86"), Color("27243f"), 2))
	frame.add_child(header)
	_add_label(header, "物 品 栏", Rect2(18, 4, 250, 40), 23, Color.WHITE)
	count_label = _add_label(header, "", Rect2(292, 4, 170, 40), 14, Color("ffd067"), HORIZONTAL_ALIGNMENT_RIGHT)

	var close := Button.new()
	close.position = Vector2(478, 5)
	close.size = Vector2(40, 38)
	close.text = "×"
	close.flat = true
	close.focus_mode = Control.FOCUS_NONE
	close.add_theme_font_override("font", source_han_font)
	close.add_theme_font_size_override("font_size", 24)
	close.add_theme_color_override("font_color", Color.WHITE)
	close.add_theme_color_override("font_hover_color", Color("ffd067"))
	close.pressed.connect(queue_free)
	header.add_child(close)

	accessory_tab = _create_tab(frame, "饰品", Vector2(22, 72), "accessory")
	item_tab = _create_tab(frame, "道具", Vector2(278, 72), "item")

	var scroll := ScrollContainer.new()
	scroll.position = Vector2(22, 116)
	scroll.size = Vector2(506, 482)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.clip_contents = true
	frame.add_child(scroll)

	item_grid = GridContainer.new()
	item_grid.columns = GRID_COLUMNS
	item_grid.custom_minimum_size.x = 487
	item_grid.add_theme_constant_override("h_separation", 8)
	item_grid.add_theme_constant_override("v_separation", 8)
	scroll.add_child(item_grid)
	_build_item_info_panel(frame)


func refresh_items() -> void:
	if item_grid == null:
		return
	if is_instance_valid(item_info_panel):
		item_info_panel.visible = false
	for child in item_grid.get_children():
		child.queue_free()
	var source_items: Array = GameState.accessory_inventory if active_kind == "accessory" else GameState.item_inventory
	var items: Array = []
	for source_entry in source_items:
		items.append(ITEM_CATALOG.normalize_entry(source_entry, active_kind))
	items.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var rarity_a := int(a.get("rarity", 0))
		var rarity_b := int(b.get("rarity", 0))
		if rarity_a != rarity_b:
			return rarity_a > rarity_b
		return String(a.get("name", "")) < String(b.get("name", ""))
	)
	var slot_count := maxi(VISIBLE_SLOT_COUNT, items.size())
	count_label.text = "%s %d 件" % ["饰品" if active_kind == "accessory" else "道具", items.size()]
	for index in slot_count:
		_create_item_slot(items[index] if index < items.size() else {}, index)
	_update_tabs()


func _create_item_slot(entry: Dictionary, index: int) -> void:
	var slot := Panel.new()
	slot.custom_minimum_size = CELL_SIZE
	slot.mouse_filter = Control.MOUSE_FILTER_STOP
	var occupied := not entry.is_empty()
	var rarity := clampi(int(entry.get("rarity", 0)), 0, RARITY_COLORS.size() - 1) if occupied else 0
	var rarity_color := RARITY_COLORS[rarity]
	var occupied_color := rarity_color.darkened(0.62)
	slot.add_theme_stylebox_override("panel", _panel_style(occupied_color if occupied else Color(0.2, 0.21, 0.25, 0.58), rarity_color if occupied else Color("777985"), 2))
	item_grid.add_child(slot)
	if not occupied:
		return
	var icon := TextureRect.new()
	icon.position = Vector2(7, 7)
	icon.size = Vector2(54, 54)
	icon.texture = load(String(entry["path"])) as Texture2D
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(icon)
	var label := _add_label(slot, String(entry["name"]), Rect2(66, 3, 86, 38), 10, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var rarity_label := _add_label(slot, ITEM_CATALOG.RARITY_NAMES[rarity], Rect2(66, 40, 86, 23), 10, rarity_color.lightened(0.18), HORIZONTAL_ALIGNMENT_CENTER)
	var owned_count := _owned_entry_count(entry)
	var stack_limit := int(entry.get("stack_limit", 1))
	var rule_text := "唯一饰品" if not String(entry.get("exclusive_group", "")).is_empty() else "持有 %d/%d" % [owned_count, stack_limit]
	slot.gui_input.connect(_on_item_slot_gui_input.bind(entry, rule_text))
	if active_kind == "item":
		var use_button := Button.new()
		use_button.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		use_button.flat = true
		use_button.focus_mode = Control.FOCUS_NONE
		use_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		use_button.gui_input.connect(_on_item_slot_gui_input.bind(entry, rule_text))
		use_button.pressed.connect(_use_item_entry.bind(entry))
		slot.add_child(use_button)


func _build_item_info_panel(parent: Control) -> void:
	item_info_panel = Panel.new()
	item_info_panel.position = Vector2(22, 116)
	item_info_panel.size = Vector2(506, 166)
	item_info_panel.z_index = 20
	item_info_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	item_info_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.075, 0.085, 0.12, 0.985), Color("4e4a86"), 3))
	item_info_panel.gui_input.connect(_on_item_info_background_input)
	item_info_panel.visible = false
	parent.add_child(item_info_panel)

	item_info_icon = TextureRect.new()
	item_info_icon.position = Vector2(16, 20)
	item_info_icon.size = Vector2(94, 94)
	item_info_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	item_info_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	item_info_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	item_info_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	item_info_panel.add_child(item_info_icon)
	item_info_name = _add_label(item_info_panel, "", Rect2(126, 12, 260, 34), 18, Color.WHITE)
	item_info_rarity = _add_label(item_info_panel, "", Rect2(392, 42, 82, 28), 12, Color.WHITE, HORIZONTAL_ALIGNMENT_RIGHT)
	item_info_effect = _add_label(item_info_panel, "", Rect2(126, 47, 352, 66), 13, Color.WHITE)
	item_info_effect.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	item_info_rule = _add_label(item_info_panel, "", Rect2(16, 122, 462, 32), 12, Color("bfc5d4"))

	var close_info := Button.new()
	close_info.position = Vector2(462, 4)
	close_info.size = Vector2(38, 34)
	close_info.text = "×"
	close_info.flat = true
	close_info.focus_mode = Control.FOCUS_NONE
	close_info.add_theme_font_override("font", source_han_font)
	close_info.add_theme_font_size_override("font_size", 20)
	close_info.add_theme_color_override("font_color", Color.WHITE)
	close_info.pressed.connect(_hide_item_info)
	item_info_panel.add_child(close_info)


func _on_item_slot_gui_input(event: InputEvent, entry: Dictionary, rule_text: String) -> void:
	if not event is InputEventMouseButton:
		return
	var mouse_event := event as InputEventMouseButton
	if mouse_event.button_index != MOUSE_BUTTON_RIGHT or not mouse_event.pressed:
		return
	get_viewport().set_input_as_handled()
	_show_item_info(entry, rule_text)


func _show_item_info(entry: Dictionary, rule_text: String) -> void:
	var rarity := clampi(int(entry.get("rarity", 0)), 0, RARITY_COLORS.size() - 1)
	item_info_icon.texture = load(String(entry["path"])) as Texture2D
	item_info_name.text = String(entry["name"])
	item_info_rarity.text = ITEM_CATALOG.RARITY_NAMES[rarity]
	item_info_rarity.add_theme_color_override("font_color", RARITY_COLORS[rarity].lightened(0.18))
	item_info_effect.text = String(entry["effect"])
	item_info_rule.text = "%s · 右键查看，左键使用" % rule_text if active_kind == "item" else rule_text
	item_info_panel.visible = true
	item_info_panel.move_to_front()


func _hide_item_info() -> void:
	item_info_panel.visible = false


func _on_item_info_background_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_hide_item_info()


func _owned_entry_count(entry: Dictionary) -> int:
	var inventory: Array = GameState.accessory_inventory if active_kind == "accessory" else GameState.item_inventory
	var count := 0
	for owned in inventory:
		if int(owned.get("id", -1)) == int(entry.get("id", -2)):
			count += 1
	return count


func _create_tab(parent: Control, text: String, position: Vector2, kind: String) -> Button:
	var button := Button.new()
	button.position = position
	button.size = Vector2(250, 36)
	button.text = text
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_override("font", source_han_font)
	button.add_theme_font_size_override("font_size", 15)
	button.pressed.connect(_select_tab.bind(kind))
	parent.add_child(button)
	return button


func _select_tab(kind: String) -> void:
	active_kind = kind
	refresh_items()


func _update_tabs() -> void:
	for pair in [[accessory_tab, "accessory"], [item_tab, "item"]]:
		var button := pair[0] as Button
		var selected := active_kind == String(pair[1])
		button.disabled = selected
		button.add_theme_color_override("font_color", Color.WHITE)
		button.add_theme_color_override("font_disabled_color", Color.WHITE)
		button.add_theme_stylebox_override("normal", _panel_style(Color("ef3f68") if selected else Color("4e4a86"), Color("27243f"), 2))
		button.add_theme_stylebox_override("disabled", _panel_style(Color("ef3f68"), Color("27243f"), 2))


func _use_item(index: int) -> void:
	var result := GameState.use_item(index)
	refresh_items()
	var parent_control := get_parent()
	if parent_control and parent_control.has_method("_refresh_inventory_count"):
		parent_control.call("_refresh_inventory_count")
	if parent_control and parent_control.has_method("_sync_coins"):
		parent_control.call("_sync_coins")
	if parent_control and parent_control.has_method("_set_notice"):
		parent_control.call("_set_notice", result)


func _use_item_entry(entry: Dictionary) -> void:
	var inventory_index := -1
	for index in GameState.item_inventory.size():
		var owned := ITEM_CATALOG.normalize_entry(GameState.item_inventory[index], "item")
		if int(owned.get("id", -1)) == int(entry.get("id", -2)):
			inventory_index = index
			break
	if inventory_index >= 0:
		_use_item(inventory_index)


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
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 1)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label


func _panel_style(fill: Color, border: Color, width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(width)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	return style
