extends Node

const NORMAL_CURSOR: Texture2D = preload("res://素材/地图/cursor/normal.png")
const PRESSED_CURSOR: Texture2D = preload("res://素材/地图/cursor/pressed.png")
const DRAG_CURSOR_0: Texture2D = preload("res://素材/地图/cursor/drag_0.png")
const DRAG_CURSOR_1: Texture2D = preload("res://素材/地图/cursor/drag_1.png")
const DETAIL_CURSOR: Texture2D = preload("res://素材/主菜单/deteai2l.png")
const POINTER_HOTSPOT := Vector2(12, 12)
const DRAG_HOTSPOT := Vector2(21, 3)
const DETAIL_HOTSPOT := Vector2(8, 8)
const DRAG_FRAME_TIME := 0.14
const MANAGED_SHAPES: Array[int] = [
	Input.CURSOR_ARROW,
	Input.CURSOR_POINTING_HAND,
	Input.CURSOR_DRAG,
	Input.CURSOR_CAN_DROP,
	Input.CURSOR_FORBIDDEN,
]

var left_pressed := false
var dragging_unit := false
var inspecting_card := false
var drag_frame := 0
var drag_elapsed := 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_apply_cursor()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		left_pressed = event.pressed
		_apply_cursor()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and not event.pressed:
		set_inspecting(false)


func _process(delta: float) -> void:
	if not dragging_unit:
		return
	drag_elapsed += delta
	if drag_elapsed < DRAG_FRAME_TIME:
		return
	drag_elapsed = fmod(drag_elapsed, DRAG_FRAME_TIME)
	drag_frame = 1 - drag_frame
	_apply_cursor()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		left_pressed = false
		set_inspecting(false)
		set_dragging(false)


func set_dragging(value: bool) -> void:
	if dragging_unit == value:
		return
	dragging_unit = value
	drag_frame = 0
	drag_elapsed = 0.0
	_apply_cursor()


func set_inspecting(value: bool) -> void:
	if inspecting_card == value:
		return
	inspecting_card = value
	_apply_cursor()


func _apply_cursor() -> void:
	var texture := NORMAL_CURSOR
	var hotspot := POINTER_HOTSPOT
	if dragging_unit:
		texture = DRAG_CURSOR_1 if drag_frame == 1 else DRAG_CURSOR_0
		hotspot = DRAG_HOTSPOT
	elif inspecting_card:
		texture = DETAIL_CURSOR
		hotspot = DETAIL_HOTSPOT
	elif left_pressed:
		texture = PRESSED_CURSOR
	for cursor_shape in MANAGED_SHAPES:
		Input.set_custom_mouse_cursor(texture, cursor_shape, hotspot)
