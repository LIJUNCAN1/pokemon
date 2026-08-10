extends Control

const SOURCE_HAN_FONT: FontFile = preload("res://assets/fonts/SourceHanSansSC-Heavy.otf")
const MENU_BUTTON_NORMAL: Texture2D = preload("res://assets/ui/pixel_menu/controls/button-normal.png")
const MENU_BUTTON_PRESSED: Texture2D = preload("res://assets/ui/pixel_menu/controls/button-pressed.png")
const BUTTON_DISPLAY_SCALE := 0.8579767
const ROW_NAMES: Array[String] = ["显示模式", "分辨率", "音效", "音乐", "语言", "按键布局"]
const OPTIONS: Array = [
	["全屏", "无边框窗口化", "窗口化"],
	["1280 x 720", "1600 x 900", "1920 x 1080"],
	["0%", "25%", "50%", "75%", "100%"],
	["0%", "25%", "50%", "75%", "100%"],
	["简体中文"],
	["自动", "键盘鼠标", "控制器"],
]

var option_indices: Array[int] = [0, 2, 4, 3, 0, 0]
var value_labels: Array[Label] = []
var source_han_font: FontFile
var exit_scene_path := ""
var overlay_shade: ColorRect
var overlay_frame: Panel
var closing := false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# This overlay was authored in 1280x720 coordinates; render it at 0.5
	# in viewport space. In-game parents are already scaled to 0.5, while
	# the main menu is not, so compensate for the inherited parent scale.
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	position = Vector2.ZERO
	size = Vector2(1280, 720)
	var inherited_scale := Vector2.ONE
	var parent_control := get_parent() as Control
	if parent_control:
		inherited_scale = parent_control.get_global_transform().get_scale().abs()
	scale = Vector2(
		0.5 / maxf(inherited_scale.x, 0.001),
		0.5 / maxf(inherited_scale.y, 0.001)
	)
	z_index = 180
	source_han_font = SOURCE_HAN_FONT.duplicate() as FontFile
	source_han_font.antialiasing = TextServer.FONT_ANTIALIASING_GRAY
	source_han_font.multichannel_signed_distance_field = true
	source_han_font.msdf_pixel_range = 8
	source_han_font.msdf_size = 64
	source_han_font.hinting = TextServer.HINTING_NORMAL
	source_han_font.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	source_han_font.oversampling = 1.0
	source_han_font.allow_system_fallback = false
	_sync_current_settings()
	_build_interface()
	_play_entrance()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		get_viewport().set_input_as_handled()
		_close_overlay()


func _sync_current_settings() -> void:
	match DisplayServer.window_get_mode():
		DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			option_indices[0] = 0
		DisplayServer.WINDOW_MODE_FULLSCREEN:
			option_indices[0] = 1
		_:
			option_indices[0] = 1 if DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS) else 2
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
	overlay_shade = ColorRect.new()
	overlay_shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay_shade.color = Color(0.02, 0.03, 0.05, 0.78)
	overlay_shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(overlay_shade)
	var outside := Button.new()
	outside.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	outside.flat = true
	outside.focus_mode = Control.FOCUS_NONE
	outside.mouse_default_cursor_shape = Control.CURSOR_ARROW
	outside.pressed.connect(_close_overlay)
	add_child(outside)

	var row_bottom := 12.0 + (ROW_NAMES.size() - 1) * 61.0 + 54.0
	var has_exit_action := not exit_scene_path.is_empty()
	var exit_button_y := row_bottom + 18.0
	var frame_height := exit_button_y + 42.0 + 16.0 if has_exit_action else row_bottom + 16.0
	overlay_frame = Panel.new()
	overlay_frame.size = Vector2(484, frame_height)
	overlay_frame.position = (Vector2(1280, 720) - overlay_frame.size) * 0.5
	overlay_frame.pivot_offset = overlay_frame.size * 0.5
	overlay_frame.add_theme_stylebox_override("panel", _panel_style(Color(0.96, 0.96, 0.97, 1.0), Color(0.27, 0.27, 0.31, 1.0), 4))
	add_child(overlay_frame)

	for index in ROW_NAMES.size():
		var y := 12.0 + index * 61.0
		var row := Panel.new()
		row.position = Vector2(16, y)
		row.size = Vector2(452, 54)
		row.add_theme_stylebox_override("panel", _panel_style(Color(0.985, 0.985, 0.99, 1.0), Color(0.62, 0.62, 0.69, 1.0), 3))
		overlay_frame.add_child(row)
		_add_text(row, ROW_NAMES[index], Rect2(12, 8, 170, 38), 18, true, HORIZONTAL_ALIGNMENT_CENTER)
		var left := _arrow_button(row, "◀", Rect2(216, 7, 42, 40))
		left.pressed.connect(_change_option.bind(index, -1))
		var value := _add_text(row, OPTIONS[index][option_indices[index]], Rect2(260, 8, 136, 38), 17, true, HORIZONTAL_ALIGNMENT_CENTER)
		value_labels.append(value)
		var right := _arrow_button(row, "▶", Rect2(398, 7, 42, 40))
		right.pressed.connect(_change_option.bind(index, 1))

	if not has_exit_action:
		return
	var exit_button := Button.new()
	exit_button.position = Vector2(16, exit_button_y)
	exit_button.size = Vector2(452, 42)
	exit_button.text = "主菜单"
	exit_button.focus_mode = Control.FOCUS_NONE
	exit_button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	exit_button.add_theme_font_override("font", source_han_font)
	exit_button.add_theme_font_size_override("font_size", 12)
	exit_button.add_theme_color_override("font_color", Color.WHITE)
	exit_button.add_theme_color_override("font_hover_color", Color.WHITE)
	exit_button.add_theme_color_override("font_pressed_color", Color.WHITE)
	exit_button.add_theme_stylebox_override("normal", _pixel_button_style(MENU_BUTTON_NORMAL))
	exit_button.add_theme_stylebox_override("hover", _pixel_button_style(MENU_BUTTON_NORMAL, 0.0, Color(1.08, 1.05, 1.05, 1.0)))
	exit_button.add_theme_stylebox_override("pressed", _pixel_button_style(MENU_BUTTON_PRESSED, 1.0))
	exit_button.add_theme_stylebox_override("focus", _pixel_button_style(MENU_BUTTON_NORMAL))
	exit_button.pressed.connect(_exit_current_mode)
	overlay_frame.add_child(exit_button)


func _play_entrance() -> void:
	overlay_shade.modulate.a = 0.0
	overlay_frame.modulate.a = 0.0
	overlay_frame.scale = Vector2(0.92, 0.92)
	var tween := create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(overlay_shade, "modulate:a", 1.0, 0.24)
	tween.tween_property(overlay_frame, "modulate:a", 1.0, 0.24)
	tween.tween_property(overlay_frame, "scale", Vector2.ONE, 0.24)


func _close_overlay() -> void:
	if closing:
		return
	closing = true
	var tween := create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(overlay_shade, "modulate:a", 0.0, 0.16)
	tween.tween_property(overlay_frame, "modulate:a", 0.0, 0.16)
	tween.tween_property(overlay_frame, "scale", Vector2(0.96, 0.96), 0.16)
	tween.chain().tween_callback(queue_free)


func _exit_current_mode() -> void:
	if not exit_scene_path.is_empty():
		get_tree().change_scene_to_file(exit_scene_path)


func _change_option(row_index: int, direction: int) -> void:
	var values: Array = OPTIONS[row_index]
	option_indices[row_index] = posmod(option_indices[row_index] + direction, values.size())
	value_labels[row_index].text = values[option_indices[row_index]]
	_apply_option(row_index)


func _apply_option(row_index: int) -> void:
	match row_index:
		0:
			_apply_display_mode()
		1:
			if option_indices[0] != 0:
				_apply_windowed_size()
		2:
			_set_bus_volume("SFX", option_indices[2] * 0.25)
		3:
			_set_bus_volume("Music", option_indices[3] * 0.25)


func _apply_display_mode() -> void:
	match option_indices[0]:
		0:
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
			_apply_windowed_size()
		_:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			_apply_windowed_size()


func _apply_windowed_size() -> void:
	var sizes := [Vector2i(1280, 720), Vector2i(1600, 900), Vector2i(1920, 1080)]
	var target_size: Vector2i = sizes[option_indices[1]]
	DisplayServer.window_set_size(target_size)
	var screen := DisplayServer.window_get_current_screen()
	var usable_rect := DisplayServer.screen_get_usable_rect(screen)
	var centered_position := usable_rect.position + (usable_rect.size - target_size) / 2
	DisplayServer.window_set_position(centered_position)


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
	label.add_theme_color_override("font_color", Color("5d5f6b") if light_background else Color.WHITE)
	label.add_theme_color_override("font_shadow_color", Color("c5c6ce") if light_background else Color.BLACK)
	label.add_theme_color_override("font_outline_color", Color("5d5f6b") if light_background else Color.BLACK)
	label.add_theme_constant_override("outline_size", 1)
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label


func _install_pixel_button_visual(button: Button, font: Font) -> void:
	var button_text := button.text
	button.text = ""
	button.focus_mode = Control.FOCUS_NONE
	button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var transparent := StyleBoxFlat.new()
	transparent.bg_color = Color.TRANSPARENT
	button.add_theme_stylebox_override("normal", transparent)
	button.add_theme_stylebox_override("hover", transparent)
	button.add_theme_stylebox_override("pressed", transparent)
	button.add_theme_stylebox_override("focus", transparent)
	button.add_theme_stylebox_override("disabled", transparent)
	var visual := TextureRect.new()
	visual.name = "PixelBackground"
	visual.texture = MENU_BUTTON_NORMAL
	visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	visual.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	visual.stretch_mode = TextureRect.STRETCH_KEEP
	visual.size = MENU_BUTTON_NORMAL.get_size()
	visual.scale = Vector2.ONE * BUTTON_DISPLAY_SCALE
	visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	visual.show_behind_parent = true
	button.add_child(visual)
	var label := Label.new()
	label.name = "PixelLabel"
	label.position = Vector2.ZERO
	label.size = button.size
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.text = button_text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	label.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
	label.add_theme_constant_override("outline_size", 0)
	button.add_child(label)
	var center_visual := func() -> void:
		visual.position.x = (button.size.x - MENU_BUTTON_NORMAL.get_width() * BUTTON_DISPLAY_SCALE) * 0.5
		visual.position.y = (button.size.y - MENU_BUTTON_NORMAL.get_height() * BUTTON_DISPLAY_SCALE) * 0.5
		label.position = Vector2.ZERO
		label.size = button.size
	button.resized.connect(center_visual)
	center_visual.call()
	button.button_down.connect(func() -> void:
		visual.texture = MENU_BUTTON_PRESSED
		visual.position.x = (button.size.x - MENU_BUTTON_PRESSED.get_width() * BUTTON_DISPLAY_SCALE) * 0.5
		visual.position.y = (button.size.y - MENU_BUTTON_PRESSED.get_height() * BUTTON_DISPLAY_SCALE) * 0.5 + 1.0
		label.position.y = 1.0
	)
	button.button_up.connect(func() -> void:
		visual.texture = MENU_BUTTON_NORMAL
		center_visual.call()
	)
	button.mouse_exited.connect(func() -> void:
		if not button.button_pressed:
			visual.texture = MENU_BUTTON_NORMAL
			center_visual.call()
	)


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


func _pixel_button_style(
	texture: Texture2D,
	pressed_offset := 0.0,
	modulate := Color.WHITE,
) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = texture
	style.modulate_color = modulate
	style.texture_margin_left = 3.0
	style.texture_margin_top = 3.0
	style.texture_margin_right = 3.0
	style.texture_margin_bottom = 3.0
	style.content_margin_left = 28.0
	style.content_margin_top = 12.0 + pressed_offset
	style.content_margin_right = 28.0
	style.content_margin_bottom = 12.0
	return style
