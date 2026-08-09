extends Control

var state_label: Label


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color("#6b7078")
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	state_label = Label.new()
	state_label.set_anchors_preset(Control.PRESET_CENTER)
	state_label.position = Vector2(-170, -34)
	state_label.size = Vector2(340, 68)
	state_label.text = "普通 / 按下光标检查"
	state_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	state_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	state_label.add_theme_font_size_override("font_size", 22)
	add_child(state_label)

	CursorManager.set_dragging(false)
	await get_tree().create_timer(4.0).timeout
	state_label.text = "拖动光标两帧检查"
	CursorManager.set_dragging(true)
	CursorManager.set_process(false)
	CursorManager.drag_frame = 0
	CursorManager._apply_cursor()
	await get_tree().create_timer(1.0).timeout
	CursorManager.drag_frame = 1
	CursorManager._apply_cursor()
	await get_tree().create_timer(1.0).timeout
	CursorManager.set_process(true)
	CursorManager.set_dragging(false)
	get_tree().quit()
