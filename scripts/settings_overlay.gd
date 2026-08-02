extends Control

const SOURCE_HAN_FONT: FontFile = preload("res://assets/fonts/SourceHanSansSC-Heavy.otf")
const ROW_NAMES: Array[String] = ["全屏", "分辨率", "音效", "音乐", "语言", "按键布局"]
const OPTIONS: Array = [
	["关", "开"],
	["1280 x 720", "1600 x 900", "1920 x 1080"],
	["0%", "25%", "50%", "75%", "100%"],
	["0%", "25%", "50%", "75%", "100%"],
	["简体中文"],
	["自动", "键盘鼠标", "控制器"],
]

var option_indices: Array[int] = [0, 2, 4, 3, 0, 0]
var value_labels: Array[Label] = []
var source_han_font: FontFile


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index = 180
	source_han_font = SOURCE_HAN_FONT.duplicate() as FontFile
	source_han_font.antialiasing = TextServer.FONT_ANTIALIASING_GRAY
	source_han_font.hinting = TextServer.HINTING_NORMAL
	source_han_font.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	source_han_font.oversampling = 1.5
	source_han_font.allow_system_fallback = false
	_sync_current_settings()
	_build_interface()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		get_viewport().set_input_as_handled()
		queue_free()


func _sync_current_settings() -> void:
	option_indices[0] = 1 if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN else 0
	var current_size := DisplayServer.window_get_size()
	var resolutions: Array = [Vector2i(1280, 720), Vector2i(1600, 900), Vector2i(1920, 1080)]
	var closest := 0
	var closest_distance := 99999999.0
	for index in resolutions.size():
		var distance := Vector2(current_size).distance_squared_to(Vector2(resolutions[index]))
		if distance < closest_distance:
			closest = index
			closest_distance = distance
	option_indices[1] = closest


func _build_interface() -> void:
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.02, 0.03, 0.05, 0.78)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(shade)

	var frame := Panel.new()
	frame.position = Vector2(398, 118)
	frame.size = Vector2(484, 484)
	frame.add_theme_stylebox_override("panel", _panel_style(Color(0.96, 0.96, 0.97, 1.0), Color(0.27, 0.27, 0.31, 1.0), 4))
	add_child(frame)

	for index in ROW_NAMES.size():
		var y := 12.0 + index * 61.0
		var row := Panel.new()
		row.position = Vector2(16, y)
		row.size = Vector2(452, 54)
		row.add_theme_stylebox_override("panel", _panel_style(Color(0.985, 0.985, 0.99, 1.0), Color(0.62, 0.62, 0.69, 1.0), 3))
		frame.add_child(row)
		_add_text(row, ROW_NAMES[index], Rect2(12, 8, 170, 38), 18, true, HORIZONTAL_ALIGNMENT_CENTER)
		var left := _arrow_button(row, "◀", Rect2(216, 7, 42, 40))
		left.pressed.connect(_change_option.bind(index, -1))
		var value := _add_text(row, OPTIONS[index][option_indices[index]], Rect2(260, 8, 136, 38), 17, true, HORIZONTAL_ALIGNMENT_CENTER)
		value_labels.append(value)
		var right := _arrow_button(row, "▶", Rect2(398, 7, 42, 40))
		right.pressed.connect(_change_option.bind(index, 1))

	var done := Button.new()
	done.position = Vector2(16, 383)
	done.size = Vector2(452, 82)
	done.text = "完成"
	done.focus_mode = Control.FOCUS_NONE
	done.add_theme_font_override("font", source_han_font)
	done.add_theme_font_size_override("font_size", 28)
	done.add_theme_color_override("font_color", Color.WHITE)
	done.add_theme_color_override("font_outline_color", Color.BLACK)
	done.add_theme_color_override("font_shadow_color", Color.BLACK)
	done.add_theme_constant_override("outline_size", 1)
	done.add_theme_constant_override("shadow_offset_x", 1)
	done.add_theme_constant_override("shadow_offset_y", 1)
	done.add_theme_stylebox_override("normal", _panel_style(Color("ef3e6a"), Color(0.18, 0.16, 0.18, 1.0), 4))
	done.add_theme_stylebox_override("hover", _panel_style(Color("ff547c"), Color(0.18, 0.16, 0.18, 1.0), 4))
	done.pressed.connect(queue_free)
	frame.add_child(done)


func _change_option(row_index: int, direction: int) -> void:
	var values: Array = OPTIONS[row_index]
	option_indices[row_index] = posmod(option_indices[row_index] + direction, values.size())
	value_labels[row_index].text = values[option_indices[row_index]]
	_apply_option(row_index)


func _apply_option(row_index: int) -> void:
	match row_index:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if option_indices[0] == 1 else DisplayServer.WINDOW_MODE_WINDOWED)
		1:
			var sizes := [Vector2i(1280, 720), Vector2i(1600, 900), Vector2i(1920, 1080)]
			DisplayServer.window_set_size(sizes[option_indices[1]])
		2:
			_set_bus_volume("SFX", option_indices[2] * 0.25)
		3:
			_set_bus_volume("Music", option_indices[3] * 0.25)


func _set_bus_volume(bus_name: String, linear_volume: float) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index < 0:
		AudioServer.add_bus()
		bus_index = AudioServer.bus_count - 1
		AudioServer.set_bus_name(bus_index, bus_name)
	AudioServer.set_bus_mute(bus_index, linear_volume <= 0.0)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(maxf(linear_volume, 0.001)))


func _arrow_button(parent: Control, text: String, rect: Rect2) -> Button:
	var button := Button.new()
	button.position = rect.position
	button.size = rect.size
	button.text = text
	button.flat = true
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_override("font", source_han_font)
	button.add_theme_font_size_override("font_size", 23)
	button.add_theme_color_override("font_color", Color("ef3e6a"))
	button.add_theme_color_override("font_hover_color", Color("ff6d90"))
	button.add_theme_color_override("font_outline_color", Color(0.15, 0.14, 0.17, 1.0))
	button.add_theme_constant_override("outline_size", 1)
	parent.add_child(button)
	return button


func _add_text(parent: Control, text: String, rect: Rect2, size: int, light_background: bool, alignment: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.position = rect.position
	label.size = rect.size
	label.text = text
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", source_han_font)
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", Color(0.12, 0.12, 0.16, 1.0) if light_background else Color.WHITE)
	label.add_theme_color_override("font_shadow_color", Color(0.5, 0.5, 0.54, 0.9) if light_background else Color.BLACK)
	label.add_theme_color_override("font_outline_color", Color(0.12, 0.12, 0.16, 1.0) if light_background else Color.BLACK)
	label.add_theme_constant_override("outline_size", 1)
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
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
