extends Control

const SOURCE_HAN_FONT: FontFile = preload("res://assets/fonts/SourceHanSansSC-Heavy.otf")
const ITEM_CATALOG = preload("res://scripts/item_catalog.gd")
const EQUIPMENT_CATALOG = preload("res://scripts/equipment_catalog.gd")
const RARITY_TAG = preload("res://scripts/rarity_tag_style.gd")
const ITEM_INFO_TINT_SHADER: Shader = preload("res://assets/ui/item_info/rarity_tint.gdshader")
const ITEM_INFO_ROOT := "res://assets/ui/item_info/"
const VISIBLE_SLOT_COUNT := 24
const GRID_COLUMNS := 3
const CELL_SIZE := Vector2(157, 68)
const RARITY_COLORS: Array[Color] = [Color("8e929b"), Color("3e95d8"), Color("c45ad9")]

var source_han_font: FontFile
var item_grid: GridContainer
var count_label: Label
var accessory_tab: Button
var item_tab: Button
var equipment_tab: Button
var item_info_panel: Panel
var item_info_dismiss_layer: Button
var item_info_icon: TextureRect
var item_info_name: Label
var item_info_rarity: Label
var item_info_effect: Label
var item_info_rule: Label
var item_info_layers: Array[TextureRect] = []
var item_info_type: Label
var item_info_star: Label
var item_info_effect_rich: RichTextLabel
var item_info_rule_rich: RichTextLabel
var item_info_divider: Control
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
	item_tab = _create_tab(frame, "道具", Vector2(194, 72), "item")
	equipment_tab = _create_tab(frame, "装备", Vector2(366, 72), "equipment")

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
	_hide_item_info()
	for child in item_grid.get_children():
		child.queue_free()
	var source_items: Array = GameState.accessory_inventory if active_kind == "accessory" else (GameState.item_inventory if active_kind == "item" else GameState.equipment_inventory)
	var items: Array = []
	for source_entry in source_items:
		items.append(EQUIPMENT_CATALOG.normalize(source_entry) if active_kind == "equipment" else ITEM_CATALOG.normalize_entry(source_entry, active_kind))
	items.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var rarity_a := int(a.get("rarity", 0))
		var rarity_b := int(b.get("rarity", 0))
		if rarity_a != rarity_b:
			return rarity_a > rarity_b
		return String(a.get("name", "")) < String(b.get("name", ""))
	)
	var slot_count := maxi(VISIBLE_SLOT_COUNT, items.size())
	var kind_name := "饰品" if active_kind == "accessory" else ("道具" if active_kind == "item" else "装备")
	count_label.text = "%s %d 件" % [kind_name, items.size()]
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
	var rule_text := "每名角色最多装备两件" if active_kind == "equipment" else ("唯一饰品" if not String(entry.get("exclusive_group", "")).is_empty() else "持有 %d/%d" % [owned_count, stack_limit])
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
	elif active_kind == "equipment":
		var equip_button := Button.new()
		equip_button.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		equip_button.flat = true
		equip_button.focus_mode = Control.FOCUS_NONE
		equip_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		equip_button.pressed.connect(_equip_entry.bind(entry))
		slot.add_child(equip_button)


func _build_item_info_panel(parent: Control) -> void:
	item_info_dismiss_layer = Button.new()
	item_info_dismiss_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	item_info_dismiss_layer.flat = true
	item_info_dismiss_layer.focus_mode = Control.FOCUS_NONE
	item_info_dismiss_layer.mouse_default_cursor_shape = Control.CURSOR_ARROW
	item_info_dismiss_layer.z_index = 19
	item_info_dismiss_layer.visible = false
	item_info_dismiss_layer.pressed.connect(_hide_item_info)
	parent.add_child(item_info_dismiss_layer)

	item_info_panel = Panel.new()
	item_info_panel.position = Vector2(22, 116)
	item_info_panel.size = Vector2(506, 357)
	item_info_panel.z_index = 20
	item_info_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	item_info_panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	item_info_panel.visible = false
	parent.add_child(item_info_panel)

	item_info_icon = TextureRect.new()
	item_info_icon.position = Vector2(29, 108)
	item_info_icon.size = Vector2(213, 213)
	item_info_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	item_info_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	item_info_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	item_info_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	item_info_panel.add_child(item_info_icon)
	item_info_name = _add_label(item_info_panel, "", Rect2(72, 22, 265, 44), 26, Color.WHITE)
	item_info_rarity = _add_label(item_info_panel, "", Rect2(402, 28, 73, 36), 18, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	item_info_effect = _add_label(item_info_panel, "", Rect2(Vector2.ZERO, Vector2.ZERO), 1, Color.TRANSPARENT)
	item_info_effect.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	item_info_rule = _add_label(item_info_panel, "", Rect2(Vector2.ZERO, Vector2.ZERO), 1, Color.TRANSPARENT)
	_build_item_info_art()

	var close_info := Button.new()
	close_info.position = Vector2(466, 4)
	close_info.size = Vector2(38, 34)
	close_info.text = "×"
	close_info.flat = true
	close_info.focus_mode = Control.FOCUS_NONE
	close_info.add_theme_font_override("font", source_han_font)
	close_info.add_theme_font_size_override("font_size", 20)
	close_info.add_theme_color_override("font_color", Color.WHITE)
	close_info.pressed.connect(_hide_item_info)
	item_info_panel.add_child(close_info)


func _build_item_info_art() -> void:
	for asset_name in ["frame.png", "header.png", "header_accent.png", "rarity_icon_shadow.png", "rarity_icon_border.png", "rarity_icon_fill.png", "portrait_border.png", "portrait_fill.png", "rarity_badge.png"]:
		var layer := TextureRect.new()
		layer.position = Vector2.ZERO
		layer.size = item_info_panel.size
		layer.texture = load(ITEM_INFO_ROOT + asset_name) as Texture2D
		layer.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		layer.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		layer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		layer.z_index = -2 if asset_name == "frame.png" else -1
		if asset_name in ["header.png", "header_accent.png", "rarity_icon_border.png", "rarity_icon_fill.png", "rarity_badge.png", "portrait_border.png", "portrait_fill.png"]:
			var material := ShaderMaterial.new()
			material.shader = ITEM_INFO_TINT_SHADER
			layer.material = material
		item_info_panel.add_child(layer)
		item_info_layers.append(layer)
		if asset_name == "rarity_badge.png":
			layer.visible = false
	item_info_star = _add_label(item_info_panel, "✦", Rect2(24, 22, 44, 44), 25, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	item_info_type = _add_label(item_info_panel, "", Rect2(270, 105, 200, 42), 20, Color("252b35"))
	item_info_effect_rich = _add_rich_text(item_info_panel, Rect2(270, 150, 208, 104), 15)
	item_info_rule_rich = _add_rich_text(item_info_panel, Rect2(270, 260, 208, 54), 14)
	item_info_divider = _make_dashed_divider(item_info_panel, Vector2(270, 252), 208.0)


func _make_dashed_divider(parent: Control, start: Vector2, width: float) -> Control:
	var line := Control.new()
	line.position = start
	line.size = Vector2(width, 2)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	line.z_index = 1
	var dash_width := 8.0
	var gap_width := 6.0
	var x := 0.0
	while x < width:
		var dash := ColorRect.new()
		dash.position = Vector2(x, 0)
		dash.size = Vector2(minf(dash_width, width - x), 2)
		dash.color = Color("c8cbd2")
		dash.mouse_filter = Control.MOUSE_FILTER_IGNORE
		line.add_child(dash)
		x += dash_width + gap_width
	parent.add_child(line)
	return line


func _add_rich_text(parent: Control, rect: Rect2, font_size: int) -> RichTextLabel:
	var rich := RichTextLabel.new()
	rich.position = rect.position
	rich.size = rect.size
	rich.bbcode_enabled = true
	rich.fit_content = false
	rich.scroll_active = false
	rich.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rich.add_theme_font_override("normal_font", source_han_font)
	rich.add_theme_font_size_override("normal_font_size", font_size)
	rich.add_theme_color_override("default_color", Color("596275"))
	parent.add_child(rich)
	return rich


func _blue_item_values(text: String) -> String:
	var value_pattern := RegEx.new()
	value_pattern.compile("([+-]?\\d+(?:\\.\\d+)?%?)")
	return value_pattern.sub(text, "[color=#4f83c2]$1[/color]", true)


func _apply_item_info_rarity(rarity_color: Color) -> void:
	var tint_strengths := {1: 0.82, 2: 0.96, 4: 0.92, 5: 0.84, 6: 0.42, 7: 0.12, 8: 0.72}
	var brightnesses := {1: 0.54, 2: 0.88, 4: 0.82, 5: 0.72, 6: 0.62, 7: 1.0, 8: 0.72}
	for layer_index in item_info_layers.size():
		var layer := item_info_layers[layer_index]
		if layer.material is ShaderMaterial:
			var material := layer.material as ShaderMaterial
			material.set_shader_parameter("rarity_color", rarity_color)
			material.set_shader_parameter("tint_strength", float(tint_strengths.get(layer_index, 0.8)))
			material.set_shader_parameter("brightness", float(brightnesses.get(layer_index, 1.0)))


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
	RARITY_TAG.apply(item_info_rarity, [0, 2, 3][rarity])
	_apply_item_info_rarity(RARITY_COLORS[rarity])
	item_info_type.text = "✦ %s" % ("饰品" if active_kind == "accessory" else ("道具" if active_kind == "item" else "装备"))
	item_info_effect_rich.text = _blue_item_values(String(entry["effect"]))
	item_info_rule_rich.text = _blue_item_values(rule_text)
	item_info_dismiss_layer.visible = true
	item_info_panel.visible = true
	item_info_dismiss_layer.move_to_front()
	item_info_panel.move_to_front()


func show_entry_info(entry: Dictionary, rule_text := "") -> void:
	var normalized := EQUIPMENT_CATALOG.normalize(entry) if String(entry.get("kind", "")) == "equipment" else ITEM_CATALOG.normalize_entry(entry, active_kind)
	if normalized.is_empty():
		return
	if String(normalized.get("kind", "")) == "equipment":
		active_kind = "equipment"
		_update_tabs()
		_show_item_info(normalized, rule_text if not String(rule_text).is_empty() else "每名角色最多装备两件")
	else:
		_show_item_info(normalized, rule_text)


func _hide_item_info() -> void:
	if is_instance_valid(item_info_dismiss_layer):
		item_info_dismiss_layer.visible = false
	if is_instance_valid(item_info_panel):
		item_info_panel.visible = false


func _owned_entry_count(entry: Dictionary) -> int:
	var inventory: Array = GameState.accessory_inventory if active_kind == "accessory" else (GameState.item_inventory if active_kind == "item" else GameState.equipment_inventory)
	var count := 0
	for owned in inventory:
		if int(owned.get("id", -1)) == int(entry.get("id", -2)):
			count += 1
	return count


func _create_tab(parent: Control, text: String, position: Vector2, kind: String) -> Button:
	var button := Button.new()
	button.position = position
	button.size = Vector2(162, 36)
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
	for pair in [[accessory_tab, "accessory"], [item_tab, "item"], [equipment_tab, "equipment"]]:
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


func _equip_entry(entry: Dictionary) -> void:
	var parent_control := get_parent()
	if parent_control and parent_control.has_method("equip_selected_creature") and bool(parent_control.call("equip_selected_creature", entry)):
		refresh_items()


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
