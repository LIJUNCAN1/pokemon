extends Control

const VERSION := "v0.1.0  ·  PRE-ALPHA"

@onready var background: TextureRect = $Background
@onready var background_material: ShaderMaterial = background.material
@onready var logo: TextureRect = $Logo
@onready var logo_glow: TextureRect = $LogoGlow
@onready var menu_band: ColorRect = $MenuBand
@onready var menu_content: VBoxContainer = $MenuContent
@onready var status_label: Label = $MenuContent/Status
@onready var version_label: Label = $Version
@onready var fade: ColorRect = $Fade
@onready var buttons: Array[Button] = [
	$MenuContent/MenuButtons/StartButton,
	$MenuContent/MenuButtons/SettingsButton,
	$MenuContent/MenuButtons/RoadmapButton,
	$MenuContent/MenuButtons/ExitButton,
]

var elapsed := 0.0
var logo_base_y := 0.0
var mouse_parallax := Vector2.ZERO
var status_tween: Tween


func _ready() -> void:
	_build_pixel_theme()
	_connect_buttons()
	version_label.text = VERSION
	logo_base_y = logo.position.y
	_play_intro()
	get_viewport().size_changed.connect(_on_viewport_resized)
	_on_viewport_resized()
	buttons[0].grab_focus.call_deferred()


func _process(delta: float) -> void:
	elapsed += delta
	var viewport_size := get_viewport_rect().size
	var mouse_ratio := (get_viewport().get_mouse_position() / viewport_size) - Vector2(0.5, 0.5)
	mouse_parallax = mouse_parallax.lerp(mouse_ratio * Vector2(0.008, 0.005), delta * 2.4)
	background_material.set_shader_parameter("parallax_offset", mouse_parallax)

	var bob := sin(elapsed * 1.45) * 5.0
	logo.position.y = logo_base_y + bob
	logo_glow.position.y = logo.position.y + 4.0
	logo_glow.modulate.a = 0.13 + sin(elapsed * 1.8) * 0.035


func _build_pixel_theme() -> void:
	var pixel_font := SystemFont.new()
	pixel_font.font_names = PackedStringArray(["SimSun", "NSimSun", "Microsoft YaHei UI"])
	pixel_font.antialiasing = TextServer.FONT_ANTIALIASING_NONE
	pixel_font.hinting = TextServer.HINTING_NORMAL
	pixel_font.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	pixel_font.oversampling = 1.0

	var normal := _make_button_box(Color(0.025, 0.05, 0.065, 0.48), Color(0.38, 0.68, 0.75, 0.45), 2)
	var hover := _make_button_box(Color(0.04, 0.16, 0.20, 0.82), Color(0.42, 0.93, 1.0, 0.95), 3)
	var pressed := _make_button_box(Color(0.09, 0.25, 0.28, 0.95), Color(1.0, 0.87, 0.32, 1.0), 3)
	var focus := hover.duplicate()

	for button in buttons:
		button.add_theme_font_override("font", pixel_font)
		button.add_theme_font_size_override("font_size", 22)
		button.add_theme_color_override("font_color", Color(0.9, 0.98, 1.0))
		button.add_theme_color_override("font_hover_color", Color(1.0, 0.91, 0.42))
		button.add_theme_color_override("font_focus_color", Color(1.0, 0.91, 0.42))
		button.add_theme_color_override("font_pressed_color", Color.WHITE)
		button.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
		button.add_theme_constant_override("shadow_offset_x", 3)
		button.add_theme_constant_override("shadow_offset_y", 3)
		button.add_theme_stylebox_override("normal", normal)
		button.add_theme_stylebox_override("hover", hover)
		button.add_theme_stylebox_override("pressed", pressed)
		button.add_theme_stylebox_override("focus", focus)

	for label in [$MenuContent/MenuHint, status_label, version_label]:
		label.add_theme_font_override("font", pixel_font)


func _make_button_box(fill_color: Color, border_color: Color, border_width: int) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill_color
	box.border_color = border_color
	box.set_border_width_all(border_width)
	box.corner_radius_top_left = 2
	box.corner_radius_top_right = 2
	box.corner_radius_bottom_left = 2
	box.corner_radius_bottom_right = 2
	box.content_margin_left = 18.0
	box.content_margin_right = 18.0
	box.shadow_color = Color(0, 0, 0, 0.5)
	box.shadow_size = 5
	box.shadow_offset = Vector2(0, 4)
	return box


func _connect_buttons() -> void:
	for button in buttons:
		button.mouse_entered.connect(_on_button_highlighted.bind(button))
		button.focus_entered.connect(_on_button_highlighted.bind(button))
		button.mouse_exited.connect(_on_button_unhighlighted.bind(button))
		button.focus_exited.connect(_on_button_unhighlighted.bind(button))

	buttons[0].pressed.connect(_on_start_pressed)
	buttons[1].pressed.connect(_on_settings_pressed)
	buttons[2].pressed.connect(_on_roadmap_pressed)
	buttons[3].pressed.connect(_on_exit_pressed)


func _play_intro() -> void:
	logo.modulate.a = 0.0
	logo_glow.modulate.a = 0.0
	menu_band.modulate.a = 0.0
	menu_content.modulate.a = 0.0
	version_label.modulate.a = 0.0
	logo.position.y -= 22.0

	var tween := create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(logo, "modulate:a", 1.0, 0.75).set_delay(0.15)
	tween.tween_property(logo, "position:y", logo_base_y, 0.85).set_delay(0.15)
	tween.tween_property(logo_glow, "modulate:a", 0.15, 1.0).set_delay(0.3)
	tween.tween_property(menu_band, "modulate:a", 1.0, 0.65).set_delay(0.55)
	tween.tween_property(menu_content, "modulate:a", 1.0, 0.65).set_delay(0.72)
	tween.tween_property(version_label, "modulate:a", 1.0, 0.6).set_delay(0.95)


func _on_button_highlighted(button: Button) -> void:
	button.pivot_offset = button.size * 0.5
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", Vector2(1.055, 1.055), 0.16)


func _on_button_unhighlighted(button: Button) -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", Vector2.ONE, 0.14)


func _show_status(message: String) -> void:
	status_label.text = message
	status_label.modulate.a = 0.0
	if status_tween and status_tween.is_valid():
		status_tween.kill()
	status_tween = create_tween()
	status_tween.tween_property(status_label, "modulate:a", 1.0, 0.18)
	status_tween.tween_interval(1.5)
	status_tween.tween_property(status_label, "modulate:a", 0.0, 0.5)


func _on_start_pressed() -> void:
	_show_status("冒险即将开始 · 敬请期待")


func _on_settings_pressed() -> void:
	_show_status("设置菜单正在制作中")


func _on_roadmap_pressed() -> void:
	_show_status("更新规划页面正在制作中")


func _on_exit_pressed() -> void:
	for button in buttons:
		button.disabled = true
	var tween := create_tween()
	tween.tween_property(fade, "color:a", 1.0, 0.35)
	tween.tween_callback(get_tree().quit)


func _on_viewport_resized() -> void:
	var viewport_width := get_viewport_rect().size.x
	var scale_factor: float = clamp(viewport_width / 1280.0, 0.72, 1.2)
	logo.scale = Vector2.ONE * scale_factor
	logo_glow.scale = Vector2.ONE * scale_factor
	logo.pivot_offset = logo.size * 0.5
	logo_glow.pivot_offset = logo_glow.size * 0.5
