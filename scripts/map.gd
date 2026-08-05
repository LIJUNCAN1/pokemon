extends Control

const SOURCE_HAN_FONT: FontFile = preload("res://assets/fonts/SourceHanSansSC-Heavy.otf")
const DESIGN_SIZE := Vector2(1280, 720)
const FULL_HD_SCALE := Vector2(1.5, 1.5)
const REFERENCE_SIZE := Vector2(1672, 941)
const REFERENCE_SCALE := Vector2(DESIGN_SIZE.x / REFERENCE_SIZE.x, DESIGN_SIZE.y / REFERENCE_SIZE.y)
const MAP_UI := "res://assets/ui/map/"
const EVENT := "res://素材/事件/"
const SCENE_ASSETS := "res://素材/场景/"
const POKEMON := "res://素材/宝可梦图/"
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

var source_han_font: FontFile
var rng := RandomNumberGenerator.new()
var world: Control
var hero: Panel
var node_buttons: Dictionary = {}
var input_locked := false
var status_label: Label
var coin_label: Label
var event_overlay: Control
var event_option_area: Control
var event_description: RichTextLabel
var event_detail_title: Label
var event_detail_type: Label
var event_detail_icon: TextureRect
var event_detail_summary: RichTextLabel
var event_detail_effect: RichTextLabel
var event_corner_groups: Array = []
var event_corner_tween: Tween
var event_story_id := 0
var event_stage_id := "root"
var event_item_path := ""
var event_creature_path := ""
var event_creature_name := ""
var event_item_name := ""
var event_result_text := ""
var event_result_kind := "story"
var chest_event := false
var chest_coin_amount := 0


func _ready() -> void:
	_apply_full_hd_layout()
	source_han_font = SOURCE_HAN_FONT.duplicate() as FontFile
	source_han_font.antialiasing = TextServer.FONT_ANTIALIASING_GRAY
	source_han_font.hinting = TextServer.HINTING_NORMAL
	source_han_font.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	source_han_font.oversampling = FULL_HD_SCALE.x
	source_han_font.allow_system_fallback = false
	if not GameState.map_initialized or GameState.map_nodes.size() != 23 or GameState.map_nodes[0].get("position") != Vector2(139, 450):
		_generate_map()
	input_locked = not GameState.map_intro_played
	_build_interface()
	_position_map_on_entry.call_deferred()


func _apply_full_hd_layout() -> void:
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	position = Vector2.ZERO
	size = DESIGN_SIZE
	scale = FULL_HD_SCALE


func _generate_map() -> void:
	rng.randomize()
	var seed_value := rng.randi()
	var nodes: Array[Dictionary] = []
	for spec in _reference_node_specs():
		nodes.append({
			"id": spec["id"],
			"column": spec["column"],
			"type": spec["type"],
			"position": spec["center"],
		})
	var edges := {
		0: [1, 2, 3],
		1: [4], 2: [5], 3: [6],
		4: [7], 5: [7, 8, 9], 6: [9],
		7: [10], 8: [11], 9: [12],
		10: [13], 11: [14], 12: [15],
		13: [16, 17], 14: [17], 15: [17, 18],
		16: [19], 17: [20], 18: [21],
		19: [22], 20: [22], 21: [22], 22: [],
	}
	GameState.set_map_data(seed_value, nodes, edges)


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

	_add_map_texture(world, MAP_UI + "full-background-completed.png", Rect2(Vector2.ZERO, REFERENCE_SIZE), 0)
	_build_paths()
	_add_map_texture(world, MAP_UI + "panels/trail-title-panel.png", Rect2(39, 149, 394, 64), 15)
	_add_map_texture(world, MAP_UI + "panels/progress-panel.png", Rect2(1330, 151, 305, 66), 15)
	_add_map_texture(world, MAP_UI + "panels/legend-background-content.png", Rect2(56, 765, 1562, 107), 16)

	_add_map_texture(world, MAP_UI + "header/run-counter.png", Rect2(39, 61, 182, 64), 30)
	_add_map_texture(world, MAP_UI + "header/currency-counter.png", Rect2(230, 63, 150, 62), 30)
	_add_map_texture(world, MAP_UI + "header/tab-map-selected.png", Rect2(498, 59, 255, 67), 30)
	_add_map_texture(world, MAP_UI + "header/tab-team.png", Rect2(763, 59, 248, 67), 30)
	_add_map_texture(world, MAP_UI + "header/tab-bag.png", Rect2(1019, 59, 248, 67), 30)
	_add_map_texture(world, MAP_UI + "header/tab-relics.png", Rect2(1275, 59, 248, 67), 30)
	var close_button := _add_map_texture_button(world, MAP_UI + "header/close-button.png", Rect2(1565, 59, 72, 67), 31)
	close_button.tooltip_text = "返回主菜单"
	close_button.pressed.connect(_return_to_main)

	_build_nodes()
	_build_hero()
	_add_map_texture(world, MAP_UI + "labels/start-label.png", Rect2(111, 514, 54, 20), 41)
	_add_map_texture(world, MAP_UI + "labels/boss-label.png", Rect2(1546, 508, 50, 21), 41)

	status_label = Label.new()
	status_label.visible = false
	add_child(status_label)
	coin_label = Label.new()
	coin_label.visible = false
	add_child(coin_label)


func _build_paths() -> void:
	_add_map_texture(world, MAP_UI + "map/route-connectors-runtime.png", Rect2(Vector2.ZERO, REFERENCE_SIZE), 20)


func _build_nodes() -> void:
	var selectable := _selectable_node_ids()
	for spec in _reference_node_specs():
		var node_id := int(spec["id"])
		var rect: Rect2 = spec["rect"]
		var texture := load(MAP_UI + "nodes/" + String(spec["asset"])) as Texture2D
		var button := TextureButton.new()
		button.position = rect.position
		button.size = rect.size
		button.texture_normal = texture
		button.texture_hover = texture
		button.texture_pressed = texture
		button.texture_disabled = texture
		button.ignore_texture_size = true
		button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		button.focus_mode = Control.FOCUS_NONE
		button.z_index = 40
		button.disabled = input_locked or node_id not in selectable
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if not button.disabled else Control.CURSOR_ARROW
		button.tooltip_text = String(NODE_LABELS.get(spec["type"], "节点"))
		button.pressed.connect(_on_node_pressed.bind(node_id))
		button.mouse_entered.connect(_on_node_hovered.bind(node_id))
		button.mouse_exited.connect(_on_node_unhovered.bind(node_id))
		world.add_child(button)
		node_buttons[node_id] = button
		_refresh_single_node(node_id)


func _build_hero() -> void:
	hero = Panel.new()
	hero.size = Vector2(96, 105)
	hero.position = _node_position(GameState.current_map_node) - hero.size * 0.5
	hero.z_index = 39
	hero.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hero.add_theme_stylebox_override("panel", _panel_style(Color.TRANSPARENT, Color("f0a71d"), 3))
	world.add_child(hero)


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


func _position_map_on_entry() -> void:
	await get_tree().process_frame
	world.position = Vector2.ZERO
	GameState.map_intro_played = true
	input_locked = false
	_refresh_node_interaction()
	if GameState.current_map_node_type() == "boss" and GameState.is_map_node_completed(GameState.current_map_node):
		_show_run_complete()


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
		button.disabled = input_locked or int(node_id) not in selectable
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if not button.disabled else Control.CURSOR_ARROW
		_refresh_single_node(int(node_id))


func _refresh_single_node(node_id: int) -> void:
	var button := node_buttons.get(node_id) as TextureButton
	if button == null:
		return
	if GameState.is_map_node_completed(node_id):
		button.modulate = Color(0.58, 0.58, 0.62, 1.0)
	else:
		button.modulate = Color.WHITE


func _on_node_hovered(node_id: int) -> void:
	var button := node_buttons.get(node_id) as TextureButton
	if button != null and not button.disabled:
		button.modulate = Color(1.12, 1.08, 0.90, 1.0)


func _on_node_unhovered(node_id: int) -> void:
	_refresh_single_node(node_id)


func _on_node_pressed(node_id: int) -> void:
	if input_locked or node_id not in _selectable_node_ids():
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
		"start":
			get_tree().change_scene_to_file("res://battle_prep.tscn")
		"chest":
			chest_event = true
			_show_event_popup()
		"event", "rest":
			_show_event_popup()
		"shop", "battle", "elite", "boss":
			get_tree().change_scene_to_file("res://battle_prep.tscn")
		_:
			GameState.complete_current_map_node()
			get_tree().reload_current_scene()


func _show_event_popup() -> void:
	_prepare_event_rewards()
	event_overlay = Control.new()
	event_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	event_overlay.z_index = 120
	add_child(event_overlay)
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.018, 0.022, 0.028, 0.98)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	event_overlay.add_child(shade)

	var illustration := Panel.new()
	illustration.position = Vector2(82, 30)
	illustration.size = Vector2(690, 325)
	illustration.clip_contents = true
	illustration.add_theme_stylebox_override("panel", _panel_style(Color("123646"), Color("d7d6df"), 5))
	event_overlay.add_child(illustration)
	_add_event_texture(illustration, SCENE_ASSETS + "图层 2.png", Rect2(5, 5, 680, 150), TextureRect.STRETCH_SCALE)
	_add_event_texture(illustration, SCENE_ASSETS + "图层 5.png", Rect2(5, 128, 680, 192), TextureRect.STRETCH_SCALE)
	var light := ColorRect.new()
	light.position = Vector2(240, 130)
	light.size = Vector2(220, 150)
	light.color = Color(0.36, 0.86, 0.60, 0.20)
	light.mouse_filter = Control.MOUSE_FILTER_IGNORE
	illustration.add_child(light)
	var story_creature := _add_event_texture(illustration, event_creature_path, Rect2(280, 105, 130, 155))
	story_creature.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_add_label(illustration, _event_title(), Rect2(18, 12, 654, 42), 25, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)

	event_option_area = Control.new()
	event_option_area.position = Vector2(82, 365)
	event_option_area.size = Vector2(760, 180)
	event_overlay.add_child(event_option_area)

	_add_event_texture(event_overlay, EVENT + "image-1785667721191-bpnz232e87t.png", Rect2(54, 565, 824, 126), TextureRect.STRETCH_SCALE)
	event_description = RichTextLabel.new()
	event_description.position = Vector2(80, 582)
	event_description.size = Vector2(772, 88)
	event_description.bbcode_enabled = true
	event_description.fit_content = false
	event_description.scroll_active = false
	event_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	event_description.add_theme_font_override("normal_font", source_han_font)
	event_description.add_theme_font_size_override("normal_font_size", 18)
	event_description.add_theme_color_override("default_color", Color("313440"))
	event_description.mouse_filter = Control.MOUSE_FILTER_IGNORE
	event_overlay.add_child(event_description)

	_add_event_texture(event_overlay, EVENT + "02_切图_2.png", Rect2(922, 24, 330, 666), TextureRect.STRETCH_SCALE)
	event_detail_title = _add_label(event_overlay, "", Rect2(947, 42, 150, 38), 20, Color.WHITE)
	event_detail_type = _add_label(event_overlay, "", Rect2(1100, 42, 125, 38), 14, Color.WHITE, HORIZONTAL_ALIGNMENT_RIGHT)
	_add_event_texture(event_overlay, EVENT + "image-1785667710877-puzgzca6peo.png", Rect2(950, 105, 126, 112), TextureRect.STRETCH_SCALE)
	event_detail_icon = _add_event_texture(event_overlay, event_creature_path, Rect2(964, 116, 98, 88))
	event_detail_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	event_detail_summary = _event_rich_label(event_overlay, Rect2(1090, 112, 130, 98), 15)
	event_detail_effect = _event_rich_label(event_overlay, Rect2(958, 260, 252, 338), 16)

	event_stage_id = "root"
	_render_event_stage()


func _prepare_event_rewards() -> void:
	rng.seed = GameState.map_seed + GameState.current_map_node * 997 + 41
	event_story_id = rng.randi_range(0, 2)
	var creature_index := rng.randi_range(0, EVENT_CREATURES.size() - 1)
	event_creature_path = EVENT_CREATURES[creature_index]
	event_creature_name = EVENT_CREATURE_NAMES[creature_index]
	var item_files: Array[String] = []
	for file_name in DirAccess.get_files_at("res://assets/items/64x64"):
		if file_name.ends_with(".png"):
			item_files.append(file_name)
	if item_files.is_empty():
		event_item_path = ""
		event_item_name = "神秘道具"
	else:
		var item_file := item_files[rng.randi_range(0, item_files.size() - 1)]
		event_item_path = "res://assets/items/64x64/%s" % item_file
		event_item_name = item_file.get_basename().replace("_", " ").capitalize()
	chest_coin_amount = rng.randi_range(5, 9)


func _event_title() -> String:
	if chest_event:
		return "遗失的宝箱"
	return ["月光遗迹", "暴雨中的旧驿站", "沉睡的孵化庭院"][event_story_id]


func _event_stage_data() -> Dictionary:
	if event_stage_id == "result":
		return {
			"story": event_result_text,
			"options": [{"text": "收好所得，继续远征", "tag": "", "kind": event_result_kind, "action": "finish", "detail": "本次事件已经结束。\n奖励已经加入本次远征。"}],
		}
	if chest_event:
		var chest_roll := posmod(GameState.map_seed + GameState.current_map_node * 37, 10)
		if chest_roll < 4:
			return {
				"story": "道路旁放着一只被遗忘的宝箱，锁扣已经松动，里面传来金币碰撞的声音。",
				"options": [{"text": "打开宝箱", "tag": "（金币：+%d）" % chest_coin_amount, "kind": "coins", "amount": chest_coin_amount, "detail": "获得宝箱中的金币。"}],
			}
		if chest_roll < 8:
			return {
				"story": "宝箱缝隙中透出微光，一件保存完好的装备正静静躺在其中。",
				"options": [{"text": "打开宝箱", "tag": "（道具：%s）" % event_item_name, "kind": "item", "detail": "获得一件随机道具并放入背包。"}],
			}
		return {
			"story": "宝箱突然轻轻晃动，里面似乎藏着一位等待同行的伙伴。",
			"options": [{"text": "打开宝箱", "tag": "（角色卡：%s）" % event_creature_name, "kind": "creature", "detail": "获得一张角色卡；队伍已满时转化为 8 金币。"}],
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
						{"text": "打开旅行者留下的箱子", "tag": "（道具：%s）" % event_item_name, "kind": "item", "detail": "获得一件随机道具并放入背包。"},
						{"text": "整理散落的钱袋", "tag": "（金币：+5）", "kind": "coins", "amount": 5, "detail": "获得 5 枚金币。"},
					]}
				"nest":
					return {"story": "低语来自破碎石柱后的巢穴。一只迷失的生物正被古代锁链困住。", "options": [
						{"text": "破坏锁链并带它离开", "tag": "（角色卡：%s）" % event_creature_name, "kind": "creature", "detail": "获得角色卡；队伍已满时会转化为 8 金币。"},
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
						{"text": "拆下稳定器", "tag": "（道具：%s）" % event_item_name, "kind": "item", "detail": "获得发电机中保存的一件随机道具。"},
					]}
				"archive":
					return {"story": "值班室的日志记录了最后一场暴雨。柜台下还压着驿站管理员未发出的补给。", "options": [
						{"text": "取走密封补给", "tag": "（道具：%s）" % event_item_name, "kind": "item", "detail": "获得一件随机道具并放入背包。"},
						{"text": "回收旧时代货币", "tag": "（金币：+6）", "kind": "coins", "amount": 6, "detail": "获得 6 枚金币。"},
					]}
				"signal":
					return {"story": "信号并非求救，而是一只躲雨生物发出的回应。它谨慎地注视着你。", "options": [
						{"text": "分享食物并邀请同行", "tag": "（角色卡：%s）" % event_creature_name, "kind": "creature", "detail": "获得角色卡；队伍已满时会转化为 8 金币。"},
						{"text": "让它为队伍指路", "tag": "（属性：全队最大生命 +10%）", "kind": "attribute", "attribute": "health", "amount": 0.10, "detail": "安全路线使全队在之后的战斗中拥有更多最大生命。"},
					]}
				_:
					return {"story": "暴雨迫使你进入一座废弃驿站。屋顶不停漏水，远处发电机偶尔闪出蓝光，地下还有断续信号。", "options": [
						{"text": "修复院子里的旧发电机", "tag": "", "kind": "story", "next": "generator", "detail": "发电机仍有少量能源，修复后也许可以重新分配。"},
						{"text": "搜索积满灰尘的值班室", "tag": "", "kind": "story", "next": "archive", "detail": "值班室里散落着日志和没有送出的包裹。"},
						{"text": "回应地下室传来的信号", "tag": "", "kind": "story", "next": "signal", "detail": "信号很微弱，但每隔数秒都会准确重复。"},
					]}
		_:
			match event_stage_id:
				"pool":
					return {"story": "池水倒映出并不存在的星空。触碰水面时，你感受到两种不同的祝福。", "options": [
						{"text": "接受繁茂祝福", "tag": "（属性：全队最大生命 +14%）", "kind": "attribute", "attribute": "health", "amount": 0.14, "detail": "提高本次远征中全队的最大生命。"},
						{"text": "接受星火祝福", "tag": "（属性：全队伤害 +10%）", "kind": "attribute", "attribute": "damage", "amount": 0.10, "detail": "提高本次远征中全队的技能伤害。"},
					]}
				"greenhouse":
					return {"story": "温室中央生长着一株透明植物，根系包裹着一枚保存完好的容器。", "options": [
						{"text": "摘下根系中的容器", "tag": "（道具：%s）" % event_item_name, "kind": "item", "detail": "获得一件被植物保护至今的随机道具。"},
						{"text": "采集成熟的能量果实", "tag": "（金币：+7）", "kind": "coins", "amount": 7, "detail": "出售能量果实，获得 7 枚金币。"},
					]}
				"cradle":
					return {"story": "哭声来自被花藤覆盖的摇篮。里面的生物睁开眼睛，主动把爪子伸向你。", "options": [
						{"text": "抱起它并一起旅行", "tag": "（角色卡：%s）" % event_creature_name, "kind": "creature", "detail": "获得角色卡；队伍已满时会转化为 8 金币。"},
						{"text": "修复摇篮的供能装置", "tag": "（属性：全队充能速度 +9%）", "kind": "attribute", "attribute": "charge", "amount": 0.09, "detail": "带走装置中的技术，提高全队技能充能速度。"},
					]}
				_:
					return {"story": "被月色笼罩的庭院中，植物仍按古老程序生长。水池、温室与摇篮室分别传来不同的声响。", "options": [
						{"text": "靠近映着星空的水池", "tag": "", "kind": "story", "next": "pool", "detail": "水面没有波纹，却能听见类似心跳的回响。"},
						{"text": "进入仍亮着灯的温室", "tag": "", "kind": "story", "next": "greenhouse", "detail": "玻璃之后有一株从未见过的透明植物。"},
						{"text": "寻找摇篮室里的哭声", "tag": "", "kind": "story", "next": "cradle", "detail": "哭声很轻，而且在听见你的脚步后突然停止。"},
					]}


func _render_event_stage() -> void:
	if event_corner_tween and event_corner_tween.is_valid():
		event_corner_tween.kill()
	for child in event_option_area.get_children():
		child.queue_free()
	event_corner_groups.clear()
	var stage := _event_stage_data()
	event_description.text = "[center]%s[/center]" % String(stage["story"])
	var options: Array = stage["options"]
	for index in options.size():
		var option: Dictionary = options[index]
		var row := Control.new()
		row.position = Vector2(0, index * 58.0)
		row.size = Vector2(760, 52)
		event_option_area.add_child(row)
		_add_event_texture(row, EVENT + "03_切图_3.png", Rect2(Vector2.ZERO, row.size), TextureRect.STRETCH_SCALE)
		var text_label := _event_rich_label(row, Rect2(22, 4, 716, 43), 15)
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
	if not options.is_empty():
		_show_event_stage_overview(options[0])


func _select_event_option(index: int, option: Dictionary) -> void:
	for group_index in event_corner_groups.size():
		for corner in event_corner_groups[group_index]:
			(corner as TextureRect).visible = group_index == index
	_start_event_corner_animation(index)
	var kind := String(option.get("kind", "story"))
	var color: Color = REWARD_COLORS.get(kind, REWARD_COLORS["story"])
	event_detail_title.text = String(option.get("text", "事件选择"))
	event_detail_title.add_theme_color_override("font_color", color if kind != "story" else Color.WHITE)
	event_detail_type.text = _event_kind_name(kind)
	event_detail_type.add_theme_color_override("font_color", color if kind != "story" else Color.WHITE)
	var summary_text := String(option.get("tag", ""))
	if summary_text.is_empty():
		summary_text = "继续故事"
	event_detail_summary.text = "[center][color=#%s]%s[/color][/center]" % [color.to_html(false), summary_text]
	event_detail_effect.text = "[center][color=#31343e]%s[/color][/center]" % String(option.get("detail", "选择后继续探索。"))
	event_detail_icon.visible = kind == "item" or kind == "creature"
	if kind == "item" and not event_item_path.is_empty():
		event_detail_icon.texture = load(event_item_path) as Texture2D
	elif kind == "creature":
		event_detail_icon.texture = load(event_creature_path) as Texture2D


func _clear_event_option_selection() -> void:
	if event_corner_tween and event_corner_tween.is_valid():
		event_corner_tween.kill()
	for group in event_corner_groups:
		for corner in group:
			var corner_texture := corner as TextureRect
			corner_texture.position = corner_texture.get_meta("base_position", corner_texture.position)
			corner_texture.modulate.a = 1.0
			corner_texture.visible = false


func _show_event_stage_overview(first_option: Dictionary) -> void:
	event_detail_title.text = _event_title()
	event_detail_title.add_theme_color_override("font_color", Color.WHITE)
	event_detail_type.text = "宝箱奖励" if chest_event else "随机事件"
	event_detail_summary.text = "[center][color=#667080]将鼠标放到选项上\n查看可能的结果[/color][/center]"
	event_detail_effect.text = "[center][color=#31343e]%s[/color][/center]" % String(first_option.get("detail", "探索故事并作出选择。"))
	event_detail_icon.visible = false


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
	match kind:
		"attribute":
			GameState.add_event_attribute(String(option["attribute"]), float(option["amount"]))
			event_result_text = "你接受了遗迹的力量。%s 已在本次远征中生效。" % String(option["tag"])
		"item":
			if not event_item_path.is_empty():
				GameState.add_item(event_item_path)
			event_result_text = "你收好了找到的物品。%s 已放入背包。" % String(option["tag"])
		"creature":
			if GameState.add_creature_reward(event_creature_path):
				GameState.mark_creature_seen(event_creature_path)
				event_result_text = "%s 决定加入你的远征。%s" % [event_creature_name, String(option["tag"])]
			else:
				GameState.coins += 8
				event_result_text = "队伍和备战席已满，角色卡转化为了 8 枚金币。"
		"coins":
			var amount := int(option.get("amount", 0))
			GameState.coins += amount
			event_result_text = "你整理好旅途中找到的货币。%s" % String(option["tag"])
		_:
			event_result_text = "你结束了调查，继续踏上远征。"
	event_result_kind = kind
	event_stage_id = "result"
	coin_label.text = "$%d" % GameState.coins
	_render_event_stage()


func _event_kind_name(kind: String) -> String:
	match kind:
		"attribute": return "属性强化"
		"item": return "道具奖励"
		"creature": return "角色卡"
		"coins": return "金币"
		_: return "故事选择"


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
	_add_label(overlay, "远 征 完 成", Rect2(340, 225, 600, 90), 42, Color("ffd45f"), HORIZONTAL_ALIGNMENT_CENTER)
	var back := Button.new()
	back.position = Vector2(515, 350)
	back.size = Vector2(250, 66)
	back.text = "返回主菜单"
	_style_button(back, Color("3d7180"), Color.WHITE, 20)
	back.pressed.connect(_return_to_main)
	overlay.add_child(back)


func _node_position(node_id: int) -> Vector2:
	var node_position: Vector2 = GameState.map_nodes[node_id]["position"]
	return node_position


func _focus_offset(node_id: int) -> Vector2:
	return Vector2.ZERO


func _return_to_main() -> void:
	get_tree().change_scene_to_file("res://main.tscn")


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
