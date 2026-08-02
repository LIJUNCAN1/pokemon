extends Control

const VERSION := "v0.1.0  ·  PRE-ALPHA"
const PIXEL_FONT: FontFile = preload("res://assets/fonts/ark-pixel-12px-proportional-zh_cn.ttf")
const DESIGN_SIZE := Vector2(1280, 720)
const FULL_HD_SCALE := Vector2(1.5, 1.5)

@onready var background: TextureRect = $Background
@onready var background_material: ShaderMaterial = background.material
@onready var logo: TextureRect = $Logo
@onready var menu_music: AudioStreamPlayer = $MenuMusic
@onready var menu_band: ColorRect = $MenuBand
@onready var menu_content: VBoxContainer = $MenuContent
@onready var status_label: Label = $MenuContent/Status
@onready var version_label: Label = $Version
@onready var intro_curtain: Control = $IntroCurtain
@onready var top_curtain: ColorRect = $IntroCurtain/Top
@onready var bottom_curtain: ColorRect = $IntroCurtain/Bottom
@onready var press_any_key: Label = $PressAnyKey
@onready var fade: ColorRect = $Fade
@onready var buttons: Array[Button] = [
	$MenuContent/MenuButtons/StartButton,
	$MenuContent/MenuButtons/SettingsButton,
	$MenuContent/MenuButtons/RoadmapButton,
	$MenuContent/MenuButtons/ExitButton,
]

var elapsed := 0.0
var logo_base_y := 0.0
var logo_target_position := Vector2.ZERO
var logo_target_scale := Vector2.ONE
var mouse_parallax := Vector2.ZERO
var status_tween: Tween
var waiting_for_start := false
var logo_at_menu := false


func _ready() -> void:
	_apply_full_hd_layout()
	_build_pixel_theme()
	_connect_buttons()
	version_label.text = VERSION
	get_viewport().size_changed.connect(_on_viewport_resized)
	_on_viewport_resized()
	logo_base_y = logo.position.y
	logo_target_position = logo.position
	logo_target_scale = logo.scale
	status_label.modulate.a = 0.0
	_play_intro.call_deferred()


func _apply_full_hd_layout() -> void:
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	position = Vector2.ZERO
	size = DESIGN_SIZE
	scale = FULL_HD_SCALE


func _process(delta: float) -> void:
	elapsed += delta
	var viewport_size := get_viewport_rect().size
	var mouse_ratio := (get_viewport().get_mouse_position() / viewport_size) - Vector2(0.5, 0.5)
	mouse_parallax = mouse_parallax.lerp(mouse_ratio * Vector2(0.008, 0.005), delta * 2.4)
	background_material.set_shader_parameter("parallax_offset", mouse_parallax)

	if logo_at_menu:
		var bob := sin(elapsed * 1.45) * 4.0
		logo.position.y = logo_base_y + bob

	if waiting_for_start:
		press_any_key.modulate.a = 0.48 + (sin(elapsed * 3.2) + 1.0) * 0.26


func _build_pixel_theme() -> void:
	var pixel_font := PIXEL_FONT.duplicate() as FontFile
	pixel_font.antialiasing = TextServer.FONT_ANTIALIASING_NONE
	pixel_font.hinting = TextServer.HINTING_NONE
	pixel_font.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	pixel_font.oversampling = 1.0
	pixel_font.allow_system_fallback = false

	var normal := _make_button_box(Color(0.025, 0.05, 0.065, 0.48), Color(0.38, 0.68, 0.75, 0.45), 2)
	var hover := _make_button_box(Color(0.04, 0.16, 0.20, 0.82), Color(0.42, 0.93, 1.0, 0.95), 3)
	var pressed := _make_button_box(Color(0.09, 0.25, 0.28, 0.95), Color(1.0, 0.87, 0.32, 1.0), 3)
	var focus := hover.duplicate()

	for button in buttons:
		button.add_theme_font_override("font", pixel_font)
		button.add_theme_font_size_override("font_size", 24)
		button.add_theme_color_override("font_color", Color.WHITE)
		button.add_theme_color_override("font_hover_color", Color.WHITE)
		button.add_theme_color_override("font_focus_color", Color.WHITE)
		button.add_theme_color_override("font_pressed_color", Color.WHITE)
		button.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
		button.add_theme_constant_override("shadow_offset_x", 3)
		button.add_theme_constant_override("shadow_offset_y", 3)
		button.add_theme_stylebox_override("normal", normal)
		button.add_theme_stylebox_override("hover", hover)
		button.add_theme_stylebox_override("pressed", pressed)
		button.add_theme_stylebox_override("focus", focus)

	for label in [$MenuContent/MenuHint, status_label, version_label, press_any_key]:
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
	for button in buttons:
		button.disabled = true
	logo.modulate.a = 0.0
	menu_band.modulate.a = 0.0
	menu_content.modulate.a = 0.0
	version_label.modulate.a = 0.0
	press_any_key.modulate.a = 0.0

	await get_tree().process_frame
	var viewport_size := get_viewport_rect().size
	logo.position = (viewport_size - logo.size) * 0.5
	logo.scale = logo_target_scale * 1.15

	var appear := create_tween()
	appear.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	appear.tween_property(logo, "modulate:a", 1.0, 0.7)
	await appear.finished
	await get_tree().create_timer(1.8).timeout

	var move_logo := create_tween().set_parallel(true)
	move_logo.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	move_logo.tween_property(logo, "position", logo_target_position, 0.95)
	move_logo.tween_property(logo, "scale", logo_target_scale, 0.95)
	await move_logo.finished
	logo_base_y = logo_target_position.y
	logo_at_menu = true
	await get_tree().create_timer(0.2).timeout

	var open_curtain := create_tween().set_parallel(true)
	open_curtain.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	open_curtain.tween_property(top_curtain, "position:y", -top_curtain.size.y - 4.0, 1.15)
	open_curtain.tween_property(bottom_curtain, "position:y", bottom_curtain.position.y + bottom_curtain.size.y + 4.0, 1.15)
	await open_curtain.finished
	_start_menu_music()
	waiting_for_start = true
	press_any_key.modulate.a = 1.0


func _start_menu_music() -> void:
	if menu_music.playing:
		return
	var mp3_stream := menu_music.stream as AudioStreamMP3
	if mp3_stream:
		mp3_stream.loop = true
	menu_music.volume_db = -40.0
	menu_music.play()
	var music_fade := create_tween()
	music_fade.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	music_fade.tween_property(menu_music, "volume_db", -12.0, 2.2)


func _unhandled_input(event: InputEvent) -> void:
	if not waiting_for_start or not event.is_pressed():
		return
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton:
		waiting_for_start = false
		get_viewport().set_input_as_handled()
		_show_main_menu()


func _show_main_menu() -> void:
	var reveal := create_tween().set_parallel(true)
	reveal.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	reveal.tween_property(press_any_key, "modulate:a", 0.0, 0.25)
	reveal.tween_property(menu_band, "modulate:a", 1.0, 0.55).set_delay(0.15)
	reveal.tween_property(menu_content, "modulate:a", 1.0, 0.6).set_delay(0.3)
	reveal.tween_property(version_label, "modulate:a", 1.0, 0.5).set_delay(0.45)
	await reveal.finished
	for button in buttons:
		button.disabled = false
	buttons[0].grab_focus()


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
	for button in buttons:
		button.disabled = true
	var transition := create_tween().set_parallel(true)
	transition.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	transition.tween_property(fade, "color:a", 1.0, 0.45)
	transition.tween_property(menu_music, "volume_db", -40.0, 0.4)
	await transition.finished
	GameState.reset_run()
	get_tree().change_scene_to_file("res://battle_prep.tscn")


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
	var viewport_width := get_viewport_rect().size.x / FULL_HD_SCALE.x
	var scale_factor: float = clamp(viewport_width / 1280.0, 0.72, 1.2)
	logo.scale = Vector2.ONE * scale_factor
	logo.pivot_offset = logo.size * 0.5
	if logo_at_menu:
		logo_target_position = logo.position
		logo_target_scale = logo.scale
		logo_base_y = logo.position.y
