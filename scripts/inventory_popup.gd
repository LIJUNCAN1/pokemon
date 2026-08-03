extends Control

const SOURCE_HAN_FONT: FontFile = preload("res://assets/fonts/SourceHanSansSC-Heavy.otf")
const VISIBLE_SLOT_COUNT := 32
const GRID_COLUMNS := 4
const CELL_SIZE := Vector2(112, 54)

var source_han_font: FontFile
var item_grid: GridContainer
var count_label: Label


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index = 190
	mouse_filter = Control.MOUSE_FILTER_STOP
	source_han_font = SOURCE_HAN_FONT.duplicate() as FontFile
	source_han_font.antialiasing = TextServer.FONT_ANTIALIASING_GRAY
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

	var scroll := ScrollContainer.new()
	scroll.position = Vector2(22, 72)
	scroll.size = Vector2(506, 526)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.clip_contents = true
	frame.add_child(scroll)

	item_grid = GridContainer.new()
	item_grid.columns = GRID_COLUMNS
	item_grid.custom_minimum_size.x = 472
	item_grid.add_theme_constant_override("h_separation", 8)
	item_grid.add_theme_constant_override("v_separation", 8)
	scroll.add_child(item_grid)


func refresh_items() -> void:
	if item_grid == null:
		return
	for child in item_grid.get_children():
		child.queue_free()
	var items: Array[String] = GameState.item_inventory
	var slot_count := maxi(VISIBLE_SLOT_COUNT, items.size())
	count_label.text = "%d / %d 件" % [items.size(), VISIBLE_SLOT_COUNT]
	for index in slot_count:
		_create_item_slot(items[index] if index < items.size() else "")


func _create_item_slot(texture_path: String) -> void:
	var slot := Panel.new()
	slot.custom_minimum_size = CELL_SIZE
	slot.mouse_filter = Control.MOUSE_FILTER_STOP
	var occupied := not texture_path.is_empty()
	slot.add_theme_stylebox_override("panel", _panel_style(Color(0.12, 0.13, 0.17, 0.96) if occupied else Color(0.2, 0.21, 0.25, 0.58), Color("d8d3e3") if occupied else Color("777985"), 2))
	item_grid.add_child(slot)
	if not occupied:
		return
	var icon := TextureRect.new()
	icon.position = Vector2(5, 5)
	icon.size = Vector2(44, 44)
	icon.texture = load(texture_path) as Texture2D
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(icon)
	var item_id := texture_path.get_file().get_basename().trim_prefix("fc")
	var label := _add_label(slot, "道具\n%s" % item_id, Rect2(51, 4, 56, 46), 11, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	slot.tooltip_text = "道具 %s" % item_id


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
