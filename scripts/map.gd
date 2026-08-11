extends Control

const SOURCE_HAN_FONT: FontFile = preload("res://assets/fonts/SourceHanSansSC-Heavy.otf")
const ITEM_CATALOG = preload("res://scripts/item_catalog.gd")
const CREATURE_CATALOG = preload("res://scripts/creature_catalog.gd")
const DESIGN_SIZE := Vector2(1280, 720)
const FULL_HD_SCALE := Vector2(0.5, 0.5)
const REFERENCE_SIZE := Vector2(1672, 941)
const REFERENCE_SCALE := Vector2(DESIGN_SIZE.x / REFERENCE_SIZE.x, DESIGN_SIZE.y / REFERENCE_SIZE.y)
const EVENT := "res://素材/事件/"
const EVENT_ILLUSTRATION_FRAME := EVENT + "aseprite_export/event_illustration_frame.png"
const EVENT_OPTION_FRAME := EVENT + "aseprite_export/event_option.png"
const EVENT_TEXT_BOX := EVENT + "aseprite_export/event_text_box.png"
const EVENT_PLACEHOLDER_ROOT := "res://assets/event_placeholders/"
const EVENT_STORY_ILLUSTRATIONS: Array[String] = [
	"res://assets/events/forest_relic.png",
	EVENT_PLACEHOLDER_ROOT + "storm_station.jpg",
	EVENT_PLACEHOLDER_ROOT + "hatching_garden.jpg",
	EVENT_PLACEHOLDER_ROOT + "lantern_market.jpg",
	EVENT_PLACEHOLDER_ROOT + "snow_rescue.jpg",
	EVENT_PLACEHOLDER_ROOT + "forgotten_chest.jpg",
	"res://assets/events/forest_crystal.png",
	"res://assets/events/crystal_surprise.png",
]
const EVENT_STORY_TITLES: Array[String] = [
	"月光遗迹", "暴雨中的旧驿站", "沉睡的孵化庭院", "灯火流动集市",
	"雪原救援", "回声化石洞穴", "林间晶石", "幸运闪光",
]
const EVENT_CHEST_ILLUSTRATION := EVENT_PLACEHOLDER_ROOT + "forgotten_chest.jpg"
const CHEST_SHEET: Texture2D = preload("res://assets/ui/chest/chests.png")
const CHEST_FRAME_SIZE := Vector2i(48, 32)
const SCENE_ASSETS := "res://素材/场景/"
const MAP_ASSETS := "res://素材/地图/"
const POKEMON := "res://素材/宝可梦图/"
const MAP_PREP_MUSIC := "res://assets/audio/pixel_mountain_quest.mp3"
const EVENT_CREATURES: Array[String] = [
	POKEMON + "1 (1).png", POKEMON + "1 (2).png", POKEMON + "1 (3).png",
	POKEMON + "1 (4).png", POKEMON + "1 (5).png", POKEMON + "1 (6).png",
	POKEMON + "1 (7).png", POKEMON + "1 (8).png", POKEMON + "1 (9).png",
	POKEMON + "1 (10).png", POKEMON + "图层 2.png", POKEMON + "图层 3.png",
	POKEMON + "图层 4.png", POKEMON + "图层 5.png", POKEMON + "图层 6.png",
]
const EVENT_CREATURE_NAMES: Array[String] = [
	"芽叶兽", "钢甲象", "烛灵", "岩甲龟", "夜翼兽", "冰角鹿", "菌盖兽", "深海贤者",
	"绵云羊", "烈焰犬", "花叶兽", "铁壳蛛", "星云兽", "花甲虫", "熔岩蛛",
]
const REWARD_COLORS := {
	"attribute": Color("ef466f"),
	"item": Color("e2a93b"),
	"accessory": Color("c77be8"),
	"creature": Color("668fe5"),
	"coins": Color("e6c454"),
	"story": Color("667080"),
}
const NODE_LABELS := {
	"start": "起点",
	"battle": "战斗",
	"elite": "精英",
	"shop": "商店",
	"event": "事件",
	"chest": "宝箱",
	"rest": "休息",
	"boss": "BOSS",
}
const NODE_COLORS := {
	"start": Color("55b9ca"),
	"battle": Color("d95b62"),
	"elite": Color("ad5de0"),
	"shop": Color("e2ad45"),
	"event": Color("58a8df"),
	"chest": Color("d9982f"),
	"rest": Color("9a65dc"),
	"boss": Color("ef3d45"),
}
const NODE_FRAME_ASSET := MAP_ASSETS + "未选中框1.png"
const NODE_SELECTED_FRAME_ASSET := MAP_ASSETS + "选中框1.png"
const NODE_VISITED_MASK_ASSET := MAP_ASSETS + "node-visited-mask.png"
const MAP_LAYER_ROOT := "res://素材/地图/aseprite_layers/"
const MAP_NODE_X_STRETCH := 1.90
const MAP_NODE_Y_STRETCH := 1.20
const MAP_NODE_X_ANCHOR := 139.0
const MAP_NODE_Y_ANCHOR := 450.0
const MAP_CONTENT_WIDTH := 3000.0
const MAP_VIEWPORT_POSITION := Vector2(53, 178)
const MAP_VIEWPORT_SIZE := Vector2(1566, 548)
const MAP_CAMERA_LEFT_OVERSCAN := -110.0
const NODE_ICON_ASSETS := {
	"start": MAP_ASSETS + "战斗icon.png",
	"battle": MAP_ASSETS + "战斗icon.png",
	"elite": MAP_ASSETS + "精英icon.png",
	"shop": MAP_ASSETS + "休息icon.png",
	"event": MAP_ASSETS + "事件icon.png",
	"chest": MAP_ASSETS + "奖励icon.png",
	"rest": MAP_ASSETS + "休息节点icon.png",
	"boss": MAP_ASSETS + "boss2.png",
}

var source_han_font: FontFile
var rng := RandomNumberGenerator.new()
var world: Control
var map_viewport: Control
var map_content: Control
var hero: Control
var node_buttons: Dictionary = {}
var node_hover_frames: Dictionary = {}
var node_state_overlays: Dictionary = {}
var input_locked := false
var status_label: Label
var coin_label: Label
var event_overlay: Control
var event_option_area: Control
var event_description: RichTextLabel
var event_corner_groups: Array = []
var event_corner_tween: Tween
var event_story_id := 0
var event_stage_id := "root"
var event_consumable: Dictionary = {}
var event_loot: Dictionary = {}
var event_creature_path := ""
var event_creature_name := ""
var event_result_text := ""
var event_result_kind := "story"
var chest_event := false
var rest_event := false
var chest_coin_amount := 0
var chest_choices: Array[Dictionary] = []
var node_info_detail: Label
var node_info_hint: Label
var settings_overlay: Control
var map_drag_pending := false
var map_drag_active := false
var map_drag_suppress_click := false
var map_drag_distance := 0.0
var tutorial_overlay: Control
var tutorial_shade_layer: Control
var tutorial_dialogue: Label
var tutorial_step := 0
const TUTORIAL_STEPS: Array[Dictionary] = [
	{"focus": Rect2(40, 20, 370, 80), "text": "欢迎来到怪兽远征。我是森野博士。这里会显示当前区域与层数，击败区域尽头的首领才能继续前进。"},
	{"focus": Rect2(70, 185, 1110, 360), "text": "地图由多条路线组成。只能前往与当前节点相连的下一站；战斗、事件、营地和宝箱会带来不同风险与奖励。"},
	{"focus": Rect2(25, 585, 1230, 110), "text": "节点图例会告诉你即将遇到的内容。先观察后选择路线，构筑需要的怪兽、羁绊、道具与饰品。"},
	{"focus": Rect2(1120, 12, 125, 75), "text": "键盘可用鼠标操作，Esc 打开设置；手柄可用方向键移动焦点并确认。准备好后，选择发亮的节点开始远征。"},
]


func _ready() -> void:
	_apply_full_hd_layout()
	MusicManager.play_music(MAP_PREP_MUSIC, 1.2)
	source_han_font = SOURCE_HAN_FONT.duplicate() as FontFile
	source_han_font.antialiasing = TextServer.FONT_ANTIALIASING_GRAY
	source_han_font.multichannel_signed_distance_field = true
	source_han_font.msdf_pixel_range = 8
	source_han_font.msdf_size = 64
	source_han_font.hinting = TextServer.HINTING_NORMAL
	source_han_font.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	source_han_font.oversampling = FULL_HD_SCALE.x
	source_han_font.allow_system_fallback = false
	var opening_node_valid := (
		GameState.map_initialized
		and GameState.map_nodes.size() == 23
		and String(GameState.map_nodes[0].get("type", "")) == "chest"
		and bool(GameState.map_nodes[0].get("mimic", false))
		and _route_edges_are_ordered(GameState.map_edges)
	)
	if not opening_node_valid:
		_generate_map()
	input_locked = not GameState.map_intro_played
	_build_interface()
	_position_map_on_entry.call_deferred()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		if not is_instance_valid(settings_overlay):
			get_viewport().set_input_as_handled()
			_open_map_settings()


func _input(event: InputEvent) -> void:
	if input_locked or not is_instance_valid(map_viewport) or not is_instance_valid(map_content) or is_instance_valid(event_overlay) or is_instance_valid(settings_overlay):
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var local_position: Vector2 = map_viewport.get_global_transform_with_canvas().affine_inverse() * event.position
			if Rect2(Vector2.ZERO, map_viewport.size).has_point(local_position):
				map_drag_pending = true
				map_drag_active = false
				map_drag_distance = 0.0
		else:
			if map_drag_active:
				map_drag_suppress_click = true
				_clear_map_drag_suppression.call_deferred()
			map_drag_pending = false
			map_drag_active = false
	elif event is InputEventMouseMotion and map_drag_pending and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var local_delta: Vector2 = map_viewport.get_global_transform_with_canvas().basis_xform_inv(event.relative)
		map_drag_distance += absf(local_delta.x)
		if map_drag_distance >= 8.0:
			map_drag_active = true
		if map_drag_active:
			_pan_map(local_delta.x)


func _clear_map_drag_suppression() -> void:
	await get_tree().process_frame
	map_drag_suppress_click = false


func _pan_map(horizontal_delta: float) -> void:
	map_content.position.x = clampf(
		map_content.position.x + horizontal_delta,
		_map_content_min_x(),
		_map_content_max_x()
	)


func _apply_full_hd_layout() -> void:
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	position = Vector2.ZERO
	size = DESIGN_SIZE
	scale = FULL_HD_SCALE


func _generate_map() -> void:
	rng.randomize()
	var seed_value := rng.randi() ^ (GameState.floor * 104729)
	rng.seed = seed_value
	var nodes: Array[Dictionary] = []
	var middle_types := _shuffled_middle_types()
	var mimic_columns: Dictionary = {}
	for spec in _reference_node_specs():
		var node_id := int(spec["id"])
		var column := int(spec["column"])
		var node_type := "chest" if node_id == 0 else String(spec["type"])
		if node_id == 22:
			node_type = "boss" if GameState.is_region_boss_floor() else "elite"
		elif node_id > 0:
			node_type = middle_types[node_id - 1]
		var position: Vector2 = spec["center"]
		if node_id > 0 and node_id < 22:
			position += Vector2(rng.randi_range(-12, 12), rng.randi_range(-12, 12))
			position.y = clampf(position.y, 280.0, 620.0)
		var node := {
			"id": node_id,
			"column": column,
			"type": node_type,
			"position": position,
		}
		if node_id == 0:
			node["mimic"] = true
			node["opening"] = true
		elif node_type == "chest" and not mimic_columns.has(column) and not mimic_columns.has(column - 1) and rng.randf() < 0.20:
			node["mimic"] = true
			mimic_columns[column] = true
		nodes.append(node)
	var edges := _generate_route_edges()
	GameState.set_map_data(seed_value, nodes, edges)


func _shuffled_middle_types() -> Array[String]:
	# Each floor keeps a useful content mix, while the locations change with
	# the saved map seed. This prevents all-combat or no-event floors.
	var result: Array[String] = [
		"battle", "battle", "battle", "battle", "battle", "battle", "battle", "battle", "battle",
		"event", "event", "event",
		"chest", "chest", "chest",
		"shop", "shop",
		"rest", "rest",
		"elite", "elite",
	]
	for index in range(result.size() - 1, 0, -1):
		var swap_index := rng.randi_range(0, index)
		var value := result[index]
		result[index] = result[swap_index]
		result[swap_index] = value
	return result


func _generate_route_edges() -> Dictionary:
	var edges: Dictionary = {0: [1, 2, 3], 22: []}
	# Every template preserves vertical order. Routes may split or merge at a
	# shared node, but an upper route can never cross beneath a lower route.
	var route_patterns: Array = [
		[[0], [1], [2]],
		[[0, 1], [1], [2]],
		[[0], [0, 1], [2]],
		[[0], [1, 2], [2]],
		[[0], [1], [1, 2]],
		[[0, 1], [1, 2], [2]],
		[[0], [0, 1], [1, 2]],
		[[0], [0, 1, 2], [2]],
	]
	for column in range(1, 7):
		var current_start := 1 + (column - 1) * 3
		var next_start := current_start + 3
		var pattern: Array = route_patterns[rng.randi_range(0, route_patterns.size() - 1)]
		for row in 3:
			var from_id := current_start + row
			var targets: Array[int] = []
			for target_row in pattern[row]:
				targets.append(next_start + int(target_row))
			edges[from_id] = targets
	for node_id in range(19, 22):
		edges[node_id] = [22]
	return edges


func _route_edges_are_ordered(edges: Dictionary) -> bool:
	if edges.is_empty():
		return false
	for column in range(1, 7):
		var current_start := 1 + (column - 1) * 3
		var next_start := current_start + 3
		var previous_target_row := -1
		for source_row in 3:
			var source_id := current_start + source_row
			var targets: Array = edges.get(source_id, [])
			if targets.is_empty():
				return false
			var sorted_target_rows: Array[int] = []
			for target_id in targets:
				var target_row := int(target_id) - next_start
				if target_row < 0 or target_row > 2:
					return false
				sorted_target_rows.append(target_row)
			sorted_target_rows.sort()
			if sorted_target_rows[0] < previous_target_row:
				return false
			previous_target_row = sorted_target_rows[sorted_target_rows.size() - 1]
	return true


func _reference_node_specs() -> Array[Dictionary]:
	return [
		{"id": 0, "column": 0, "type": "start", "center": Vector2(139, 450), "rect": Rect2(86, 393, 106, 115), "asset": "start-node.png"},
		{"id": 1, "column": 1, "type": "battle", "center": Vector2(331, 307), "rect": Rect2(292, 264, 78, 87), "asset": "r1-c1-normal.png"},
		{"id": 2, "column": 1, "type": "event", "center": Vector2(333, 450), "rect": Rect2(294, 407, 78, 87), "asset": "r2-c1-event.png"},
		{"id": 3, "column": 1, "type": "battle", "center": Vector2(335, 595), "rect": Rect2(296, 552, 78, 87), "asset": "r3-c1-normal.png"},
		{"id": 4, "column": 2, "type": "chest", "center": Vector2(517, 307), "rect": Rect2(478, 264, 78, 87), "asset": "r1-c2-treasure.png"},
		{"id": 5, "column": 2, "type": "rest", "center": Vector2(517, 450), "rect": Rect2(478, 407, 78, 87), "asset": "r2-c2-rest.png"},
		{"id": 6, "column": 2, "type": "rest", "center": Vector2(518, 595), "rect": Rect2(479, 552, 78, 87), "asset": "r3-c2-rest.png"},
		{"id": 7, "column": 3, "type": "elite", "center": Vector2(698, 307), "rect": Rect2(659, 264, 79, 87), "asset": "r1-c3-elite.png"},
		{"id": 8, "column": 3, "type": "battle", "center": Vector2(701, 450), "rect": Rect2(662, 407, 79, 87), "asset": "r2-c3-normal.png"},
		{"id": 9, "column": 3, "type": "event", "center": Vector2(703, 595), "rect": Rect2(664, 552, 79, 87), "asset": "r3-c3-event.png"},
		{"id": 10, "column": 4, "type": "shop", "center": Vector2(908, 307), "rect": Rect2(869, 264, 78, 87), "asset": "r1-c4-shop.png"},
		{"id": 11, "column": 4, "type": "chest", "center": Vector2(910, 450), "rect": Rect2(871, 407, 78, 87), "asset": "r2-c4-treasure.png"},
		{"id": 12, "column": 4, "type": "shop", "center": Vector2(909, 595), "rect": Rect2(870, 552, 79, 87), "asset": "r3-c4-shop.png"},
		{"id": 13, "column": 5, "type": "battle", "center": Vector2(1097, 307), "rect": Rect2(1058, 264, 79, 87), "asset": "r1-c5-normal.png"},
		{"id": 14, "column": 5, "type": "chest", "center": Vector2(1098, 450), "rect": Rect2(1059, 407, 78, 87), "asset": "r2-c5-treasure.png"},
		{"id": 15, "column": 5, "type": "elite", "center": Vector2(1096, 595), "rect": Rect2(1057, 552, 79, 87), "asset": "r3-c5-elite.png"},
		{"id": 16, "column": 6, "type": "rest", "center": Vector2(1280, 307), "rect": Rect2(1241, 264, 79, 87), "asset": "r1-c6-rest.png"},
		{"id": 17, "column": 6, "type": "battle", "center": Vector2(1282, 450), "rect": Rect2(1243, 407, 78, 87), "asset": "r2-c6-normal.png"},
		{"id": 18, "column": 6, "type": "shop", "center": Vector2(1282, 595), "rect": Rect2(1243, 552, 78, 87), "asset": "r3-c6-shop.png"},
		{"id": 19, "column": 7, "type": "battle", "center": Vector2(1446, 307), "rect": Rect2(1407, 264, 78, 87), "asset": "r1-c7-normal.png"},
		{"id": 20, "column": 7, "type": "battle", "center": Vector2(1447, 450), "rect": Rect2(1408, 407, 78, 87), "asset": "r2-c7-normal.png"},
		{"id": 21, "column": 7, "type": "battle", "center": Vector2(1446, 595), "rect": Rect2(1407, 552, 79, 87), "asset": "r3-c7-normal.png"},
		{"id": 22, "column": 8, "type": "boss", "center": Vector2(1573, 454), "rect": Rect2(1525, 406, 96, 96), "asset": "boss-node.png"},
	]


func _build_interface() -> void:
	world = Control.new()
	world.position = Vector2.ZERO
	world.size = REFERENCE_SIZE
	world.scale = REFERENCE_SCALE
	world.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(world)

	var white_background := ColorRect.new()
	white_background.position = Vector2.ZERO
	white_background.size = REFERENCE_SIZE
	white_background.color = Color("b9bec5")
	white_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	white_background.z_index = -10
	world.add_child(white_background)
	var mountain_layer := _add_map_texture(world, MAP_LAYER_ROOT + "shan.png", Rect2(Vector2.ZERO, REFERENCE_SIZE), 0)
	mountain_layer.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	map_viewport = Control.new()
	# Clip interactive map content to the inner mountain panel, leaving the
	# authored frame pixels and the bottom detail panel unobstructed.
	map_viewport.position = MAP_VIEWPORT_POSITION
	map_viewport.size = MAP_VIEWPORT_SIZE
	map_viewport.clip_contents = true
	map_viewport.mouse_filter = Control.MOUSE_FILTER_PASS
	map_viewport.z_index = 10
	world.add_child(map_viewport)
	map_content = Control.new()
	map_content.position = _map_content_position_for_node(GameState.current_map_node)
	map_content.size = Vector2(MAP_CONTENT_WIDTH, REFERENCE_SIZE.y)
	map_content.pivot_offset = map_content.size * 0.5
	map_content.scale = Vector2.ONE
	map_content.mouse_filter = Control.MOUSE_FILTER_PASS
	map_viewport.add_child(map_content)
	_build_paths()
	# Authored frame layers stay above every map node/path so no interactive
	# element can cover the border pixels. Keep title/settings just above them.
	var outer_layer := _add_map_texture(world, MAP_LAYER_ROOT + "da_kuang.png", Rect2(Vector2.ZERO, REFERENCE_SIZE), 100)
	outer_layer.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var top_layer := _add_map_texture(world, MAP_LAYER_ROOT + "up_kuang.png", Rect2(Vector2.ZERO, REFERENCE_SIZE), 101)
	top_layer.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var bottom_layer := _add_map_texture(world, MAP_LAYER_ROOT + "xiao_kuang.png", Rect2(Vector2.ZERO, REFERENCE_SIZE), 101)
	bottom_layer.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_build_node_info_panel()
	_build_map_title()

	var settings_button := _add_map_texture_button(world, MAP_ASSETS + "设置icon.png", Rect2(1580, 42, 50, 46), 102)
	settings_button.pressed.connect(_open_map_settings)

	_build_nodes()
	_build_hero()
	status_label = Label.new()
	status_label.visible = false
	add_child(status_label)
	coin_label = Label.new()
	coin_label.visible = false
	add_child(coin_label)


func _build_paths() -> void:
	for source_id in GameState.map_edges:
		var source_position := _node_position(int(source_id))
		for target_id in GameState.map_edges[source_id]:
			_add_dashed_path(source_position, _node_position(int(target_id)))


func _add_dashed_path(start: Vector2, finish: Vector2) -> void:
	var direction := finish - start
	var length := direction.length()
	var normal := direction.normalized()
	var dash_texture := load(MAP_ASSETS + "虚线.png") as Texture2D
	var offset := 0.0
	while offset < length:
		var dash := TextureRect.new()
		dash.position = start + normal * offset
		dash.size = Vector2(minf(8.0, length - offset), 3)
		dash.pivot_offset = Vector2(0, 1.5)
		dash.rotation = direction.angle()
		dash.texture = dash_texture
		dash.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		dash.stretch_mode = TextureRect.STRETCH_SCALE
		dash.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		dash.mouse_filter = Control.MOUSE_FILTER_IGNORE
		dash.z_index = 20
		map_content.add_child(dash)
		offset += 15.0


func _build_nodes() -> void:
	var selectable := _selectable_node_ids()
	for spec in GameState.map_nodes:
		var node_id := int(spec["id"])
		var node_type := String(spec["type"])
		var center := _node_position(node_id)
		var node_size := Vector2(92, 94)
		var current_node := node_id == GameState.current_map_node
		var button := TextureButton.new()
		button.position = center - node_size * 0.5
		button.size = node_size
		button.texture_normal = load(NODE_SELECTED_FRAME_ASSET if current_node else NODE_FRAME_ASSET) as Texture2D
		button.texture_hover = load(NODE_SELECTED_FRAME_ASSET) as Texture2D
		button.texture_pressed = button.texture_hover
		button.texture_disabled = button.texture_normal
		button.ignore_texture_size = true
		button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		button.focus_mode = Control.FOCUS_NONE
		button.z_index = 40
		button.disabled = input_locked
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if node_id in selectable else Control.CURSOR_ARROW
		button.pressed.connect(_on_node_pressed.bind(node_id))
		button.mouse_entered.connect(_on_node_hovered.bind(node_id))
		button.mouse_exited.connect(_on_node_unhovered.bind(node_id))
		map_content.add_child(button)
		node_buttons[node_id] = button

		if node_type in NODE_ICON_ASSETS:
			var icon := TextureRect.new()
			icon.position = center - Vector2(27, 27)
			icon.size = Vector2(54, 54)
			icon.texture = load(String(NODE_ICON_ASSETS[node_type])) as Texture2D
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
			icon.z_index = 41
			map_content.add_child(icon)

		var state_overlay := TextureRect.new()
		state_overlay.position = center - node_size * 0.5
		state_overlay.size = node_size
		state_overlay.texture = load(NODE_VISITED_MASK_ASSET) as Texture2D
		state_overlay.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		state_overlay.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		state_overlay.modulate = Color(1, 1, 1, 0.58)
		state_overlay.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		state_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		state_overlay.z_index = 42
		map_content.add_child(state_overlay)
		node_state_overlays[node_id] = state_overlay
		_refresh_single_node(node_id)
	_update_node_info(GameState.current_map_node)


func _build_hero() -> void:
	# The current node's orange frame is now the position marker. Keep an
	# invisible control for the travel tween so movement logic stays intact.
	hero = Control.new()
	hero.size = Vector2(1, 1)
	hero.position = _node_position(GameState.current_map_node) - hero.size * 0.5
	hero.visible = false
	hero.z_index = 39
	hero.mouse_filter = Control.MOUSE_FILTER_IGNORE
	map_content.add_child(hero)


func _add_map_texture(parent: Control, path: String, rect: Rect2, layer: int) -> TextureRect:
	var texture_rect := TextureRect.new()
	texture_rect.position = rect.position
	texture_rect.size = rect.size
	texture_rect.texture = load(path) as Texture2D
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP
	texture_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_rect.z_index = layer
	parent.add_child(texture_rect)
	return texture_rect


func _add_map_texture_button(parent: Control, path: String, rect: Rect2, layer: int) -> TextureButton:
	var button := TextureButton.new()
	var texture := load(path) as Texture2D
	button.position = rect.position
	button.size = rect.size
	button.texture_normal = texture
	button.texture_hover = texture
	button.texture_pressed = texture
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	button.focus_mode = Control.FOCUS_NONE
	button.z_index = layer
	parent.add_child(button)
	return button


func _build_node_info_panel() -> void:
	var legend := Control.new()
	legend.position = Vector2(72, 774)
	legend.size = Vector2(1518, 82)
	legend.mouse_filter = Control.MOUSE_FILTER_IGNORE
	legend.z_index = 102
	world.add_child(legend)
	var entries := [
		{"label": "普通战斗", "icon": MAP_ASSETS + "战斗icon.png"},
		{"label": "精英战斗", "icon": MAP_ASSETS + "精英icon.png"},
		{"label": "宝箱", "icon": MAP_ASSETS + "奖励icon.png"},
		{"label": "商店", "icon": MAP_ASSETS + "休息icon.png"},
		{"label": "事件", "icon": MAP_ASSETS + "事件icon.png"},
		{"label": "休息营地", "icon": MAP_ASSETS + "休息节点icon.png"},
	]
	var entry_width := 253.0
	for index in entries.size():
		_add_legend_entry(legend, entries[index], Vector2(index * entry_width, 8), entry_width)
		if index < entries.size() - 1:
			var separator := ColorRect.new()
			separator.position = Vector2((index + 1) * entry_width - 2, 15)
			separator.size = Vector2(3, 52)
			separator.color = Color("68717a")
			separator.mouse_filter = Control.MOUSE_FILTER_IGNORE
			legend.add_child(separator)


func _add_legend_entry(parent: Control, entry: Dictionary, position: Vector2, width: float) -> void:
	var item := Control.new()
	item.position = position
	item.size = Vector2(width, 66)
	item.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(item)
	var frame := TextureRect.new()
	frame.position = Vector2(5, 3)
	frame.size = Vector2(58, 59)
	frame.texture = load(NODE_FRAME_ASSET) as Texture2D
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	frame.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	item.add_child(frame)
	var icon := TextureRect.new()
	icon.position = Vector2(17, 14)
	icon.size = Vector2(34, 34)
	icon.texture = load(String(entry["icon"])) as Texture2D
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	item.add_child(icon)
	var label := Label.new()
	label.position = Vector2(70, 5)
	label.size = Vector2(width - 78, 56)
	label.text = String(entry["label"])
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", source_han_font)
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color("303942"))
	label.add_theme_color_override("font_outline_color", Color("eef1f3"))
	label.add_theme_constant_override("outline_size", 1)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	item.add_child(label)


func _update_node_info(node_id: int) -> void:
	if node_info_detail == null or node_id < 0 or node_id >= GameState.map_nodes.size():
		return
	var node_type := String(GameState.map_nodes[node_id].get("type", ""))
	node_info_detail.text = _node_description(node_type, node_id)
	node_info_hint.text = "点击节点开始" if node_id in _selectable_node_ids() and not input_locked else ""


func _build_map_title() -> void:
	var title := Label.new()
	title.position = Vector2(48, 39)
	title.size = Vector2(280, 54)
	title.text = "区域 %d · 第 %d 层" % [GameState.region, GameState.floor]
	title.add_theme_font_override("font", source_han_font)
	title.add_theme_font_size_override("font_size", 33)
	title.add_theme_color_override("font_color", Color.WHITE)
	title.add_theme_color_override("font_outline_color", Color("27313a"))
	title.add_theme_constant_override("outline_size", 2)
	title.z_index = 102
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	world.add_child(title)


func _node_description(node_type: String, node_id := -1) -> String:
	match node_type:
		"start": return "整备队伍并开始本次探索"
		"battle": return "与野生宝可梦战斗，获得奖励"
		"elite": return "挑战精英敌人，奖励更加丰厚"
		"shop": return "购买道具并调整队伍状态"
		"event": return "触发随机事件并作出选择"
		"chest": return "挑战宝箱怪，击败后获得宝箱奖励" if node_id >= 0 and bool(GameState.map_nodes[node_id].get("mimic", false)) else "打开宝箱，获得随机资源"
		"rest": return "恢复状态，为下一段路程做准备"
		"boss": return "最终首领战，完成本区域"
		_: return "选择一个地图节点"


func _open_map_settings() -> void:
	if not is_instance_valid(settings_overlay):
		settings_overlay = preload("res://settings_overlay.tscn").instantiate() as Control
		settings_overlay.set("exit_scene_path", "res://main.tscn")
		add_child(settings_overlay)
	else:
		settings_overlay.move_to_front()


func _position_map_on_entry() -> void:
	await get_tree().process_frame
	var play_intro := input_locked
	var target_position := _map_content_position_for_node(GameState.current_map_node)
	if play_intro:
		# Start on the authored Boss-room side, then pan to the current node.
		# This restores the original map entrance while preserving the longer route.
		var boss_position := _map_content_position_for_node(22)
		map_content.position = boss_position
		await get_tree().create_timer(1.0).timeout
		var camera_tween := create_tween()
		camera_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
		camera_tween.tween_property(map_content, "position", target_position, 1.6)
		await camera_tween.finished
	else:
		map_content.position = target_position
	GameState.map_intro_played = true
	GameState.save_run()
	input_locked = false
	_refresh_node_interaction()
	_update_node_info(GameState.current_map_node)
	if not GameState.tutorial_completed:
		_show_tutorial()
	if GameState.current_map_node == GameState.map_nodes.size() - 1 and GameState.is_map_node_completed(GameState.current_map_node):
		_show_run_complete()


func _show_tutorial() -> void:
	if is_instance_valid(tutorial_overlay):
		return
	input_locked = true
	_refresh_node_interaction()
	tutorial_step = 0
	tutorial_overlay = Control.new()
	tutorial_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tutorial_overlay.z_index = 260
	tutorial_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(tutorial_overlay)
	tutorial_shade_layer = Control.new()
	tutorial_shade_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tutorial_shade_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tutorial_overlay.add_child(tutorial_shade_layer)
	var professor_frame := Panel.new()
	professor_frame.position = Vector2(26, 350)
	professor_frame.size = Vector2(250, 350)
	professor_frame.clip_contents = true
	professor_frame.add_theme_stylebox_override("panel", _panel_style(Color("f6f3ea"), Color("48515d"), 4))
	tutorial_overlay.add_child(professor_frame)
	var professor := TextureRect.new()
	professor.position = Vector2(-30, -10)
	professor.size = Vector2(310, 500)
	professor.texture = load("res://assets/tutorial/professor.png") as Texture2D
	professor.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	professor.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	professor.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	professor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	professor_frame.add_child(professor)
	var dialogue_panel := Panel.new()
	dialogue_panel.position = Vector2(250, 500)
	dialogue_panel.size = Vector2(1000, 185)
	dialogue_panel.add_theme_stylebox_override("panel", _panel_style(Color("f7f7f3"), Color("4e5662"), 5))
	tutorial_overlay.add_child(dialogue_panel)
	tutorial_dialogue = Label.new()
	tutorial_dialogue.position = Vector2(35, 24)
	tutorial_dialogue.size = Vector2(930, 105)
	tutorial_dialogue.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tutorial_dialogue.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tutorial_dialogue.add_theme_font_override("font", source_han_font)
	tutorial_dialogue.add_theme_font_size_override("font_size", 21)
	tutorial_dialogue.add_theme_color_override("font_color", Color("282d35"))
	tutorial_dialogue.add_theme_color_override("font_shadow_color", Color("c9cbd0"))
	tutorial_dialogue.add_theme_constant_override("shadow_offset_x", 1)
	tutorial_dialogue.add_theme_constant_override("shadow_offset_y", 1)
	dialogue_panel.add_child(tutorial_dialogue)
	var uses_gamepad := not Input.get_connected_joypads().is_empty()
	var hint_icons := [
		"res://assets/ui/input/gamepad_dpad.png",
		"res://assets/ui/input/gamepad_confirm.png",
		"res://assets/ui/input/gamepad_cancel.png",
	] if uses_gamepad else ["res://assets/ui/input/key_escape.png"]
	for icon_index in hint_icons.size():
		var hint_icon := TextureRect.new()
		hint_icon.position = Vector2(38 + icon_index * 28, 143)
		hint_icon.size = Vector2(22, 22)
		hint_icon.texture = load(String(hint_icons[icon_index])) as Texture2D
		hint_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		hint_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		hint_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		hint_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		dialogue_panel.add_child(hint_icon)
	var hint_text := Label.new()
	hint_text.position = Vector2(42 + hint_icons.size() * 28, 139)
	hint_text.size = Vector2(410, 30)
	hint_text.text = "移动 / 确认 / 返回" if uses_gamepad else "打开设置或返回"
	hint_text.add_theme_font_override("font", source_han_font)
	hint_text.add_theme_font_size_override("font_size", 14)
	hint_text.add_theme_color_override("font_color", Color("555b65"))
	dialogue_panel.add_child(hint_text)
	var next_button := Button.new()
	next_button.position = Vector2(770, 133)
	next_button.size = Vector2(190, 42)
	next_button.text = "下一步"
	next_button.add_theme_font_override("font", source_han_font)
	next_button.add_theme_font_size_override("font_size", 18)
	next_button.add_theme_color_override("font_color", Color.WHITE)
	next_button.add_theme_color_override("font_outline_color", Color.BLACK)
	next_button.add_theme_constant_override("outline_size", 1)
	next_button.add_theme_stylebox_override("normal", _panel_style(Color("ef466f"), Color("3b3f48"), 3))
	next_button.add_theme_stylebox_override("hover", _panel_style(Color("f35b7f"), Color.WHITE, 3))
	next_button.pressed.connect(_advance_tutorial.bind(next_button))
	dialogue_panel.add_child(next_button)
	_render_tutorial_step(next_button)


func _render_tutorial_step(next_button: Button) -> void:
	var data := TUTORIAL_STEPS[tutorial_step]
	tutorial_dialogue.text = String(data["text"])
	next_button.text = "开始远征" if tutorial_step == TUTORIAL_STEPS.size() - 1 else "下一步"
	for child in tutorial_shade_layer.get_children():
		child.queue_free()
	var focus: Rect2 = data["focus"]
	var shade_color := Color(0.01, 0.015, 0.025, 0.78)
	var shade_rects := [
		Rect2(0, 0, DESIGN_SIZE.x, focus.position.y),
		Rect2(0, focus.end.y, DESIGN_SIZE.x, DESIGN_SIZE.y - focus.end.y),
		Rect2(0, focus.position.y, focus.position.x, focus.size.y),
		Rect2(focus.end.x, focus.position.y, DESIGN_SIZE.x - focus.end.x, focus.size.y),
	]
	for rect in shade_rects:
		if rect.size.x <= 0 or rect.size.y <= 0:
			continue
		var shade := ColorRect.new()
		shade.position = rect.position
		shade.size = rect.size
		shade.color = shade_color
		shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tutorial_shade_layer.add_child(shade)
	var border := Panel.new()
	border.position = focus.position
	border.size = focus.size
	border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	border.add_theme_stylebox_override("panel", _panel_style(Color(0, 0, 0, 0), Color("ffd44a"), 3))
	tutorial_shade_layer.add_child(border)


func _advance_tutorial(next_button: Button) -> void:
	if tutorial_step < TUTORIAL_STEPS.size() - 1:
		tutorial_step += 1
		_render_tutorial_step(next_button)
		return
	GameState.tutorial_completed = true
	GameState.save_run()
	var fade := create_tween()
	fade.tween_property(tutorial_overlay, "modulate:a", 0.0, 0.35)
	await fade.finished
	tutorial_overlay.queue_free()
	input_locked = false
	_refresh_node_interaction()


func _selectable_node_ids() -> Array[int]:
	if not GameState.is_map_node_completed(GameState.current_map_node):
		return [GameState.current_map_node]
	var result: Array[int] = []
	for value in GameState.map_edges.get(GameState.current_map_node, []):
		result.append(int(value))
	return result


func _refresh_node_interaction() -> void:
	var selectable := _selectable_node_ids()
	for node_id in node_buttons:
		var button: TextureButton = node_buttons[node_id]
		button.disabled = input_locked
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if int(node_id) in selectable and not input_locked else Control.CURSOR_ARROW
		_refresh_single_node(int(node_id))


func _refresh_single_node(node_id: int) -> void:
	var button := node_buttons.get(node_id) as TextureButton
	if button == null:
		return
	var current_node := node_id == GameState.current_map_node
	button.texture_normal = load(NODE_SELECTED_FRAME_ASSET if current_node else NODE_FRAME_ASSET) as Texture2D
	button.texture_hover = load(NODE_SELECTED_FRAME_ASSET) as Texture2D
	button.texture_pressed = button.texture_hover
	button.texture_disabled = button.texture_normal
	button.modulate = Color.WHITE
	var overlay := node_state_overlays.get(node_id) as TextureRect
	if overlay != null:
		var completed := GameState.is_map_node_completed(node_id)
		overlay.visible = completed
		overlay.modulate = Color(1, 1, 1, 0.58)


func _on_node_hovered(node_id: int) -> void:
	var button := node_buttons.get(node_id) as TextureButton
	if button != null and not button.disabled:
		button.modulate = Color.WHITE
	_update_node_info(node_id)


func _on_node_unhovered(node_id: int) -> void:
	_refresh_single_node(node_id)
	_update_node_info(GameState.current_map_node)


func _on_node_pressed(node_id: int) -> void:
	if input_locked or map_drag_suppress_click or node_id not in _selectable_node_ids():
		return
	input_locked = true
	for button in node_buttons.values():
		(button as TextureButton).disabled = true
	GameState.set_current_map_node(node_id)
	status_label.text = "正在前往%s节点" % NODE_LABELS[GameState.current_map_node_type()]
	var travel := create_tween().set_parallel(true)
	travel.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	travel.tween_property(hero, "position", _node_position(node_id) - hero.size * 0.5, 0.7)
	await travel.finished
	_dispatch_current_node()


func _dispatch_current_node() -> void:
	match GameState.current_map_node_type():
		"chest":
			if bool(GameState.current_map_node_data().get("mimic", false)):
				get_tree().change_scene_to_file("res://battle_prep.tscn")
			else:
				chest_event = true
				_show_event_popup()
		"event":
			_show_event_popup()
		"rest":
			rest_event = true
			_show_event_popup()
		"shop", "battle", "elite", "boss":
			get_tree().change_scene_to_file("res://battle_prep.tscn")
		_:
			GameState.complete_current_map_node()
			get_tree().reload_current_scene()


func _show_event_popup(story_override := -1) -> void:
	_prepare_event_rewards()
	if story_override >= 0 and not chest_event and not rest_event:
		event_story_id = clampi(story_override, 0, EVENT_STORY_ILLUSTRATIONS.size() - 1)
	event_overlay = Control.new()
	event_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	event_overlay.z_index = 120
	add_child(event_overlay)
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.018, 0.022, 0.028, 0.98)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	event_overlay.add_child(shade)

	var illustration := Control.new()
	illustration.position = Vector2(394, 42)
	illustration.size = Vector2(492, 312)
	illustration.clip_contents = true
	event_overlay.add_child(illustration)
	_add_event_texture(illustration, EVENT_ILLUSTRATION_FRAME, Rect2(Vector2.ZERO, illustration.size))
	var illustration_content := Control.new()
	illustration_content.position = Vector2(14, 14)
	illustration_content.size = Vector2(464, 284)
	illustration_content.clip_contents = true
	illustration.add_child(illustration_content)
	if chest_event:
		var chest_backdrop := ColorRect.new()
		chest_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		chest_backdrop.color = Color("11131a")
		illustration_content.add_child(chest_backdrop)
		_play_chest_open_animation(illustration_content)
	else:
		_add_event_texture(
			illustration_content,
			_event_illustration_path(),
			Rect2(Vector2.ZERO, illustration_content.size),
			TextureRect.STRETCH_KEEP_ASPECT_COVERED,
		)
		if event_story_id < 6:
			var story_creature := _add_event_texture(illustration_content, event_creature_path, Rect2(188, 68, 89, 106))
			story_creature.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	event_option_area = Control.new()
	event_option_area.position = Vector2(394, 368)
	event_option_area.size = Vector2(492, 155)
	event_overlay.add_child(event_option_area)

	var text_box := _add_event_texture(event_overlay, EVENT_TEXT_BOX, Rect2(220, 536, 840, 180))
	text_box.z_index = 4
	event_description = RichTextLabel.new()
	event_description.position = Vector2(245, 558)
	event_description.size = Vector2(790, 132)
	event_description.bbcode_enabled = true
	event_description.fit_content = false
	event_description.scroll_active = false
	event_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	event_description.add_theme_font_override("normal_font", source_han_font)
	event_description.add_theme_font_size_override("normal_font_size", 20)
	event_description.add_theme_color_override("default_color", Color("313440"))
	event_description.add_theme_color_override("font_shadow_color", Color("d7d8df"))
	event_description.add_theme_constant_override("shadow_offset_x", 1)
	event_description.add_theme_constant_override("shadow_offset_y", 1)
	event_description.mouse_filter = Control.MOUSE_FILTER_IGNORE
	event_description.z_index = 5
	event_overlay.add_child(event_description)

	event_stage_id = "root"
	_render_event_stage()


func _prepare_event_rewards() -> void:
	rng.seed = GameState.map_seed + GameState.current_map_node * 997 + 41
	event_story_id = rng.randi_range(0, EVENT_STORY_ILLUSTRATIONS.size() - 1)
	var creature_index := rng.randi_range(0, EVENT_CREATURES.size() - 1)
	event_creature_path = EVENT_CREATURES[creature_index]
	event_creature_name = EVENT_CREATURE_NAMES[creature_index]
	var reward_source := "chest" if chest_event else "event"
	event_consumable = ITEM_CATALOG.random_entry("item", rng, -1, reward_source)
	event_loot = ITEM_CATALOG.random_entry("accessory" if rng.randf() < 0.5 else "item", rng, -1, reward_source)
	chest_choices.clear()
	var used_choices: Dictionary = {}
	while chest_choices.size() < 3:
		var kind := "accessory" if rng.randf() < 0.45 else "item"
		var choice := ITEM_CATALOG.random_entry(kind, rng, -1, "chest")
		var key := "%s:%d" % [choice.get("kind", kind), int(choice.get("id", -1))]
		if not used_choices.has(key):
			used_choices[key] = true
			chest_choices.append(choice)
	var chest_range := GameState.chest_gold_range()
	chest_coin_amount = rng.randi_range(chest_range.x, chest_range.y)


func _event_illustration_path() -> String:
	if chest_event:
		return EVENT_CHEST_ILLUSTRATION
	if rest_event:
		return EVENT_STORY_ILLUSTRATIONS[0]
	return EVENT_STORY_ILLUSTRATIONS[clampi(event_story_id, 0, EVENT_STORY_ILLUSTRATIONS.size() - 1)]


func _event_title() -> String:
	if rest_event:
		return "旅途营地"
	if chest_event:
		return "遗失的宝箱"
	return EVENT_STORY_TITLES[clampi(event_story_id, 0, EVENT_STORY_TITLES.size() - 1)]


func _loot_option(text: String, entry: Dictionary) -> Dictionary:
	var type_name := "饰品" if entry["kind"] == "accessory" else "道具"
	return {
		"text": text,
		"tag": "（%s：%s）" % [type_name, String(entry["name"])],
		"kind": entry["kind"],
		"entry": entry,
		"detail": entry["effect"],
	}


func _event_stage_data() -> Dictionary:
	var gold_small := GameState.scaled_event_gold(GameState.EVENT_GOLD_SMALL)
	var gold_medium := GameState.scaled_event_gold(GameState.EVENT_GOLD_MEDIUM)
	var gold_large := GameState.scaled_event_gold(GameState.EVENT_GOLD_LARGE)
	if event_stage_id == "result":
		return {
			"story": event_result_text,
			"options": [{"text": "收好所得，继续远征", "tag": "", "kind": event_result_kind, "action": "finish", "detail": "本次事件已经结束。\n奖励已经加入本次远征。"}],
		}
	if rest_event:
		return {
			"story": "队伍找到了一处安全营地。篝火还留有余温，训练场和补给箱都可以使用，但天亮前只够完成一件事。",
			"options": [
				{"text": "围着篝火充分休息", "tag": "（恢复：远征生命 +1）", "kind": "recovery", "amount": 1, "detail": "恢复 1 点远征生命；生命已满时改为获得 3 金币。"},
				{"text": "支付场地费进行训练", "tag": "（金币 -3，全队伤害 +5%）", "kind": "attribute", "attribute": "damage", "amount": 0.05, "cost": 3, "detail": "支付 3 金币，本轮远征全队伤害永久提高 5%。"},
				_loot_option("整理营地留下的补给", event_consumable),
			],
		}
	if chest_event:
		var chest_options: Array[Dictionary] = []
		for choice in chest_choices:
			chest_options.append(_loot_option("选择", choice))
		return {
			"story": "宝箱已经开启。三件奖励只能带走一件，请选择最适合本次构筑的道具。",
			"options": chest_options,
		}
	match event_story_id:
		0:
			match event_stage_id:
				"sanctum":
					return {"story": "石门后是一座仍在呼吸般闪烁的祭坛。两枚符文只能唤醒其中一枚。", "options": [
						{"text": "按下翠绿生命符文", "tag": "（属性：全队最大生命 +12%）", "kind": "attribute", "attribute": "health", "amount": 0.12, "detail": "生命符文会强化本次远征中所有己方单位的最大生命。"},
						{"text": "按下猩红力量符文", "tag": "（属性：全队伤害 +9%）", "kind": "attribute", "attribute": "damage", "amount": 0.09, "detail": "力量符文会永久提高本次远征中所有己方单位的技能伤害。"},
					]}
				"camp":
					return {"story": "脚印通向一处废弃营地。火堆早已熄灭，箱子里却传来轻微碰撞声。", "options": [
						_loot_option("打开旅行者留下的箱子", event_loot),
						{"text": "整理散落的钱袋", "tag": "（金币：+%d）" % gold_small, "kind": "coins", "amount": gold_small, "detail": "获得 %d 枚金币。" % gold_small},
					]}
				"nest":
					return {"story": "低语来自破碎石柱后的巢穴。一只迷失的生物正被古代锁链困住。", "options": [
						{"text": "破坏锁链并带它离开", "tag": "（角色卡：%s）" % event_creature_name, "kind": "creature", "detail": "获得角色卡；队伍已满时按该角色售价转化为金币。"},
						{"text": "吸收锁链残留的能量", "tag": "（属性：全队充能速度 +8%）", "kind": "attribute", "attribute": "charge", "amount": 0.08, "detail": "提高本次远征中全队的技能充能速度。"},
					]}
				_:
					return {"story": "月光从坍塌的穹顶落下，照亮三条通往遗迹深处的道路。空气里残留着温暖而危险的魔力。", "options": [
						{"text": "推开刻满藤蔓纹路的石门", "tag": "", "kind": "story", "next": "sanctum", "detail": "石门后传来规律的能量脉动。继续调查会进入故事的下一层。"},
						{"text": "追随地面上的新鲜脚印", "tag": "", "kind": "story", "next": "camp", "detail": "脚印不像怪物留下的，也许有其他旅行者来过这里。"},
						{"text": "寻找石柱后方的低语声", "tag": "", "kind": "story", "next": "nest", "detail": "微弱的呼救声被风声掩盖，似乎有什么被困在深处。"},
					]}
		1:
			match event_stage_id:
				"generator":
					return {"story": "你清理掉缠绕发电机的藤蔓。残存的雷光汇成两条不同频率的回路。", "options": [
						{"text": "接通高速回路", "tag": "（属性：全队充能速度 +10%）", "kind": "attribute", "attribute": "charge", "amount": 0.10, "detail": "提高本次远征中全队的技能充能速度。"},
						_loot_option("拆下稳定器", event_loot),
					]}
				"archive":
					return {"story": "值班室的日志记录了最后一场暴雨。柜台下还压着驿站管理员未发出的补给。", "options": [
						_loot_option("取走密封补给", event_loot),
						{"text": "回收旧时代货币", "tag": "（金币：+%d）" % gold_medium, "kind": "coins", "amount": gold_medium, "detail": "获得 %d 枚金币。" % gold_medium},
					]}
				"signal":
					return {"story": "信号并非求救，而是一只躲雨生物发出的回应。它谨慎地注视着你。", "options": [
						{"text": "分享食物并邀请同行", "tag": "（角色卡：%s）" % event_creature_name, "kind": "creature", "detail": "获得角色卡；队伍已满时按该角色售价转化为金币。"},
						{"text": "让它为队伍指路", "tag": "（属性：全队最大生命 +10%）", "kind": "attribute", "attribute": "health", "amount": 0.10, "detail": "安全路线使全队在之后的战斗中拥有更多最大生命。"},
					]}
				_:
					return {"story": "暴雨迫使你进入一座废弃驿站。屋顶不停漏水，远处发电机偶尔闪出蓝光，地下还有断续信号。", "options": [
						{"text": "修复院子里的旧发电机", "tag": "", "kind": "story", "next": "generator", "detail": "发电机仍有少量能源，修复后也许可以重新分配。"},
						{"text": "搜索积满灰尘的值班室", "tag": "", "kind": "story", "next": "archive", "detail": "值班室里散落着日志和没有送出的包裹。"},
						{"text": "回应地下室传来的信号", "tag": "", "kind": "story", "next": "signal", "detail": "信号很微弱，但每隔数秒都会准确重复。"},
					]}
		2:
			match event_stage_id:
				"pool":
					return {"story": "池水倒映出并不存在的星空。触碰水面时，你感受到两种不同的祝福。", "options": [
						{"text": "接受繁茂祝福", "tag": "（属性：全队最大生命 +14%）", "kind": "attribute", "attribute": "health", "amount": 0.14, "detail": "提高本次远征中全队的最大生命。"},
						{"text": "接受星火祝福", "tag": "（属性：全队伤害 +10%）", "kind": "attribute", "attribute": "damage", "amount": 0.10, "detail": "提高本次远征中全队的技能伤害。"},
					]}
				"greenhouse":
					return {"story": "温室中央生长着一株透明植物，根系包裹着一枚保存完好的容器。", "options": [
						_loot_option("摘下根系中的容器", event_loot),
						{"text": "采集成熟的能量果实", "tag": "（金币：+%d）" % gold_large, "kind": "coins", "amount": gold_large, "detail": "出售能量果实，获得 %d 枚金币。" % gold_large},
					]}
				"cradle":
					return {"story": "哭声来自被花藤覆盖的摇篮。里面的生物睁开眼睛，主动把爪子伸向你。", "options": [
						{"text": "抱起它并一起旅行", "tag": "（角色卡：%s）" % event_creature_name, "kind": "creature", "detail": "获得角色卡；队伍已满时按该角色售价转化为金币。"},
						{"text": "修复摇篮的供能装置", "tag": "（属性：全队充能速度 +9%）", "kind": "attribute", "attribute": "charge", "amount": 0.09, "detail": "带走装置中的技术，提高全队技能充能速度。"},
					]}
				_:
					return {"story": "被月色笼罩的庭院中，植物仍按古老程序生长。水池、温室与摇篮室分别传来不同的声响。", "options": [
						{"text": "靠近映着星空的水池", "tag": "", "kind": "story", "next": "pool", "detail": "水面没有波纹，却能听见类似心跳的回响。"},
						{"text": "进入仍亮着灯的温室", "tag": "", "kind": "story", "next": "greenhouse", "detail": "玻璃之后有一株从未见过的透明植物。"},
						{"text": "寻找摇篮室里的哭声", "tag": "", "kind": "story", "next": "cradle", "detail": "哭声很轻，而且在听见你的脚步后突然停止。"},
					]}
		3:
			match event_stage_id:
				"stalls":
					return {"story": "摊主掀开防雨布，几件来自远方的货物泛着微光。他愿意按旅人价格出售其中一件。", "options": [
						{"text": "购买摊主推荐的物品", "tag": "（金币 -2，%s：%s）" % ["饰品" if event_loot["kind"] == "accessory" else "道具", event_loot["name"]], "kind": event_loot["kind"], "entry": event_loot, "cost": 2, "detail": event_loot["effect"]},
						{"text": "帮忙整理货箱换取报酬", "tag": "（金币：+%d）" % gold_small, "kind": "coins", "amount": gold_small, "detail": "帮商队完成工作并获得金币。"},
					]}
				"lost_partner":
					return {"story": "商队正在寻找一只走失的驮兽。你在灯笼照不到的小巷里发现了它留下的脚印。", "options": [
						{"text": "沿脚印找回走失伙伴", "tag": "（角色卡：%s）" % event_creature_name, "kind": "creature", "detail": "获得角色卡；共享卡池售罄或队伍已满时转化为金币。"},
						{"text": "标记路线后返回领取补给", "tag": "（道具：%s）" % event_consumable["name"], "kind": "item", "entry": event_consumable, "detail": event_consumable["effect"]},
					]}
				_:
					return {"story": "夜色中，一支挂满灯笼的流动商队停在岔路口。摊主们交换物资，也在寻找走失的伙伴。", "options": [
						{"text": "浏览临时摊位", "tag": "", "kind": "story", "next": "stalls", "detail": "查看商队从其他区域带来的货物。"},
						{"text": "帮助商队寻找走失伙伴", "tag": "", "kind": "story", "next": "lost_partner", "detail": "协助商队可能获得角色卡或补给。"},
						{"text": "向领队询问安全路线", "tag": "（属性：全队最大生命 +6%）", "kind": "attribute", "attribute": "health", "amount": 0.06, "detail": "商队提供的路线情报提高本轮远征的生存能力。"},
					]}
		4:
			match event_stage_id:
				"rescue":
					return {"story": "呼救声来自被雪覆盖的岩缝。一只冻僵的生物正努力保护身旁的补给袋。", "options": [
						{"text": "救出它并邀请同行", "tag": "（角色卡：%s）" % event_creature_name, "kind": "creature", "detail": "获得角色卡；共享卡池售罄或队伍已满时转化为金币。"},
						{"text": "留下食物并带走补给袋", "tag": "（道具：%s）" % event_consumable["name"], "kind": "item", "entry": event_consumable, "detail": event_consumable["effect"]},
					]}
				"shelter":
					return {"story": "避风岩洞里有一堆尚未熄灭的炭火。墙上刻着前一支队伍留下的训练记录。", "options": [
						{"text": "休息并恢复远征生命", "tag": "（恢复：远征生命 +1）", "kind": "recovery", "amount": 1, "detail": "恢复 1 点生命，生命已满则获得 3 金币。"},
						{"text": "研读训练记录", "tag": "（属性：全队伤害 +6%）", "kind": "attribute", "attribute": "damage", "amount": 0.06, "detail": "本轮远征全队伤害永久提高。"},
					]}
				_:
					return {"story": "暴雪遮住了道路。远处既有断续的呼救声，也能看见一处避风岩洞和闪烁的旧信标。", "options": [
						{"text": "寻找暴雪中的呼救声", "tag": "", "kind": "story", "next": "rescue", "detail": "声音很微弱，继续搜索可能消耗更多时间。"},
						{"text": "先进入避风岩洞", "tag": "", "kind": "story", "next": "shelter", "detail": "岩洞可以恢复状态，也保留着训练记录。"},
						{"text": "拆下旧信标的充能核心", "tag": "（属性：全队充能速度 +7%）", "kind": "attribute", "attribute": "charge", "amount": 0.07, "detail": "将信标核心用于强化队伍充能。"},
					]}
		5:
			match event_stage_id:
				"fossil":
					return {"story": "岩层中露出一块完整化石，旁边还有新鲜抓痕。沉睡的生物似乎仍在附近守护它。", "options": [
						{"text": "修复化石并等待守护者", "tag": "（角色卡：%s）" % event_creature_name, "kind": "creature", "detail": "获得角色卡；共享卡池售罄或队伍已满时转化为金币。"},
						{"text": "带走化石出售", "tag": "（金币：+%d）" % gold_large, "kind": "coins", "amount": gold_large, "detail": "将完整化石换成金币。"},
					]}
				"crystal":
					return {"story": "洞穴深处的晶簇会回应队伍的呼吸。敲下晶体会破坏共鸣，但能带走其中的力量。", "options": [
						_loot_option("小心取下稳定晶体", event_loot),
						{"text": "让队伍吸收晶簇共鸣", "tag": "（属性：全队最大生命 +8%）", "kind": "attribute", "attribute": "health", "amount": 0.08, "detail": "本轮远征全队最大生命永久提高。"},
					]}
				_:
					return {"story": "洞口吹出带着矿石气味的暖风。深处传来规律回声，墙壁上同时露出化石与发光晶脉。", "options": [
						{"text": "沿抓痕寻找完整化石", "tag": "", "kind": "story", "next": "fossil", "detail": "完整化石附近可能有守护它的生物。"},
						{"text": "深入调查发光晶脉", "tag": "", "kind": "story", "next": "crystal", "detail": "晶脉可能提供饰品或永久属性。"},
						{"text": "收集入口处的碎矿", "tag": "（金币：+%d）" % gold_medium, "kind": "coins", "amount": gold_medium, "detail": "出售容易取得的碎矿，安全获得金币。"},
					]}
		6:
			return {"story": "林间空地的古老石台上悬浮着一枚金色晶石。它会回应靠近者的心跳，光芒也随着队伍的脚步逐渐增强。", "options": [
				{"text": "触碰晶石并记录它的脉动", "tag": "（属性：全队充能速度 +10%）", "kind": "attribute", "attribute": "charge", "amount": 0.10, "detail": "晶石的节律强化本轮远征中全队的技能充能速度。"},
				_loot_option("取下石台边缘脱落的晶片", event_loot),
				{"text": "将石台位置卖给遗迹商人", "tag": "（金币：+%d）" % gold_medium, "kind": "coins", "amount": gold_medium, "detail": "记录遗迹坐标并换取金币，不惊动晶石本体。"},
			]}
		7:
			return {"story": "晶石突然迸发出耀眼金光！短暂的惊讶之后，你发现光芒正在凝聚成一份只属于勇敢探索者的馈赠。", "options": [
				{"text": "抓住飞散的金币", "tag": "（金币：+%d）" % gold_large, "kind": "coins", "amount": gold_large, "detail": "在光芒消失前收集一大把金币。"},
				{"text": "邀请被光芒吸引来的伙伴", "tag": "（角色卡：%s）" % event_creature_name, "kind": "creature", "detail": "获得角色卡；共享卡池售罄或队伍已满时转化为金币。"},
				{"text": "把闪光吸收进队伍徽记", "tag": "（属性：全队伤害 +8%）", "kind": "attribute", "attribute": "damage", "amount": 0.08, "detail": "本轮远征全队伤害永久提高 8%。"},
			]}
		_:
			return {"story": "前方出现了一道尚未记录的遗迹光芒。", "options": [
				{"text": "谨慎调查", "tag": "（金币：+%d）" % gold_small, "kind": "coins", "amount": gold_small, "detail": "完成调查并获得少量金币。"},
				_loot_option("带走遗迹中的补给", event_consumable),
				{"text": "记录路线经验", "tag": "（属性：全队最大生命 +5%）", "kind": "attribute", "attribute": "health", "amount": 0.05, "detail": "本轮远征全队最大生命永久提高。"},
			]}


func _render_event_stage() -> void:
	if event_corner_tween and event_corner_tween.is_valid():
		event_corner_tween.kill()
	for child in event_option_area.get_children():
		child.queue_free()
	event_corner_groups.clear()
	var stage := _event_stage_data()
	event_description.text = String(stage["story"])
	var options: Array = stage["options"]
	if chest_event and event_stage_id == "root":
		_render_chest_choice_cards(options)
		return
	for index in options.size():
		var option: Dictionary = options[index]
		var row := Control.new()
		row.position = Vector2(0, index * 54.0)
		row.size = Vector2(492, 46)
		event_option_area.add_child(row)
		_add_event_texture(row, EVENT_OPTION_FRAME, Rect2(Vector2.ZERO, row.size))
		var text_label := _event_rich_label(row, Rect2(16, 10, 460, 30), 15)
		var kind := String(option.get("kind", "story"))
		var tag := String(option.get("tag", ""))
		var color: Color = REWARD_COLORS.get(kind, REWARD_COLORS["story"])
		text_label.text = "[color=#30333d]%s[/color] [color=#%s]%s[/color]" % [option["text"], color.to_html(false), tag]
		var hit := Button.new()
		hit.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		hit.flat = true
		hit.focus_mode = Control.FOCUS_NONE
		hit.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		hit.mouse_entered.connect(_select_event_option.bind(index, option))
		hit.mouse_exited.connect(_clear_event_option_selection)
		hit.focus_entered.connect(_select_event_option.bind(index, option))
		hit.pressed.connect(_choose_event_option.bind(option))
		row.add_child(hit)
		event_corner_groups.append(_create_event_corners(row))


func _render_chest_choice_cards(options: Array) -> void:
	for index in options.size():
		var option: Dictionary = options[index]
		var entry: Dictionary = option.get("entry", {})
		var card := Panel.new()
		card.position = Vector2(index * 164.0 + 2.0, 0)
		card.size = Vector2(158, 155)
		var rarity := clampi(int(entry.get("rarity", 0)), 0, 2)
		var border_colors := [Color("b8bdc5"), Color("3e95d8"), Color("c45ad9")]
		card.add_theme_stylebox_override("panel", _panel_style(Color("f5f5f2"), border_colors[rarity], 3))
		event_option_area.add_child(card)
		var icon := TextureRect.new()
		icon.position = Vector2(45, 9)
		icon.size = Vector2(68, 68)
		icon.texture = load(String(entry.get("path", ""))) as Texture2D
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(icon)
		var name_label := _event_rich_label(card, Rect2(8, 78, 142, 28), 15)
		name_label.text = "[center][color=#30333d]%s[/color][/center]" % String(entry.get("name", "未知奖励"))
		var effect_label := _event_rich_label(card, Rect2(9, 104, 140, 40), 10)
		effect_label.text = "[center][color=#626875]%s[/color][/center]" % String(entry.get("effect", ""))
		var hit := Button.new()
		hit.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		hit.flat = true
		hit.focus_mode = Control.FOCUS_NONE
		hit.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		hit.pressed.connect(_choose_event_option.bind(option))
		card.add_child(hit)
		var corners := _create_event_corners(card)
		event_corner_groups.append(corners)
		hit.mouse_entered.connect(_select_event_option.bind(index, option))
		hit.mouse_exited.connect(_clear_event_option_selection)


func _play_chest_open_animation(parent: Control) -> void:
	var frames := SpriteFrames.new()
	frames.add_animation(&"open")
	frames.set_animation_speed(&"open", 8.0)
	frames.set_animation_loop(&"open", false)
	# Gold chest open animation is row 6 of the authored 5x8 sheet.
	for frame_index in 5:
		var atlas := AtlasTexture.new()
		atlas.atlas = CHEST_SHEET
		atlas.region = Rect2i(frame_index * CHEST_FRAME_SIZE.x, 5 * CHEST_FRAME_SIZE.y, CHEST_FRAME_SIZE.x, CHEST_FRAME_SIZE.y)
		frames.add_frame(&"open", atlas, 1.0 if frame_index < 4 else 2.5)
	var chest := AnimatedSprite2D.new()
	chest.sprite_frames = frames
	chest.animation = &"open"
	chest.position = parent.size * 0.5
	chest.scale = Vector2(4.0, 4.0)
	chest.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	chest.z_index = 2
	parent.add_child(chest)
	chest.play()


func _select_event_option(index: int, _option: Dictionary) -> void:
	for group_index in event_corner_groups.size():
		for corner in event_corner_groups[group_index]:
			(corner as TextureRect).visible = group_index == index
	_start_event_corner_animation(index)


func _clear_event_option_selection() -> void:
	if event_corner_tween and event_corner_tween.is_valid():
		event_corner_tween.kill()
	for group in event_corner_groups:
		for corner in group:
			var corner_texture := corner as TextureRect
			corner_texture.position = corner_texture.get_meta("base_position", corner_texture.position)
			corner_texture.modulate.a = 1.0
			corner_texture.visible = false


func _choose_event_option(option: Dictionary) -> void:
	if option.has("next"):
		event_stage_id = String(option["next"])
		_render_event_stage()
		return
	if String(option.get("action", "")) == "finish":
		GameState.complete_current_map_node()
		get_tree().reload_current_scene()
		return
	var kind := String(option.get("kind", "story"))
	var cost := int(option.get("cost", 0))
	if cost > 0 and not GameState.try_spend_coins(cost):
		event_description.text = "金币不足，无法选择这项行动。你仍可以选择其他安排。"
		coin_label.text = "$%d" % GameState.coins
		return
	match kind:
		"attribute":
			GameState.add_event_attribute(String(option["attribute"]), float(option["amount"]))
			event_result_text = "你接受了遗迹的力量。%s 已在本次远征中生效。" % String(option["tag"])
		"item":
			var item_entry: Dictionary = option.get("entry", event_consumable)
			if GameState.add_item(item_entry).is_empty():
				var item_gold := int(item_entry.get("sell_price", 1))
				GameState.add_coins(item_gold)
				event_result_text = "%s 已达到叠加上限，转化为 %d 枚金币。" % [String(item_entry["name"]), item_gold]
			else:
				event_result_text = "你收好了%s。%s" % [String(item_entry["name"]), String(item_entry["effect"])]
		"accessory":
			var accessory_entry: Dictionary = option.get("entry", event_loot)
			if GameState.add_accessory(accessory_entry).is_empty():
				var accessory_gold := int(accessory_entry.get("sell_price", 1))
				GameState.add_coins(accessory_gold)
				event_result_text = "%s 与现有饰品冲突，转化为 %d 枚金币。" % [String(accessory_entry["name"]), accessory_gold]
			else:
				event_result_text = "你佩戴了%s。%s" % [String(accessory_entry["name"]), String(accessory_entry["effect"])]
		"recovery":
			if GameState.run_lives < GameState.MAX_RUN_LIVES:
				GameState.restore_run_life(int(option.get("amount", 1)))
				event_result_text = "队伍得到充分休息，恢复了 1 点远征生命。"
			else:
				GameState.add_coins(3)
				event_result_text = "队伍状态良好，将剩余补给换成了 3 枚金币。"
		"creature":
			if int(GameState.creature_shop_pool.get(event_creature_path, 0)) <= 0:
				var exhausted_value := GameState.creature_sell_value(CREATURE_CATALOG.rarity_for_texture(event_creature_path), 1)
				GameState.add_coins(exhausted_value)
				event_result_text = "%s 已从共享卡池中售罄，奖励转化为了 %d 枚金币。" % [event_creature_name, exhausted_value]
			elif GameState.add_creature_reward(event_creature_path):
				GameState.take_creature_from_pool(event_creature_path)
				GameState.mark_creature_seen(event_creature_path)
				event_result_text = "%s 决定加入你的远征。%s" % [event_creature_name, String(option["tag"])]
			else:
				var rarity := CREATURE_CATALOG.rarity_for_texture(event_creature_path)
				var sell_value := GameState.creature_sell_value(rarity, 1)
				GameState.add_coins(sell_value)
				event_result_text = "队伍和备战席已满，角色卡按售价转化为了 %d 枚金币。" % sell_value
		"coins":
			var amount := int(option.get("amount", 0))
			GameState.add_coins(amount)
			event_result_text = "你整理好旅途中找到的货币。%s" % String(option["tag"])
		_:
			event_result_text = "你结束了调查，继续踏上远征。"
	event_result_kind = kind
	event_stage_id = "result"
	coin_label.text = "$%d" % GameState.coins
	_render_event_stage()


func _create_event_corners(parent: Control) -> Array[TextureRect]:
	var texture := load("res://素材/图鉴/selection_corners.png") as Texture2D
	var regions := [Rect2(0, 0, 14, 14), Rect2(67, 0, 14, 14), Rect2(0, 42, 14, 14), Rect2(67, 42, 14, 14)]
	var positions := [Vector2(-3, -3), Vector2(parent.size.x - 11, -3), Vector2(-3, parent.size.y - 11), Vector2(parent.size.x - 11, parent.size.y - 11)]
	var corners: Array[TextureRect] = []
	for index in 4:
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = regions[index]
		var corner := TextureRect.new()
		corner.position = positions[index]
		corner.size = Vector2(14, 14)
		corner.texture = atlas
		corner.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		corner.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		corner.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		corner.mouse_filter = Control.MOUSE_FILTER_IGNORE
		corner.visible = false
		corner.z_index = 5
		corner.set_meta("base_position", positions[index])
		parent.add_child(corner)
		corners.append(corner)
	return corners


func _start_event_corner_animation(index: int) -> void:
	if event_corner_tween and event_corner_tween.is_valid():
		event_corner_tween.kill()
	if index < 0 or index >= event_corner_groups.size():
		return
	var corners: Array = event_corner_groups[index]
	var directions := [Vector2(-2, -2), Vector2(2, -2), Vector2(-2, 2), Vector2(2, 2)]
	event_corner_tween = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	for corner_index in corners.size():
		var corner: TextureRect = corners[corner_index]
		var base_position: Vector2 = corner.get_meta("base_position", corner.position)
		corner.position = base_position
		corner.modulate.a = 1.0
		event_corner_tween.parallel().tween_property(corner, "position", base_position + directions[corner_index], 0.42)
		event_corner_tween.parallel().tween_property(corner, "modulate:a", 0.62, 0.42)
	event_corner_tween.chain()
	for corner_index in corners.size():
		var corner: TextureRect = corners[corner_index]
		var base_position: Vector2 = corner.get_meta("base_position", corner.position)
		event_corner_tween.parallel().tween_property(corner, "position", base_position, 0.42)
		event_corner_tween.parallel().tween_property(corner, "modulate:a", 1.0, 0.42)


func _event_rich_label(parent: Control, rect: Rect2, font_size: int) -> RichTextLabel:
	var label := RichTextLabel.new()
	label.position = rect.position
	label.size = rect.size
	label.bbcode_enabled = true
	label.fit_content = false
	label.scroll_active = false
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_override("normal_font", source_han_font)
	label.add_theme_font_size_override("normal_font_size", font_size)
	label.add_theme_color_override("default_color", Color("30333d"))
	label.add_theme_color_override("font_shadow_color", Color("d7d8df"))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label


func _add_event_texture(parent: Control, path: String, rect: Rect2, stretch := TextureRect.STRETCH_KEEP_ASPECT_CENTERED) -> TextureRect:
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


func _show_run_complete() -> void:
	input_locked = true
	var overlay := ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.02, 0.03, 0.05, 0.82)
	overlay.z_index = 150
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)
	var final_floor := GameState.is_final_floor()
	var result_title := "远 征 完 成" if final_floor else "第 %d 层 完 成" % GameState.floor
	_add_label(overlay, result_title, Rect2(340, 225, 600, 90), 42, Color("ffd45f"), HORIZONTAL_ALIGNMENT_CENTER)
	var result_detail := "区域 %d · 本区第 %d 层\n完成战斗：%d · 当前金币：%d · 剩余生命：%d" % [GameState.region, GameState.floor_in_region(), GameState.battle_victories, GameState.coins, GameState.run_lives]
	_add_label(overlay, result_detail, Rect2(340, 305, 600, 58), 16, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	var back := Button.new()
	back.position = Vector2(515, 382)
	back.size = Vector2(250, 66)
	back.text = "返回主菜单" if final_floor else "进入下一层"
	_style_button(back, Color("3d7180"), Color.WHITE, 20)
	back.pressed.connect(_return_to_main if final_floor else _advance_to_next_floor)
	overlay.add_child(back)


func _node_position(node_id: int) -> Vector2:
	var node_position: Vector2 = GameState.map_nodes[node_id]["position"]
	node_position.x = MAP_NODE_X_ANCHOR + (node_position.x - MAP_NODE_X_ANCHOR) * MAP_NODE_X_STRETCH
	node_position.y = MAP_NODE_Y_ANCHOR + (node_position.y - MAP_NODE_Y_ANCHOR) * MAP_NODE_Y_STRETCH
	return node_position


func _map_content_position_for_node(node_id: int) -> Vector2:
	var focus_x := _node_position(node_id).x
	var maximum_scroll := maxf(0.0, MAP_CONTENT_WIDTH - MAP_VIEWPORT_SIZE.x)
	var visible_left := clampf(focus_x - 430.0, MAP_CAMERA_LEFT_OVERSCAN, maximum_scroll)
	return Vector2(-MAP_VIEWPORT_POSITION.x - visible_left, -MAP_VIEWPORT_POSITION.y)


func _map_content_min_x() -> float:
	return -MAP_VIEWPORT_POSITION.x - maxf(0.0, MAP_CONTENT_WIDTH - MAP_VIEWPORT_SIZE.x)


func _map_content_max_x() -> float:
	return -MAP_VIEWPORT_POSITION.x - MAP_CAMERA_LEFT_OVERSCAN


func _focus_offset(node_id: int) -> Vector2:
	return Vector2.ZERO


func _return_to_main() -> void:
	GameState.has_started_new_game = false
	GameState.clear_run_save()
	get_tree().change_scene_to_file("res://main.tscn")


func _advance_to_next_floor() -> void:
	if GameState.advance_floor():
		get_tree().reload_current_scene()


func _style_button(button: Button, fill: Color, border: Color, font_size: int) -> void:
	button.add_theme_font_override("font", source_han_font)
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_disabled_color", Color("8d98a8"))
	button.add_theme_color_override("font_outline_color", Color.BLACK)
	button.add_theme_constant_override("outline_size", 1)
	button.add_theme_stylebox_override("normal", _panel_style(fill, border, 3))
	button.add_theme_stylebox_override("hover", _panel_style(fill.lightened(0.16), Color("ffe178"), 4))
	button.add_theme_stylebox_override("pressed", _panel_style(fill.darkened(0.12), Color.WHITE, 4))
	button.add_theme_stylebox_override("disabled", _panel_style(fill.darkened(0.48), Color("546172"), 2))


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
	style.corner_radius_top_left = 7
	style.corner_radius_top_right = 7
	style.corner_radius_bottom_left = 7
	style.corner_radius_bottom_right = 7
	return style
