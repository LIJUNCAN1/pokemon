extends Control

class Fighter:
	var sprite: TextureRect
	var texture_path := ""
	var level := 1
	var charge_frame: Panel
	var charge_fill: ColorRect
	var hp_label: Label
	var status_row: VBoxContainer
	var hp: int
	var max_hp: int
	var charge := 0.0
	var charge_rate: float
	var base_charge_rate: float
	var attack_timer := 0.0
	var base_attack_interval := 1.5
	var attack_speed_multiplier := 1.0
	var energy_per_attack := 0.25
	var trainer_buff_remaining := 0.0
	var trainer_attack_bonus := 0.0
	var trainer_attack_speed_bonus := 0.0
	var player_side: bool
	var alive := true
	var home_position: Vector2
	var base_scale := Vector2.ONE
	var traits := PackedStringArray()
	var damage_multiplier := 1.0
	var damage_reduction := 0.0
	var skill_hp_growth := 0.0
	var skill_dodge_growth := 0.0
	var skill_damage_reduction_growth := 0.0
	var heal_on_cast := 0.0
	var shield := 0
	var burn_stacks := 0
	var burn_remaining := 0.0
	var stun_remaining := 0.0
	var slow_remaining := 0.0
	var crit_chance := 0.05
	var dodge_chance := 0.0
	var control_resistance := 0.0
	var status_immune := false
	var revived_as_seedling := false
	var revived_as_spirit := false
	var mechanical_shock_ready := false
	var rock_armor_stacks := 0
	var formation_index := 0
	var attack_range := "melee"
	var target_rule := "front_row"
	var trigger_rule := "on_full_charge"
	var damage_range := Vector2i(9, 17)
	var skill_id := "basic"
	var skill_name := "基础攻击"
	var locked_target: Fighter
	var can_attack := true
	var attacking := false
	var boss_phase_triggered := false
	var boss_attack_count := 0
	var equipment: Array[String] = []
	var basic_hit_count := 0
	var equipment_low_hp_triggered := false
	var equipment_first_cast_triggered := false
	var equipment_control_immunity_used := false
	var equipment_revive_used := false
	var equipment_skill_damage := 0.0


const SOURCE_HAN_FONT: FontFile = preload("res://assets/fonts/SourceHanSansSC-Heavy.otf")
const CATALOG = preload("res://scripts/creature_catalog.gd")
const RARITY_TAG = preload("res://scripts/rarity_tag_style.gd")
const ITEM_CATALOG = preload("res://scripts/item_catalog.gd")
const EQUIPMENT_CATALOG = preload("res://scripts/equipment_catalog.gd")
const SETTINGS_OVERLAY_SCENE: PackedScene = preload("res://settings_overlay.tscn")
const DESIGN_SIZE := Vector2(1280, 720)
const FULL_HD_SCALE := Vector2(0.5, 0.5)
const SCENE_ASSETS := "res://素材/场景/"
const BATTLE_GRASS_TEXTURE := SCENE_ASSETS + "战斗草地.png"
const POKEMON := "res://素材/宝可梦图/"
const MIMIC_TEXTURE := "res://素材/图鉴/角色/宝箱怪.png"
const P7_PROJECTILE_SHEET: Texture2D = preload("res://素材/战斗场景/aseprite_export/P7kD08_sheet.png")
const P7_PROJECTILE_FRAME_SIZE := Vector2i(95, 76)
const P7_PROJECTILE_FRAME_COUNT := 22
const P7_PROJECTILE_FPS := 12.5
const P7_PROJECTILE_TRAVEL_FRAMES := 16
const STATUS_ICON_SHEET: Texture2D = preload("res://assets/ui/status/status_icons.png")
const STATUS_ICON_SIZE := Vector2i(16, 16)
const BATTLE_CRITICAL_ICON: Texture2D = preload("res://素材/战斗场景/图层5.png")
const BATTLE_RANGED_ICON: Texture2D = preload("res://素材/战斗场景/图层 3.png")
const BATTLE_MELEE_ICON: Texture2D = preload("res://素材/战斗场景/图层 4.png")
const BATTLE_SHIELD_ICON: Texture2D = preload("res://素材/战斗场景/图层 2.png")
const RESULT_COIN_ICON: Texture2D = preload("res://assets/ui/battle_result/coin.png")
const MENU_BUTTON_NORMAL: Texture2D = preload("res://assets/ui/pixel_menu/controls/button-normal.png")
const MENU_BUTTON_PRESSED: Texture2D = preload("res://assets/ui/pixel_menu/controls/button-pressed.png")
const PRESET_INFO_FRAME: Texture2D = preload("res://素材/主菜单/13_切图_13 拷贝.png")
const STONE_GOLEM_SHEET: Texture2D = preload("res://assets/boss/stone_golem/character_sheet.png")
const STONE_GOLEM_FRAME_SIZE := Vector2i(100, 100)
const ELEMENT_VFX: Dictionary = {
	"火": {
		"basic": ["res://assets/battle/vfx/fire_basic.png", Vector2i(48, 48), 11],
		"advanced": ["res://assets/battle/vfx/fire_advanced.png", Vector2i(48, 48), 18],
	},
	"雷": {
		"basic": ["res://assets/battle/vfx/lightning_basic.png", Vector2i(32, 32), 5],
		"advanced": ["res://assets/battle/vfx/lightning_advanced.png", Vector2i(64, 64), 13],
	},
	"自然": {
		"basic": ["res://assets/battle/vfx/nature_basic.png", Vector2i(32, 32), 18],
		"advanced": ["res://assets/battle/vfx/nature_advanced.png", Vector2i(32, 32), 12],
	},
	"岩": {
		"basic": ["res://assets/battle/vfx/rock_basic.png", Vector2i(32, 32), 36],
		"advanced": ["res://assets/battle/vfx/rock_advanced.png", Vector2i(32, 32), 36],
	},
}
const TRAIT_VFX_COLORS: Dictionary = {
	"自然": Color("a8a8a8"), "火": Color("fc9833"), "水": Color("4f9be6"), "雷": Color("f7d542"),
	"冰": Color("76d4c9"), "岩": Color("d77e47"), "月影": Color("70717e"), "星辉": Color("eb7ada"),
	"格斗": Color("dc3d4b"), "飞行": Color("91aee6"), "亡灵": Color("b65cce"), "风": Color("fd7c7a"),
	"晶石": Color("ceb984"),
}
const FALLBACK_TEAM: Array[String] = [
	POKEMON + "1 (5).png", POKEMON + "1 (6).png", POKEMON + "1 (7).png",
	POKEMON + "1 (8).png", POKEMON + "1 (9).png", POKEMON + "1 (10).png",
]
const ENEMY_TEAM: Array[String] = [
	POKEMON + "图层 2.png", POKEMON + "图层 3.png", POKEMON + "图层 4.png",
	POKEMON + "图层 5.png", POKEMON + "图层 6.png", POKEMON + "图层 7.png",
]
const TOP_X_POSITIONS: Array[float] = [230.0, 392.0, 550.0, 730.0, 892.0, 1050.0]
const BOTTOM_X_POSITIONS: Array[float] = [194.0, 356.0, 518.0, 761.0, 923.0, 1085.0]
const ROW_POSITIONS: Array[float] = [335.0, 438.0]
const DETAIL_RARITY_COLORS: Array[Color] = [Color("b8bdc5"), Color("58b85f"), Color("3e95d8"), Color("c45ad9"), Color("e3a62f")]

var source_han_font: FontFile
var fighters: Array[Fighter] = []
var rng := RandomNumberGenerator.new()
var battle_over := false
var status_label: Label
var player_synergies: Dictionary = {}
var nature_heal_elapsed := 0.0
var burn_elapsed := 0.0
var plant_growth_elapsed := 0.0
var healing_zone_elapsed := 0.0
var healing_zone_ticks := 0
var battle_speed := 1.0
var battle_elapsed := 0.0
var battle_speed_button: Button
var settings_overlay: Control
var fighter_info_panel: Panel
var fighter_info_icon: TextureRect
var fighter_info_role_icon: TextureRect
var fighter_info_name: Label
var fighter_info_summary: Label
var fighter_info_rarity: Label
var fighter_info_stats: Label
var fighter_info_skill: Label
var fighter_info_description: Label
var fighter_info_gradient: TextureRect
var fighter_info_portrait_panel: Panel
var fighter_info_element_panel: Panel
var fighter_info_race_panel: Panel
var fighter_info_element_icon: TextureRect
var fighter_info_race_icon: TextureRect
var fighter_info_element: Label
var fighter_info_race: Label
var fighter_info_skill_damage: Label
var fighter_info_cooldown: Label
var fighter_info_shadow: Panel
var fighter_info_skill_backdrop: Panel
var fighter_info_name_icon: Label
var victory_reward_text := ""
var result_item_rewards: Array[Dictionary] = []
var result_gold_reward := 0
var result_reward_sources: Array[String] = []
var consumable_bonuses: Dictionary = {"health": 0.0, "damage": 0.0, "charge": 0.0}
var trainer_battle_effect: Dictionary = {}
var inspected_fighter: Fighter
var p7_projectile_frames: SpriteFrames
var status_info_panel: Panel
var result_gold_info_panel: Panel

# Kept as a silent compatibility node for existing scene tests and older saves;
# actual playback is owned by the global crossfade manager.
@onready var battle_music: AudioStreamPlayer = $BattleMusic

func _ready() -> void:
	_apply_full_hd_layout()
	_start_battle_music()
	rng.randomize()
	source_han_font = SOURCE_HAN_FONT.duplicate() as FontFile
	source_han_font.antialiasing = TextServer.FONT_ANTIALIASING_GRAY
	source_han_font.multichannel_signed_distance_field = true
	source_han_font.msdf_pixel_range = 8
	source_han_font.msdf_size = 64
	source_han_font.hinting = TextServer.HINTING_NORMAL
	source_han_font.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	source_han_font.oversampling = FULL_HD_SCALE.x
	source_han_font.allow_system_fallback = false
	consumable_bonuses = GameState.take_next_battle_bonuses()
	trainer_battle_effect = GameState.take_trainer_battle_effect()
	_build_battlefield()


func _start_battle_music() -> void:
	MusicManager.play_music("res://assets/audio/echoes_of_the_crystal_cavern.mp3", 1.4)


func _apply_full_hd_layout() -> void:
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	position = Vector2.ZERO
	size = DESIGN_SIZE
	scale = FULL_HD_SCALE


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			var local_mouse := get_global_transform_with_canvas().affine_inverse() * get_viewport().get_mouse_position()
			if is_instance_valid(result_gold_info_panel) and not result_gold_info_panel.get_rect().has_point(local_mouse):
				_hide_result_gold_info()
				get_viewport().set_input_as_handled()
				return
			if is_instance_valid(status_info_panel) and not status_info_panel.get_rect().has_point(local_mouse):
				_hide_status_info()
				get_viewport().set_input_as_handled()
				return
			if is_instance_valid(fighter_info_panel) and fighter_info_panel.visible and not fighter_info_panel.get_rect().has_point(local_mouse):
				_hide_fighter_info()
				get_viewport().set_input_as_handled()
				return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		if is_instance_valid(result_gold_info_panel):
			_hide_result_gold_info()
			get_viewport().set_input_as_handled()
			return
		if is_instance_valid(status_info_panel):
			_hide_status_info()
			get_viewport().set_input_as_handled()
			return
		if is_instance_valid(fighter_info_panel) and fighter_info_panel.visible:
			_hide_fighter_info()
			get_viewport().set_input_as_handled()
			return
		if not is_instance_valid(settings_overlay):
			get_viewport().set_input_as_handled()
			_open_battle_settings()


func _process(delta: float) -> void:
	if battle_over:
		return
	delta *= battle_speed
	battle_elapsed += delta
	_process_synergy_timers(delta)
	var team_speed_bonus := _mechanical_team_speed_bonus() + _insect_team_speed_bonus()
	for fighter in fighters:
		if not fighter.alive:
			continue
		_update_trainer_buff(fighter, delta)
		if not fighter.can_attack:
			continue
		if fighter.attacking:
			continue
		if fighter.stun_remaining > 0.0:
			fighter.stun_remaining = maxf(fighter.stun_remaining - delta, 0.0)
			_update_status_icons(fighter)
			continue
		if fighter.slow_remaining > 0.0:
			fighter.slow_remaining = maxf(fighter.slow_remaining - delta, 0.0)
		var current_attack_speed := fighter.attack_speed_multiplier
		if fighter.player_side:
			current_attack_speed *= 1.0 + team_speed_bonus
		if fighter.slow_remaining > 0.0:
			current_attack_speed *= 0.65
		fighter.attack_timer -= delta * current_attack_speed
		if fighter.attack_timer <= 0.0:
			fighter.attack_timer = fighter.base_attack_interval
			_perform_basic_attack(fighter)
		_update_charge_bar(fighter)
		if fighter.charge >= 1.0 and not fighter.attacking:
			fighter.charge = 0.0
			_perform_skill(fighter)
	if is_instance_valid(fighter_info_panel) and fighter_info_panel.visible and inspected_fighter != null:
		_refresh_fighter_info()


func _build_battlefield() -> void:
	var biome := _battle_biome()
	match biome:
		"snow": _build_snow_biome()
		"cave": _build_cave_biome()
		_: _build_grass_biome()
	_build_platforms()
	_spawn_teams()
	if biome == "grass":
		_add_texture(SCENE_ASSETS + "图层 1.png", Rect2(0, 400, 1280, 315), 20, TextureRect.STRETCH_SCALE)
	elif biome == "snow":
		_add_texture(SCENE_ASSETS + "雪地 (3).png", Rect2(0, 390, 1280, 330), 20, TextureRect.STRETCH_SCALE)
	else:
		_add_texture(SCENE_ASSETS + "矿洞 (4).png", Rect2(0, 390, 1280, 330), 20, TextureRect.STRETCH_SCALE)
	_build_hud()


func _build_platforms() -> void:
	var platform_asset := SCENE_ASSETS + "图层 6.png"
	var lower_asset := SCENE_ASSETS + "图层 7.png"
	if _battle_biome() == "snow":
		platform_asset = SCENE_ASSETS + "雪地 (4).png"
		lower_asset = platform_asset
	elif _battle_biome() == "cave":
		platform_asset = SCENE_ASSETS + "矿洞 (1).png"
		lower_asset = platform_asset
	for group_x in [170.0, 670.0]:
		_add_texture(platform_asset, Rect2(group_x, 307, 440, 52), 4, TextureRect.STRETCH_SCALE)
	_add_texture(lower_asset, Rect2(135, 410, 446, 55), 4, TextureRect.STRETCH_SCALE)
	_add_texture(lower_asset, Rect2(702, 410, 446, 55), 4, TextureRect.STRETCH_SCALE)


func _battle_biome() -> String:
	if not GameState.map_initialized:
		return "grass"
	match clampi(GameState.region, 1, 3):
		2: return "snow"
		3: return "cave"
		_: return "grass"


func _build_grass_biome() -> void:
	var sky := _add_texture(SCENE_ASSETS + "图层 2.png", Rect2(0, 0, 1280, 220), 0)
	sky.stretch_mode = TextureRect.STRETCH_SCALE
	_add_texture(BATTLE_GRASS_TEXTURE, Rect2(0, 215, 1280, 371), 1, TextureRect.STRETCH_KEEP_ASPECT_COVERED)
	_add_texture(SCENE_ASSETS + "图层 3.png", Rect2(0, 82, 1280, 149), 3, TextureRect.STRETCH_SCALE)


func _build_snow_biome() -> void:
	# Snow keeps the authored depth order: distant forest, snow field, tree line,
	# fighters/platforms, then the close foreground added by _build_battlefield.
	_add_texture(SCENE_ASSETS + "雪地 (5).png", Rect2(0, 0, 1280, 610), 0, TextureRect.STRETCH_SCALE)
	_add_texture(SCENE_ASSETS + "雪地 (1).png", Rect2(0, 205, 1280, 390), 1, TextureRect.STRETCH_SCALE)
	_add_texture(SCENE_ASSETS + "雪地 (2).png", Rect2(0, 105, 1280, 180), 3, TextureRect.STRETCH_SCALE)


func _build_cave_biome() -> void:
	# Cave artwork is treated as a single fixed composition (no parallax).
	var cave_root := Control.new()
	cave_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cave_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cave_root.z_index = 0
	add_child(cave_root)
	_add_texture_to(cave_root, SCENE_ASSETS + "矿洞 (2).png", Rect2(0, 0, 1280, 335), 0, TextureRect.STRETCH_SCALE)
	_add_texture_to(cave_root, SCENE_ASSETS + "矿洞 (3).png", Rect2(0, 200, 1280, 520), 1, TextureRect.STRETCH_SCALE)


func _add_texture_to(parent: Control, path: String, rect: Rect2, z: int, stretch: int) -> TextureRect:
	var node := TextureRect.new()
	node.position = rect.position
	node.size = rect.size
	node.texture = load(path) as Texture2D
	node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	node.stretch_mode = stretch
	node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.z_index = z
	parent.add_child(node)
	return node


func _spawn_teams() -> void:
	var player_team: Array[String] = GameState.player_team.duplicate()
	if player_team.is_empty():
		player_team = FALLBACK_TEAM.duplicate()
	player_synergies = CATALOG.count_synergies(player_team)
	var boss_encounter := GameState.map_initialized and GameState.current_map_node_type() == "boss"
	var enemy_count := _enemy_count_for_current_node()
	for index in 6:
		var row := index / 3
		var column := index % 3
		var row_x_positions := TOP_X_POSITIONS if row == 0 else BOTTOM_X_POSITIONS
		if index < player_team.size() and not player_team[index].is_empty():
			var player_level := GameState.player_team_levels[index] if index < GameState.player_team_levels.size() else 1
			var equipment: Array = GameState.player_team_equipment[index] if index < GameState.player_team_equipment.size() else []
			_create_fighter(player_team[index], Vector2(row_x_positions[column], ROW_POSITIONS[row]), true, index, player_level, equipment)
		if not boss_encounter and index < enemy_count:
			if _is_mimic_battle():
				_create_mimic_fighter(Vector2(row_x_positions[column + 3], ROW_POSITIONS[row]), index)
			else:
				GameState.mark_creature_seen(ENEMY_TEAM[index])
				_create_fighter(ENEMY_TEAM[index], Vector2(row_x_positions[column + 3], ROW_POSITIONS[row]), false, index)
	if boss_encounter:
		_create_stone_golem_boss(Vector2(925, 388))


func _enemy_count_for_current_node() -> int:
	if not GameState.map_initialized:
		return 6
	if _is_mimic_battle():
		return 1
	var node_type := GameState.current_map_node_type()
	if _is_first_battle_node():
		return 1
	if node_type == "boss":
		return 1
	var column := int(GameState.current_map_node_data().get("column", 0))
	var count: int = clampi(2 + floori(float(maxi(column - 1, 0)) / 2.0), 2, 5)
	if node_type == "elite":
		count = mini(count + 1, 6)
	return count


func _is_first_battle_node() -> bool:
	if not GameState.map_initialized or GameState.battle_victories != 0:
		return false
	return bool(GameState.current_map_node_data().get("opening", false)) or GameState.current_map_node_type() in ["battle", "elite", "boss"]


func _is_mimic_battle() -> bool:
	return GameState.map_initialized and GameState.current_map_node_type() == "chest" and bool(GameState.current_map_node_data().get("mimic", false))


func _create_mimic_fighter(center: Vector2, index: int) -> void:
	# Reuse the battle presentation of a normal fighter, then replace its
	# gameplay data. Mimics are reward encounters: they can be hit but never act.
	_create_fighter(ENEMY_TEAM[0], center, false, index)
	var mimic: Fighter = fighters.back()
	mimic.texture_path = MIMIC_TEXTURE
	mimic.sprite.texture = load(MIMIC_TEXTURE) as Texture2D
	mimic.sprite.size = Vector2(112, 104)
	mimic.sprite.position = center + Vector2(-56, -82)
	mimic.sprite.pivot_offset = mimic.sprite.size * 0.5
	mimic.sprite.scale = Vector2.ONE
	mimic.base_scale = mimic.sprite.scale
	mimic.home_position = mimic.sprite.position
	mimic.can_attack = false
	mimic.charge = 0.0
	mimic.base_charge_rate = 0.0
	mimic.charge_rate = 0.0
	mimic.skill_name = "沉睡"
	mimic.charge_frame.visible = false
	mimic.charge_fill.visible = false
	if bool(GameState.current_map_node_data().get("opening", false)):
		mimic.max_hp = maxi(mimic.max_hp, 24)
	else:
		mimic.max_hp = maxi(roundi(mimic.max_hp * 1.30), 50)
	mimic.hp = mimic.max_hp
	mimic.hp_label.text = str(mimic.hp)
	_update_charge_bar(mimic)


func _create_stone_golem_boss(center: Vector2) -> void:
	# The boss owns one exclusive position centered between both enemy rows.
	# It uses a 100x100 source frame at exactly 300% of a normal 76px fighter.
	_create_fighter(ENEMY_TEAM[0], center, false, 1, 3)
	var boss: Fighter = fighters.back()
	boss.texture_path = "res://assets/boss/stone_golem/character_sheet.png"
	boss.traits = PackedStringArray(["岩", "机械"])
	boss.attack_range = "ranged"
	boss.skill_id = "boss_quake"
	boss.status_immune = true
	boss.skill_name = "地核震荡"
	boss.damage_range = Vector2i(24, 36)
	var boss_min_hp: int = [420, 520, 650][clampi(GameState.region - 1, 0, 2)]
	boss.max_hp = maxi(roundi(boss.max_hp * 1.8), boss_min_hp)
	boss.hp = boss.max_hp
	boss.damage_multiplier *= 1.15
	boss.base_charge_rate = 1.0 / 4.6
	boss.charge_rate = boss.base_charge_rate
	boss.base_attack_interval = 4.6
	boss.attack_timer = boss.base_attack_interval * 0.35
	boss.sprite.size = Vector2(228, 234)
	boss.sprite.position = center - Vector2(114, 150)
	boss.sprite.pivot_offset = boss.sprite.size * 0.5
	boss.sprite.scale = Vector2(-1, 1)
	boss.base_scale = boss.sprite.scale
	boss.home_position = boss.sprite.position
	boss.charge_frame.position = center + Vector2(-132, -78)
	boss.charge_frame.size = Vector2(14, 92)
	boss.charge_fill.position = Vector2(3, 87)
	boss.charge_fill.size.x = 8
	boss.hp_label.position = center + Vector2(-118, 72)
	boss.hp_label.size.x = 236
	_set_stone_golem_frame(boss, 0)
	_update_hp_label(boss)
	var idle_timer := Timer.new()
	idle_timer.wait_time = 0.14
	idle_timer.autostart = true
	idle_timer.set_meta("frame", 0)
	idle_timer.timeout.connect(_advance_stone_golem_idle.bind(boss, idle_timer))
	add_child(idle_timer)


func _advance_stone_golem_idle(boss: Fighter, timer: Timer) -> void:
	if not boss.alive or not is_instance_valid(boss.sprite):
		timer.stop()
		return
	var frame := (int(timer.get_meta("frame", 0)) + 1) % 4
	timer.set_meta("frame", frame)
	_set_stone_golem_frame(boss, frame)


func _set_stone_golem_frame(boss: Fighter, frame: int) -> void:
	var atlas := AtlasTexture.new()
	atlas.atlas = STONE_GOLEM_SHEET
	atlas.region = Rect2i(
		(frame % 10) * STONE_GOLEM_FRAME_SIZE.x,
		(frame / 10) * STONE_GOLEM_FRAME_SIZE.y,
		STONE_GOLEM_FRAME_SIZE.x,
		STONE_GOLEM_FRAME_SIZE.y,
	)
	boss.sprite.texture = atlas


func _apply_equipment_base_stats(fighter: Fighter) -> void:
	for equipment_id in fighter.equipment:
		var entry := EQUIPMENT_CATALOG.data(equipment_id)
		var amount := float(entry.get("amount", 0.0))
		match String(entry.get("stat", "")):
			"health":
				fighter.max_hp = roundi(fighter.max_hp * (1.0 + amount))
				fighter.hp = fighter.max_hp
			"damage": fighter.damage_multiplier *= 1.0 + amount
			"attack_speed": fighter.attack_speed_multiplier *= 1.0 + amount
			"control_resist": fighter.control_resistance = minf(fighter.control_resistance + amount, 0.80)
			"dodge": fighter.dodge_chance = minf(fighter.dodge_chance + amount, 0.50)
			"energy_gain": fighter.energy_per_attack = minf(fighter.energy_per_attack * (1.0 + amount), 1.0)
			"skill_damage": fighter.equipment_skill_damage += amount


func _equipment_effect_amount(fighter: Fighter, effect_type: String) -> float:
	for equipment_id in fighter.equipment:
		var entry := EQUIPMENT_CATALOG.data(equipment_id)
		if String(entry.get("effect_type", "")) == effect_type:
			return float(entry.get("effect_amount", 0.0))
	return 0.0


func _equipment_stat_amount(fighter: Fighter, stat: String) -> float:
	var total := 0.0
	for equipment_id in fighter.equipment:
		var entry := EQUIPMENT_CATALOG.data(equipment_id)
		if String(entry.get("stat", "")) == stat:
			total += float(entry.get("amount", 0.0))
	return total


func _create_fighter(texture_path: String, center: Vector2, player_side: bool, index: int, level: int = 1, equipment: Array = []) -> void:
	var fighter := Fighter.new()
	fighter.texture_path = texture_path
	fighter.level = clampi(level, 1, 3)
	fighter.player_side = player_side
	fighter.formation_index = index
	fighter.attack_range = CATALOG.attack_range_for_texture(texture_path)
	fighter.target_rule = CATALOG.target_rule_for_texture(texture_path)
	fighter.trigger_rule = CATALOG.trigger_rule_for_texture(texture_path)
	fighter.traits = CATALOG.traits_for_texture(texture_path)
	var base_hp := CATALOG.base_hp_for_texture(texture_path)
	var rarity_stat_multiplier := CATALOG.rarity_stat_multiplier(texture_path)
	base_hp = roundi(base_hp * rarity_stat_multiplier)
	fighter.damage_multiplier *= rarity_stat_multiplier
	fighter.damage_range = CATALOG.damage_range_for_texture(texture_path)
	fighter.skill_id = CATALOG.skill_id_for_texture(texture_path)
	fighter.skill_name = CATALOG.skill_name_for_texture(texture_path)
	fighter.energy_per_attack = CATALOG.energy_per_attack_for_texture(texture_path)
	for equipment_id in equipment:
		var id := String(equipment_id)
		if not EQUIPMENT_CATALOG.data(id).is_empty() and id not in fighter.equipment and fighter.equipment.size() < 2:
			fighter.equipment.append(id)
	if player_side:
		var growth := CATALOG.star_growth_for_texture(texture_path, fighter.level)
		base_hp = roundi(base_hp * float(growth.get("hp", 1.0)))
		fighter.damage_multiplier *= float(growth.get("damage", 1.0))
		base_hp = roundi(base_hp * (1.0 + GameState.run_health_bonus + float(consumable_bonuses["health"])))
		fighter.damage_multiplier *= 1.0 + GameState.run_damage_bonus + float(consumable_bonuses["damage"])
	if not player_side and GameState.map_initialized:
		var encounter_column := int(GameState.current_map_node_data().get("column", 0))
		var floor_scale := maxf(float(GameState.floor - 1), 0.0)
		base_hp = roundi(base_hp * (1.0 + encounter_column * 0.04 + floor_scale * 0.06))
		fighter.damage_multiplier *= 1.0 + encounter_column * 0.025 + floor_scale * 0.035
		match GameState.current_map_node_type():
			"elite":
				base_hp = roundi(base_hp * 1.22)
				fighter.damage_multiplier *= 1.12
			"boss":
				base_hp = roundi(base_hp * 1.30)
				fighter.damage_multiplier *= 1.20
		if _is_first_battle_node():
			base_hp = maxi(roundi(base_hp * 0.45), 18)
			fighter.damage_multiplier *= 0.45
	fighter.max_hp = base_hp
	fighter.hp = fighter.max_hp
	_apply_equipment_base_stats(fighter)
	fighter.base_charge_rate = 1.0 / maxf(CATALOG.cooldown_for_texture(texture_path), 0.5)
	fighter.base_charge_rate *= CATALOG.rarity_charge_multiplier(texture_path)
	if player_side:
		fighter.base_charge_rate *= float(CATALOG.star_growth_for_texture(texture_path, fighter.level).get("charge", 1.0))
		fighter.base_charge_rate *= 1.0 + GameState.run_charge_bonus + float(consumable_bonuses["charge"])
		fighter.crit_chance += GameState.accessory_effect_total("crit")
		fighter.dodge_chance += GameState.accessory_effect_total("dodge")
		fighter.control_resistance += GameState.accessory_effect_total("control_resist")
	if not player_side and GameState.map_initialized:
		var encounter_column := int(GameState.current_map_node_data().get("column", 0))
		fighter.base_charge_rate *= 1.0 + encounter_column * 0.035 + maxf(float(GameState.floor - 1), 0.0) * 0.025
		if GameState.current_map_node_type() == "elite":
			fighter.base_charge_rate *= 1.12
		elif GameState.current_map_node_type() == "boss":
			fighter.base_charge_rate *= 1.25
		if _is_first_battle_node():
			fighter.base_charge_rate *= 0.72
	fighter.charge_rate = fighter.base_charge_rate
	fighter.base_attack_interval = maxf(CATALOG.cooldown_for_texture(texture_path) * 0.72, 0.65)
	fighter.attack_timer = fighter.base_attack_interval * 0.35
	if player_side and not trainer_battle_effect.is_empty():
		fighter.trainer_attack_bonus = float(trainer_battle_effect.get("attack_bonus", 0.0))
		fighter.trainer_attack_speed_bonus = float(trainer_battle_effect.get("attack_speed_bonus", 0.0))
		fighter.trainer_buff_remaining = float(trainer_battle_effect.get("duration", 0.0))
		fighter.damage_multiplier *= 1.0 + fighter.trainer_attack_bonus
		fighter.attack_speed_multiplier *= 1.0 + fighter.trainer_attack_speed_bonus
	if player_side and fighter.traits.has("岩"):
		fighter.damage_reduction = CATALOG.effect_value("岩", int(player_synergies.get("岩", 0)))
	if player_side and fighter.traits.has("虫群"):
		fighter.base_charge_rate *= 1.0 + CATALOG.effect_value("虫群", int(player_synergies.get("虫群", 0)))
	if player_side and fighter.traits.has("龙族"):
		fighter.damage_multiplier *= 1.0 + CATALOG.effect_value("龙族", int(player_synergies.get("龙族", 0)))
	if player_side and fighter.traits.has("灵体"):
		fighter.heal_on_cast = CATALOG.effect_value("灵体", int(player_synergies.get("灵体", 0)))
	if player_side and fighter.traits.has("机械"):
		var mechanical_tier := CATALOG.active_tier("机械", int(player_synergies.get("机械", 0)))
		if mechanical_tier >= 0:
			fighter.shield = roundi(fighter.max_hp * 0.20)
			fighter.mechanical_shock_ready = mechanical_tier >= 1
	if player_side and fighter.traits.has("月影") and CATALOG.active_tier("月影", int(player_synergies.get("月影", 0))) >= 0:
		fighter.dodge_chance += CATALOG.effect_value("月影", int(player_synergies.get("月影", 0)))
	if player_side and fighter.traits.has("星辉") and CATALOG.active_tier("星辉", int(player_synergies.get("星辉", 0))) >= 0:
		fighter.base_charge_rate *= 1.0 + CATALOG.effect_value("星辉", int(player_synergies.get("星辉", 0)))
	if player_side and fighter.traits.has("格斗") and CATALOG.active_tier("格斗", int(player_synergies.get("格斗", 0))) >= 0:
		var fighter_bonus := CATALOG.effect_value("格斗", int(player_synergies.get("格斗", 0)))
		fighter.max_hp = roundi(fighter.max_hp * (1.0 + fighter_bonus))
		fighter.hp = fighter.max_hp
		fighter.damage_multiplier *= 1.0 + fighter_bonus
	if player_side and fighter.traits.has("飞行") and CATALOG.active_tier("飞行", int(player_synergies.get("飞行", 0))) >= 0:
		fighter.dodge_chance += CATALOG.effect_value("飞行", int(player_synergies.get("飞行", 0)))
		fighter.target_rule = "rear_chance"
	if player_side and fighter.traits.has("亡灵") and CATALOG.active_tier("亡灵", int(player_synergies.get("亡灵", 0))) >= 0:
		fighter.heal_on_cast = maxf(fighter.heal_on_cast, CATALOG.effect_value("亡灵", int(player_synergies.get("亡灵", 0))))
	if player_side and fighter.traits.has("风") and CATALOG.active_tier("风", int(player_synergies.get("风", 0))) >= 0:
		fighter.base_charge_rate *= 1.0 + CATALOG.effect_value("风", int(player_synergies.get("风", 0)))
	if player_side and fighter.traits.has("晶石") and CATALOG.active_tier("晶石", int(player_synergies.get("晶石", 0))) >= 0:
		fighter.shield = maxi(fighter.shield, roundi(fighter.max_hp * CATALOG.effect_value("晶石", int(player_synergies.get("晶石", 0)))))
		fighter.damage_reduction = maxf(fighter.damage_reduction, 0.08)
	fighter.charge_rate = fighter.base_charge_rate

	var sprite := TextureRect.new()
	sprite.position = center + Vector2(-38, -66)
	sprite.size = Vector2(76, 78)
	sprite.texture = load(texture_path) as Texture2D
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.mouse_filter = Control.MOUSE_FILTER_STOP
	sprite.pivot_offset = sprite.size * 0.5
	sprite.scale = Vector2.ONE if player_side else Vector2(-1, 1)
	sprite.z_index = 10
	add_child(sprite)
	fighter.sprite = sprite
	fighter.base_scale = sprite.scale
	fighter.home_position = sprite.position
	sprite.gui_input.connect(_on_fighter_gui_input.bind(fighter))

	var charge_frame := Panel.new()
	charge_frame.position = center + Vector2(-54, -56)
	charge_frame.size = Vector2(12, 66)
	charge_frame.z_index = 11
	charge_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	charge_frame.add_theme_stylebox_override("panel", _panel_style(Color(0.04, 0.07, 0.08, 0.9), Color.WHITE, 2))
	add_child(charge_frame)
	fighter.charge_frame = charge_frame

	var charge_fill := ColorRect.new()
	charge_fill.position = Vector2(3, 61)
	charge_fill.size = Vector2(6, 0)
	charge_fill.color = Color.WHITE
	charge_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	charge_frame.add_child(charge_fill)
	fighter.charge_fill = charge_fill

	var hp_color := Color(0.72, 0.94, 1.0) if player_side else Color(1.0, 0.72, 0.72)
	fighter.hp_label = _add_label("", Rect2(center.x - 52, center.y + 11, 104, 20), 11, hp_color, HORIZONTAL_ALIGNMENT_CENTER, 12)
	var status_row := VBoxContainer.new()
	status_row.position = center + Vector2(43, -61)
	status_row.size = Vector2(18, 96)
	status_row.alignment = BoxContainer.ALIGNMENT_BEGIN
	status_row.add_theme_constant_override("separation", 2)
	status_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	status_row.z_index = 13
	add_child(status_row)
	fighter.status_row = status_row
	_update_hp_label(fighter)
	fighters.append(fighter)


func _build_hud() -> void:
	var battle_title := "远 征 战 斗"
	if GameState.map_initialized:
		match GameState.current_map_node_type():
			"battle": battle_title = "普 通 战"
			"elite": battle_title = "精 英 战"
			"boss": battle_title = "B O S S 战"
			"chest": battle_title = "宝 箱 怪" if _is_mimic_battle() else battle_title
	_add_label(battle_title, Rect2(430, 7, 420, 48), 30, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, 45)
	_add_label("我方", Rect2(14, 270, 120, 28), 17, Color.WHITE, HORIZONTAL_ALIGNMENT_LEFT, 45)
	_add_label("敌方", Rect2(1146, 270, 120, 28), 17, Color.WHITE, HORIZONTAL_ALIGNMENT_RIGHT, 45)
	status_label = _add_label("技能条充满后自动攻击随机目标", Rect2(360, 665, 560, 34), 14, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, 45)
	battle_speed_button = Button.new()
	battle_speed_button.position = Vector2(1135, 10)
	battle_speed_button.size = Vector2(125, 45)
	battle_speed_button.text = "倍速 1x"
	battle_speed_button.add_theme_font_override("font", source_han_font)
	battle_speed_button.add_theme_font_size_override("font_size", 16)
	battle_speed_button.add_theme_color_override("font_color", Color.WHITE)
	battle_speed_button.add_theme_color_override("font_outline_color", Color.BLACK)
	battle_speed_button.add_theme_constant_override("outline_size", 1)
	battle_speed_button.add_theme_stylebox_override("normal", _panel_style(Color(0.12, 0.38, 0.52, 0.95), Color.WHITE, 2))
	battle_speed_button.add_theme_stylebox_override("hover", _panel_style(Color(0.18, 0.50, 0.64, 0.98), Color.WHITE, 2))
	battle_speed_button.add_theme_stylebox_override("pressed", _panel_style(Color(0.08, 0.27, 0.38, 1.0), Color.WHITE, 2))
	battle_speed_button.z_index = 45
	battle_speed_button.pressed.connect(_cycle_battle_speed)
	add_child(battle_speed_button)

	var settings_button := Button.new()
	settings_button.position = Vector2(1065, 10)
	settings_button.size = Vector2(60, 45)
	settings_button.text = "设置"
	settings_button.add_theme_font_override("font", source_han_font)
	settings_button.add_theme_font_size_override("font_size", 15)
	settings_button.add_theme_color_override("font_color", Color.WHITE)
	settings_button.add_theme_color_override("font_outline_color", Color.BLACK)
	settings_button.add_theme_constant_override("outline_size", 1)
	settings_button.add_theme_stylebox_override("normal", _panel_style(Color(0.18, 0.20, 0.24, 0.95), Color.WHITE, 2))
	settings_button.add_theme_stylebox_override("hover", _panel_style(Color(0.28, 0.31, 0.36, 0.98), Color.WHITE, 2))
	settings_button.add_theme_stylebox_override("pressed", _panel_style(Color(0.10, 0.12, 0.15, 1.0), Color.WHITE, 2))
	settings_button.z_index = 45
	settings_button.pressed.connect(_open_battle_settings)
	add_child(settings_button)
	_build_fighter_info_panel()


func _build_fighter_info_panel() -> void:
	fighter_info_panel = Panel.new()
	fighter_info_panel.position = Vector2(456, 104)
	fighter_info_panel.size = Vector2(369, 305)
	fighter_info_panel.z_index = 100
	fighter_info_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var outer_style := _panel_style(Color.TRANSPARENT, Color.BLACK, 4)
	outer_style.corner_radius_top_left = 10
	outer_style.corner_radius_top_right = 10
	outer_style.corner_radius_bottom_left = 10
	outer_style.corner_radius_bottom_right = 10
	outer_style.anti_aliasing = false
	fighter_info_panel.add_theme_stylebox_override("panel", outer_style)
	fighter_info_panel.visible = false
	add_child(fighter_info_panel)

	fighter_info_gradient = TextureRect.new()
	fighter_info_gradient.position = Vector2(4, 4)
	fighter_info_gradient.size = Vector2(361, 297)
	fighter_info_gradient.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fighter_info_gradient.stretch_mode = TextureRect.STRETCH_SCALE
	fighter_info_gradient.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fighter_info_panel.add_child(fighter_info_gradient)

	var header_divider := ColorRect.new()
	header_divider.position = Vector2(16, 46)
	header_divider.size = Vector2(337, 1)
	header_divider.color = Color("d5dbe4")
	header_divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fighter_info_panel.add_child(header_divider)

	fighter_info_portrait_panel = Panel.new()
	fighter_info_portrait_panel.position = Vector2(16, 58)
	fighter_info_portrait_panel.size = Vector2(173, 132)
	fighter_info_portrait_panel.add_theme_stylebox_override("panel", _rounded_style(Color(1, 1, 1, 0.44), Color("d9dee7"), 1, 7))
	fighter_info_panel.add_child(fighter_info_portrait_panel)

	fighter_info_shadow = Panel.new()
	fighter_info_shadow.position = Vector2(46, 112)
	fighter_info_shadow.size = Vector2(82, 12)
	fighter_info_shadow.add_theme_stylebox_override("panel", _rounded_style(Color(0.12, 0.16, 0.19, 0.18), Color.TRANSPARENT, 0, 8))
	fighter_info_shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fighter_info_portrait_panel.add_child(fighter_info_shadow)

	fighter_info_icon = TextureRect.new()
	fighter_info_icon.position = Vector2(14, 6)
	fighter_info_icon.size = Vector2(145, 116)
	fighter_info_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fighter_info_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	fighter_info_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	fighter_info_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fighter_info_portrait_panel.add_child(fighter_info_icon)

	fighter_info_element_panel = Panel.new()
	fighter_info_element_panel.position = Vector2(205, 64)
	fighter_info_element_panel.size = Vector2(146, 56)
	fighter_info_panel.add_child(fighter_info_element_panel)
	fighter_info_race_panel = Panel.new()
	fighter_info_race_panel.position = Vector2(205, 129)
	fighter_info_race_panel.size = Vector2(146, 56)
	fighter_info_panel.add_child(fighter_info_race_panel)
	fighter_info_element_icon = _add_detail_texture(fighter_info_element_panel, Rect2(12, 8, 40, 40))
	fighter_info_race_icon = _add_detail_texture(fighter_info_race_panel, Rect2(12, 8, 40, 40))
	fighter_info_element = _add_info_label(fighter_info_element_panel, "", Rect2(58, 8, 78, 40), 17, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	fighter_info_race = _add_info_label(fighter_info_race_panel, "", Rect2(58, 8, 78, 40), 17, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)

	fighter_info_role_icon = TextureRect.new()
	fighter_info_role_icon.position = Vector2(34, 217)
	fighter_info_role_icon.size = Vector2(33, 33)
	fighter_info_role_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fighter_info_role_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	fighter_info_role_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	fighter_info_role_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fighter_info_panel.add_child(fighter_info_role_icon)
	fighter_info_skill_backdrop = Panel.new()
	fighter_info_skill_backdrop.position = Vector2(22, 211)
	fighter_info_skill_backdrop.size = Vector2(58, 58)
	fighter_info_skill_backdrop.add_theme_stylebox_override("panel", _rounded_style(Color("ef3f64"), Color("ffc1cc"), 2, 29))
	fighter_info_panel.add_child(fighter_info_skill_backdrop)

	var bottom_panel := Panel.new()
	bottom_panel.position = Vector2(16, 205)
	bottom_panel.size = Vector2(337, 84)
	bottom_panel.add_theme_stylebox_override("panel", _rounded_style(Color("fbfcff"), Color("d9dee7"), 1, 7))
	fighter_info_panel.add_child(bottom_panel)
	fighter_info_skill_backdrop.move_to_front()
	fighter_info_role_icon.move_to_front()

	fighter_info_name_icon = _add_info_label(fighter_info_panel, "◆", Rect2(18, 7, 26, 36), 21, Color("b8bdc5"), HORIZONTAL_ALIGNMENT_CENTER)
	fighter_info_name = _add_info_label(fighter_info_panel, "", Rect2(47, 6, 190, 38), 22, Color("252b35"))
	fighter_info_summary = _add_info_label(fighter_info_panel, "", Rect2(20, 190, 331, 14), 8, Color("303642"), HORIZONTAL_ALIGNMENT_CENTER)
	fighter_info_rarity = _add_info_label(fighter_info_panel, "", Rect2(305, 12, 47, 25), 13, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	fighter_info_stats = _add_info_label(fighter_info_panel, "", Rect2(252, 258, 90, 22), 9, Color("303642"), HORIZONTAL_ALIGNMENT_RIGHT)
	fighter_info_skill = _add_info_label(fighter_info_panel, "", Rect2(92, 209, 100, 26), 14, Color("e43d5d"))
	fighter_info_skill_damage = _add_info_label(fighter_info_panel, "", Rect2(198, 211, 84, 18), 9, Color("e43d5d"), HORIZONTAL_ALIGNMENT_CENTER)
	fighter_info_cooldown = _add_info_label(fighter_info_panel, "", Rect2(282, 209, 60, 30), 9, Color("303642"), HORIZONTAL_ALIGNMENT_CENTER)
	fighter_info_description = _add_info_label(fighter_info_panel, "", Rect2(92, 242, 247, 42), 9, Color("303642"))
	fighter_info_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	fighter_info_description.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	for label in [fighter_info_name_icon, fighter_info_name, fighter_info_summary, fighter_info_stats, fighter_info_skill, fighter_info_skill_damage, fighter_info_cooldown, fighter_info_description, fighter_info_element, fighter_info_race]:
		_disable_info_shadow(label)

	var close_info := Button.new()
	close_info.position = Vector2(332, 4)
	close_info.size = Vector2(30, 30)
	close_info.text = "×"
	close_info.flat = true
	close_info.focus_mode = Control.FOCUS_NONE
	close_info.add_theme_font_override("font", source_han_font)
	close_info.add_theme_font_size_override("font_size", 22)
	close_info.add_theme_color_override("font_color", Color.WHITE)
	close_info.pressed.connect(_hide_fighter_info)
	fighter_info_panel.add_child(close_info)


func _on_fighter_gui_input(event: InputEvent, fighter: Fighter) -> void:
	if not event is InputEventMouseButton:
		return
	var mouse_event := event as InputEventMouseButton
	if mouse_event.button_index != MOUSE_BUTTON_RIGHT or not mouse_event.pressed:
		return
	get_viewport().set_input_as_handled()
	_show_fighter_info(fighter)


func _show_fighter_info(fighter: Fighter) -> void:
	inspected_fighter = fighter
	_refresh_fighter_info()
	fighter_info_panel.visible = true
	fighter_info_panel.move_to_front()


func _refresh_fighter_info() -> void:
	var fighter := inspected_fighter
	if fighter == null or not is_instance_valid(fighter.sprite):
		return
	var is_mimic := fighter.texture_path == MIMIC_TEXTURE
	var rarity := CATALOG.rarity_for_texture(fighter.texture_path)
	var display_name := "宝箱怪" if is_mimic else CATALOG.name_for_texture(fighter.texture_path)
	var side_name := "我方" if fighter.player_side else "敌方"
	var rarity_name := "特殊" if is_mimic else CATALOG.RARITY_NAMES[rarity]
	var role_text := "不会攻击" if is_mimic else CATALOG.combat_role_name(fighter.texture_path)
	var power := _fighter_attack_power(fighter)
	var damage_min := 0 if is_mimic else power.x
	var damage_max := 0 if is_mimic else power.y
	var skill_text := "静待挑战者" if is_mimic else CATALOG.skill_text_for_texture(fighter.texture_path)
	fighter_info_icon.texture = load(fighter.texture_path) as Texture2D
	fighter_info_role_icon.texture = null if is_mimic else (BATTLE_RANGED_ICON if fighter.attack_range == "ranged" else BATTLE_MELEE_ICON)
	fighter_info_name.text = display_name
	fighter_info_summary.text = "%s  生命 %d/%d  护盾 %d" % [side_name, fighter.hp, fighter.max_hp, fighter.shield]
	fighter_info_rarity.visible = not is_mimic
	if not is_mimic:
		RARITY_TAG.apply(fighter_info_rarity, rarity)
	var primary_trait := String(fighter.traits[0]) if not fighter.traits.is_empty() else "自然"
	var secondary_trait := String(fighter.traits[1]) if fighter.traits.size() > 1 else primary_trait
	var rarity_color: Color = DETAIL_RARITY_COLORS[clampi(rarity, 0, DETAIL_RARITY_COLORS.size() - 1)]
	fighter_info_name_icon.add_theme_color_override("font_color", rarity_color)
	var primary_color: Color = CATALOG.synergy_color(primary_trait) if not is_mimic else Color("858b93")
	var secondary_color: Color = CATALOG.synergy_color(secondary_trait) if not is_mimic else Color("858b93")
	fighter_info_gradient.texture = _make_fighter_detail_background(rarity_color, primary_color)
	fighter_info_element_panel.add_theme_stylebox_override("panel", _rounded_style(primary_color.lightened(0.12), primary_color.lightened(0.28), 1, 7))
	fighter_info_race_panel.add_theme_stylebox_override("panel", _rounded_style(secondary_color.lightened(0.08), secondary_color.lightened(0.24), 1, 7))
	fighter_info_element.text = primary_trait
	fighter_info_race.text = secondary_trait
	fighter_info_element_icon.texture = null if is_mimic else load(CATALOG.synergy_icon_path(primary_trait)) as Texture2D
	fighter_info_race_icon.texture = null if is_mimic else load(CATALOG.synergy_icon_path(secondary_trait)) as Texture2D
	var interval_text := "--" if is_mimic else ("%.2f秒" % _fighter_attack_interval(fighter))
	var skill_damage_max := 0 if is_mimic else roundi(float(damage_max) * 1.5)
	var equipment_names: Array[String] = []
	for equipment_id in fighter.equipment:
		equipment_names.append(String(EQUIPMENT_CATALOG.data(equipment_id).get("name", "装备")))
	fighter_info_stats.text = "LV.%d  %s%s" % [fighter.level, role_text, "  装备：%s" % "、".join(equipment_names) if not equipment_names.is_empty() else ""]
	fighter_info_skill.text = "%s" % fighter.skill_name
	var skill_name_width := minf(100.0, ceilf(source_han_font.get_string_size(fighter_info_skill.text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x))
	fighter_info_skill.size.x = skill_name_width
	fighter_info_skill_damage.position.x = fighter_info_skill.position.x + skill_name_width + 12.0
	fighter_info_skill_damage.text = "最高 %d 点伤害" % skill_damage_max
	fighter_info_cooldown.text = "攻击间隔\n%s" % interval_text
	fighter_info_description.text = skill_text


func _hide_fighter_info() -> void:
	fighter_info_panel.visible = false
	inspected_fighter = null


func _cycle_battle_speed() -> void:
	match battle_speed:
		1.0:
			battle_speed = 2.0
		2.0:
			battle_speed = 3.0
		_:
			battle_speed = 1.0
	if is_instance_valid(battle_speed_button):
		battle_speed_button.text = "倍速 %dx" % int(battle_speed)


func _open_battle_settings() -> void:
	if not is_instance_valid(settings_overlay):
		settings_overlay = SETTINGS_OVERLAY_SCENE.instantiate() as Control
		settings_overlay.set("exit_scene_path", "res://main.tscn")
		add_child(settings_overlay)
	else:
		settings_overlay.move_to_front()


func _update_trainer_buff(fighter: Fighter, delta: float) -> void:
	if fighter.trainer_buff_remaining <= 0.0:
		return
	fighter.trainer_buff_remaining = maxf(fighter.trainer_buff_remaining - delta, 0.0)
	if fighter.trainer_buff_remaining <= 0.0:
		if fighter.trainer_attack_bonus != 0.0:
			fighter.damage_multiplier /= 1.0 + fighter.trainer_attack_bonus
		if fighter.trainer_attack_speed_bonus != 0.0:
			fighter.attack_speed_multiplier /= 1.0 + fighter.trainer_attack_speed_bonus
		fighter.trainer_attack_bonus = 0.0
		fighter.trainer_attack_speed_bonus = 0.0


func _fighter_attack_interval(fighter: Fighter) -> float:
	var speed := maxf(fighter.attack_speed_multiplier, 0.05)
	if fighter.slow_remaining > 0.0:
		speed *= 0.65
	return maxf(fighter.base_attack_interval / speed, 0.25)


func _fighter_attack_power(fighter: Fighter) -> Vector2i:
	return Vector2i(
		roundi(fighter.damage_range.x * fighter.damage_multiplier),
		roundi(fighter.damage_range.y * fighter.damage_multiplier)
	)


func _perform_basic_attack(attacker: Fighter) -> void:
	if battle_over or not attacker.alive or not attacker.can_attack or attacker.attacking:
		return
	var targets := _living_fighters(not attacker.player_side)
	if targets.is_empty():
		_finish_battle(attacker.player_side)
		return
	var target := _select_attack_target(attacker, targets)
	if target == null:
		return
	if target.dodge_chance > 0.0 and rng.randf() < target.dodge_chance:
		_show_effect_label("闪避", target, Color(0.65, 0.9, 1.0))
		return
	var power := _fighter_attack_power(attacker)
	var damage := maxi(roundi(rng.randi_range(power.x, power.y) * (1.0 - target.damage_reduction)), 1)
	var missing_hp_bonus := _equipment_effect_amount(attacker, "missing_hp_damage")
	if missing_hp_bonus > 0.0:
		damage = roundi(damage * (1.0 + mini(floori((1.0 - float(attacker.hp) / maxf(attacker.max_hp, 1.0)) * 10.0), 5.0) * missing_hp_bonus))
	if target.burn_stacks > 0:
		damage = roundi(damage * (1.0 + _equipment_effect_amount(attacker, "burn_target_damage")))
	if rng.randf() < attacker.crit_chance:
		damage = roundi(damage * 1.5)
	attacker.attacking = true
	await _play_attack_animation(attacker, target)
	attacker.attacking = false
	if battle_over or not target.alive:
		return
	_play_element_contact_vfx(attacker, target)
	var dealt := _apply_damage(target, damage)
	attacker.charge = minf(attacker.charge + attacker.energy_per_attack, 1.0)
	attacker.basic_hit_count += 1
	if attacker.basic_hit_count % 3 == 0:
		attacker.charge = minf(attacker.charge + _equipment_effect_amount(attacker, "third_hit_energy"), 1.0)
	_update_charge_bar(attacker)
	_play_hit_feedback(target, dealt)
	var reflect_ratio := _equipment_effect_amount(target, "basic_reflect")
	if reflect_ratio > 0.0 and attacker.alive:
		var target_power := _fighter_attack_power(target)
		_damage_secondary(attacker, maxi(roundi(target_power.y * reflect_ratio), 1), Color(0.72, 0.78, 0.86), "反伤")
	status_label.text = "%s普通攻击造成 %d 点伤害" % ["我方" if attacker.player_side else "敌方", dealt]
	if target.hp <= 0:
		_defeat_fighter(target)
	_check_battle_end()


func _perform_skill(attacker: Fighter) -> void:
	if battle_over or not attacker.alive or not attacker.can_attack or attacker.attacking:
		return
	var targets := _living_fighters(not attacker.player_side)
	if targets.is_empty():
		_finish_battle(attacker.player_side)
		return
	var target := _select_attack_target(attacker, targets)
	if target == null:
		return
	if target.dodge_chance > 0.0 and rng.randf() < target.dodge_chance:
		_show_effect_label("闪避", target, Color(0.65, 0.9, 1.0))
		status_label.text = "%s闪避了攻击" % ("我方" if target.player_side else "敌方")
		return
	var attack_multiplier := attacker.damage_multiplier
	if attacker.player_side and attacker.traits.has("龙族") and attacker.hp * 2 < attacker.max_hp and CATALOG.active_tier("龙族", int(player_synergies.get("龙族", 0))) >= 2:
		attack_multiplier *= 1.35
	var damage := roundi(rng.randi_range(attacker.damage_range.x, attacker.damage_range.y) * attack_multiplier * (1.0 + attacker.equipment_skill_damage) * (1.0 - target.damage_reduction))
	var critical := rng.randf() < attacker.crit_chance
	if critical:
		damage = roundi(damage * 1.5)
	damage = maxi(damage, 1)
	attacker.attacking = true
	await _play_attack_animation(attacker, target)
	attacker.attacking = false
	if battle_over or not target.alive:
		return
	_play_element_contact_vfx(attacker, target)
	var dealt := _apply_damage(target, damage)
	status_label.text = "%s%s，%s造成 %d 点伤害" % ["我方释放" if attacker.player_side else "敌方释放", attacker.skill_name, "暴击！" if critical else "", dealt]
	if critical:
		_play_critical_icon(target)
	_play_hit_feedback(target, dealt)
	_apply_unique_skill(attacker, target, dealt)
	_apply_fire_attack(attacker, target)
	_apply_lightning_attack(attacker, target, dealt)
	_apply_dragon_splash(attacker, target, dealt)
	_charge_other_insects(attacker)
	if attacker.heal_on_cast > 0.0 and attacker.hp > 0:
		var healed := roundi(attacker.max_hp * attacker.heal_on_cast)
		_heal_fighter(attacker, healed)
	var retain_energy := _equipment_effect_amount(attacker, "retain_energy")
	if retain_energy > 0.0:
		_grant_skill_charge(attacker, retain_energy)
	if not attacker.equipment_first_cast_triggered:
		var team_energy := _equipment_effect_amount(attacker, "first_cast_team_energy")
		if team_energy > 0.0:
			attacker.equipment_first_cast_triggered = true
			var ally := _lowest_charge_fighter(_living_fighters(attacker.player_side), attacker)
			if ally != null:
				_grant_skill_charge(ally, team_energy)
	if target.hp <= 0:
		_defeat_fighter(target)
		var kill_energy := _equipment_effect_amount(attacker, "skill_kill_energy")
		if kill_energy > 0.0:
			_grant_skill_charge(attacker, kill_energy)
	_check_battle_end()


func _apply_unique_skill(attacker: Fighter, primary_target: Fighter, base_damage: int) -> void:
	var effects := CATALOG.skill_effects_for_texture(attacker.texture_path)
	if not effects.is_empty():
		_apply_catalog_skill_effects(attacker, primary_target, base_damage, effects)
		return
	match attacker.skill_id:
		"boss_quake":
			for enemy in _living_fighters(not attacker.player_side):
				if enemy == primary_target:
					continue
				_damage_secondary(enemy, maxi(roundi(base_damage * 0.62), 1), Color(0.78, 0.65, 0.42), "地震")
				enemy.charge = maxf(enemy.charge - 0.20, 0.0)
				_update_charge_bar(enemy)
				if enemy.hp <= 0:
					_defeat_fighter(enemy)
		"shield_self":
			var shield_bonus := GameState.accessory_effect_total("shield_power") if attacker.player_side else 0.0
			var shield_gain := maxi(roundi(attacker.max_hp * 0.18 * (1.0 + shield_bonus)), 1)
			attacker.shield += shield_gain
			_show_effect_label("护盾 +%d" % shield_gain, attacker, Color(0.62, 0.82, 1.0))
		"heal_ally":
			var allies := _living_fighters(attacker.player_side)
			if not allies.is_empty():
				var lowest: Fighter = allies[0]
				for ally in allies:
					if float(ally.hp) / maxf(float(ally.max_hp), 1.0) < float(lowest.hp) / maxf(float(lowest.max_hp), 1.0):
						lowest = ally
				_heal_fighter(lowest, maxi(roundi(attacker.max_hp * 0.16), 1))
		"team_charge":
			for ally in _living_fighters(attacker.player_side):
				if ally != attacker:
					ally.charge = minf(ally.charge + 0.16, 1.0)
					_update_charge_bar(ally)
			_show_effect_label("全队充能", attacker, Color(0.55, 0.85, 1.0))
		"burn":
			primary_target.burn_stacks += 2
			_show_effect_label("燃烧 +2", primary_target, Color(1.0, 0.38, 0.10))
		"slow":
			_apply_control(primary_target, "slow", 3.0)
			primary_target.charge = maxf(primary_target.charge - 0.20, 0.0)
			_update_charge_bar(primary_target)
			_show_effect_label("充能降低", primary_target, Color(0.50, 0.78, 1.0))
		"double_hit":
			_damage_secondary(primary_target, maxi(roundi(base_damage * 0.55), 1), Color(1.0, 0.72, 0.32), "连击")
		"seed_burst", "chain":
			var extra_targets := _living_fighters(not attacker.player_side)
			extra_targets.erase(primary_target)
			if not extra_targets.is_empty():
				var extra: Fighter = extra_targets[rng.randi_range(0, extra_targets.size() - 1)]
				_damage_secondary(extra, maxi(roundi(base_damage * (0.55 if attacker.skill_id == "chain" else 0.45)), 1), Color(0.62, 0.88, 0.42), "追击")
				if extra.hp <= 0:
					_defeat_fighter(extra)
		"aoe", "aoe_burn":
			for enemy in _living_fighters(not attacker.player_side):
				if enemy == primary_target:
					if attacker.skill_id == "aoe_burn":
						enemy.burn_stacks += 1
					continue
				_damage_secondary(enemy, maxi(roundi(base_damage * (0.48 if attacker.skill_id == "aoe" else 0.38)), 1), Color(0.72, 0.62, 1.0), "范围")
				if attacker.skill_id == "aoe_burn":
					enemy.burn_stacks += 1
				if enemy.hp <= 0:
					_defeat_fighter(enemy)


func _apply_catalog_skill_effects(attacker: Fighter, primary_target: Fighter, base_damage: int, effects: Array) -> void:
	var total_damage := base_damage
	for raw_effect in effects:
		var effect := Dictionary(raw_effect)
		var effect_type := String(effect.get("type", ""))
		match effect_type:
			"splash":
				var candidates := _living_fighters(not attacker.player_side)
				candidates.erase(primary_target)
				var hit_count := mini(int(effect.get("count", 1)), candidates.size())
				for index in hit_count:
					var target_index := rng.randi_range(0, candidates.size() - 1)
					var target: Fighter = candidates.pop_at(target_index)
					var damage := maxi(roundi(base_damage * float(effect.get("ratio", 0.4))), 1)
					total_damage += _deal_catalog_skill_damage(target, damage, "追击")
			"extra_hit":
				var damage := maxi(roundi(base_damage * float(effect.get("ratio", 0.5))), 1)
				total_damage += _deal_catalog_skill_damage(primary_target, damage, "连击")
			"random_hits":
				for index in int(effect.get("count", 1)):
					var candidates := _living_fighters(not attacker.player_side)
					if candidates.is_empty():
						break
					var target: Fighter = candidates[rng.randi_range(0, candidates.size() - 1)]
					var damage := maxi(roundi(base_damage * float(effect.get("ratio", 0.35))), 1)
					total_damage += _deal_catalog_skill_damage(target, damage, "追击")
			"aoe":
				for target in _living_fighters(not attacker.player_side).duplicate():
					if target == primary_target:
						continue
					var damage := maxi(roundi(base_damage * float(effect.get("ratio", 0.4))), 1)
					total_damage += _deal_catalog_skill_damage(target, damage, "范围")
			"execute":
				if primary_target.alive and float(primary_target.hp) / maxf(primary_target.max_hp, 1.0) < float(effect.get("threshold", 0.35)):
					var damage := maxi(roundi(base_damage * float(effect.get("ratio", 0.35))), 1)
					total_damage += _deal_catalog_skill_damage(primary_target, damage, "斩杀")
			"shield_bash":
				if primary_target.alive:
					var damage := maxi(roundi(attacker.shield * float(effect.get("ratio", 0.3))), 1)
					total_damage += _deal_catalog_skill_damage(primary_target, damage, "盾击")
			"shield_self":
				_grant_skill_shield(attacker, attacker, float(effect.get("ratio", 0.1)))
			"shield_team":
				for ally in _living_fighters(attacker.player_side):
					_grant_skill_shield(attacker, ally, float(effect.get("ratio", 0.08)))
			"shield_lowest":
				var ally := _lowest_health_fighter(_living_fighters(attacker.player_side))
				if ally != null:
					_grant_skill_shield(attacker, ally, float(effect.get("ratio", 0.1)))
			"heal_missing_self":
				var missing := maxi(attacker.max_hp - attacker.hp, 0)
				_heal_from_equipment_source(attacker, attacker, roundi(missing * float(effect.get("ratio", 0.1))))
			"heal_lowest":
				var ally := _lowest_health_fighter(_living_fighters(attacker.player_side))
				if ally != null:
					_heal_from_equipment_source(attacker, ally, maxi(roundi(attacker.max_hp * float(effect.get("ratio", 0.1)) * (1.0 + _equipment_stat_amount(attacker, "healing"))), 1))
			"heal_team":
				var amount := maxi(roundi(attacker.max_hp * float(effect.get("ratio", 0.06)) * (1.0 + _equipment_stat_amount(attacker, "healing"))), 1)
				for ally in _living_fighters(attacker.player_side):
					_heal_from_equipment_source(attacker, ally, amount)
			"lifesteal":
				_heal_from_equipment_source(attacker, attacker, maxi(roundi(total_damage * float(effect.get("ratio", 0.1))), 1))
			"charge_self":
				_grant_skill_charge(attacker, float(effect.get("amount", 0.1)))
			"charge_team":
				for ally in _living_fighters(attacker.player_side):
					if ally != attacker:
						_grant_skill_charge(ally, float(effect.get("amount", 0.1)))
			"charge_lowest":
				var ally := _lowest_charge_fighter(_living_fighters(attacker.player_side), attacker)
				if ally != null:
					_grant_skill_charge(ally, float(effect.get("amount", 0.2)))
			"drain_charge":
				_drain_skill_charge(primary_target, float(effect.get("amount", 0.1)))
			"drain_all":
				for target in _living_fighters(not attacker.player_side):
					_drain_skill_charge(target, float(effect.get("amount", 0.1)))
			"burn":
				_apply_skill_burn(primary_target, int(effect.get("stacks", 1)))
			"burn_all":
				for target in _living_fighters(not attacker.player_side):
					_apply_skill_burn(target, int(effect.get("stacks", 1)))
			"slow":
				_apply_control(primary_target, "slow", float(effect.get("duration", 2.0)))
			"slow_all":
				for target in _living_fighters(not attacker.player_side):
					_apply_control(target, "slow", float(effect.get("duration", 2.0)))
			"stun":
				_apply_control(primary_target, "stun", float(effect.get("duration", 0.8)))
			"cleanse_self":
				_cleanse_skill_status(attacker)
			"cleanse_lowest":
				var ally := _lowest_health_fighter(_living_fighters(attacker.player_side))
				if ally != null:
					_cleanse_skill_status(ally)
			"cleanse_team":
				for ally in _living_fighters(attacker.player_side):
					_cleanse_skill_status(ally)
			"max_hp_growth":
				var available := maxf(0.30 - attacker.skill_hp_growth, 0.0)
				var growth_ratio := minf(float(effect.get("ratio", 0.04)), available)
				if growth_ratio > 0.0:
					var growth := maxi(roundi(attacker.max_hp * growth_ratio), 1)
					attacker.skill_hp_growth += growth_ratio
					attacker.max_hp += growth
					attacker.hp += growth
					_update_hp_label(attacker)
					_show_effect_label("生命成长", attacker, Color(0.55, 1.0, 0.48))
			"damage_reduction":
				var available := maxf(0.20 - attacker.skill_damage_reduction_growth, 0.0)
				var gain := minf(float(effect.get("amount", 0.04)), available)
				attacker.skill_damage_reduction_growth += gain
				attacker.damage_reduction = minf(attacker.damage_reduction + gain, 0.75)
				_update_status_icons(attacker)
				if gain > 0.0:
					_show_effect_label("减伤 +%d%%" % roundi(gain * 100.0), attacker, Color(0.78, 0.82, 0.9))
			"dodge_growth":
				var available := maxf(0.32 - attacker.skill_dodge_growth, 0.0)
				var gain := minf(float(effect.get("amount", 0.08)), available)
				attacker.skill_dodge_growth += gain
				attacker.dodge_chance = minf(attacker.dodge_chance + gain, 0.75)
				_update_status_icons(attacker)
				if gain > 0.0:
					_show_effect_label("闪避 +%d%%" % roundi(gain * 100.0), attacker, Color(0.62, 0.88, 1.0))


func _deal_catalog_skill_damage(target: Fighter, damage: int, effect_name: String) -> int:
	if target == null or not target.alive:
		return 0
	var dealt := _apply_damage(target, damage)
	_play_hit_feedback(target, dealt)
	_show_effect_label("%s -%d" % [effect_name, dealt], target, Color(0.72, 0.82, 1.0))
	if target.hp <= 0:
		_defeat_fighter(target)
	return dealt


func _lowest_health_fighter(candidates: Array[Fighter]) -> Fighter:
	if candidates.is_empty():
		return null
	var lowest: Fighter = candidates[0]
	for candidate in candidates:
		if float(candidate.hp) / maxf(candidate.max_hp, 1.0) < float(lowest.hp) / maxf(lowest.max_hp, 1.0):
			lowest = candidate
	return lowest


func _lowest_charge_fighter(candidates: Array[Fighter], excluded: Fighter = null) -> Fighter:
	var lowest: Fighter = null
	for candidate in candidates:
		if candidate == excluded:
			continue
		if lowest == null or candidate.charge < lowest.charge:
			lowest = candidate
	return lowest


func _grant_skill_shield(source: Fighter, target: Fighter, ratio: float) -> void:
	var shield_bonus := GameState.accessory_effect_total("shield_power") if source.player_side else 0.0
	var amount := maxi(roundi(source.max_hp * ratio * (1.0 + shield_bonus + _equipment_stat_amount(source, "healing"))), 1)
	target.shield += amount
	_update_hp_label(target)
	_show_effect_label("护盾 +%d" % amount, target, Color(0.62, 0.82, 1.0))


func _grant_skill_charge(target: Fighter, amount: float) -> void:
	target.charge = minf(target.charge + amount, 1.0)
	_update_charge_bar(target)
	_show_effect_label("能量 +%d%%" % roundi(amount * 100.0), target, Color(0.55, 0.85, 1.0))


func _drain_skill_charge(target: Fighter, amount: float) -> void:
	target.charge = maxf(target.charge - amount, 0.0)
	_update_charge_bar(target)
	_show_effect_label("能量 -%d%%" % roundi(amount * 100.0), target, Color(0.50, 0.78, 1.0))


func _apply_skill_burn(target: Fighter, stacks: int) -> void:
	target.burn_stacks += stacks
	target.burn_remaining = maxf(target.burn_remaining, 4.5)
	_update_status_icons(target)
	_show_effect_label("燃烧 +%d" % stacks, target, Color(1.0, 0.38, 0.10))


func _cleanse_skill_status(target: Fighter) -> void:
	var had_status := target.burn_stacks > 0 or target.slow_remaining > 0.0 or target.stun_remaining > 0.0
	target.burn_stacks = 0
	target.burn_remaining = 0.0
	target.slow_remaining = 0.0
	target.stun_remaining = 0.0
	_update_status_icons(target)
	if had_status:
		_show_effect_label("净化", target, Color(0.68, 1.0, 0.82))


func _heal_from_equipment_source(source: Fighter, target: Fighter, amount: int) -> void:
	var overflow := maxi(amount - maxi(target.max_hp - target.hp, 0), 0)
	_heal_fighter(target, amount)
	var cap_ratio := _equipment_effect_amount(source, "overheal_shield")
	if overflow > 0 and cap_ratio > 0.0:
		var cap := roundi(target.max_hp * cap_ratio)
		target.shield = maxi(target.shield, mini(target.shield + overflow, cap))
		_update_hp_label(target)


func _select_attack_target(attacker: Fighter, targets: Array[Fighter]) -> Fighter:
	if attacker.locked_target != null and attacker.locked_target.alive and attacker.locked_target in targets:
		return attacker.locked_target
	var candidates: Array[Fighter] = []
	if attacker.target_rule == "lowest_hp":
		var lowest: Fighter = targets[0]
		for candidate in targets:
			if candidate.hp < lowest.hp:
				lowest = candidate
		attacker.locked_target = lowest
		return lowest
	if attacker.target_rule == "rear_chance" and rng.randf() < 0.35:
		candidates = _backline_targets(targets)
	if candidates.is_empty():
		if attacker.target_rule == "front_row":
			candidates = _melee_lane_targets(attacker, targets)
		else:
			candidates = _frontline_targets(targets)
	if candidates.is_empty():
		candidates = targets
	attacker.locked_target = candidates[rng.randi_range(0, candidates.size() - 1)]
	return attacker.locked_target


func _melee_lane_targets(attacker: Fighter, targets: Array[Fighter]) -> Array[Fighter]:
	var attacker_row := attacker.formation_index / 3
	var same_lane: Array[Fighter] = []
	for target in targets:
		if target.formation_index / 3 == attacker_row:
			same_lane.append(target)
	if not same_lane.is_empty():
		return _frontline_targets(same_lane)
	return _frontline_targets(targets)


func _frontline_targets(targets: Array[Fighter]) -> Array[Fighter]:
	var result: Array[Fighter] = []
	for row in 2:
		var row_targets: Array[Fighter] = []
		for target in targets:
			if target.formation_index / 3 == row:
				row_targets.append(target)
		if row_targets.is_empty():
			continue
		var target_is_player := row_targets[0].player_side
		var front_column := -1 if target_is_player else 3
		for target in row_targets:
			var column := target.formation_index % 3
			front_column = maxi(front_column, column) if target_is_player else mini(front_column, column)
		for target in row_targets:
			if target.formation_index % 3 == front_column:
				result.append(target)
	return result


func _backline_targets(targets: Array[Fighter]) -> Array[Fighter]:
	var result: Array[Fighter] = []
	for target in targets:
		var column := target.formation_index % 3
		if (target.player_side and column < 2) or (not target.player_side and column > 0):
			result.append(target)
	return result


func _play_attack_animation(attacker: Fighter, target: Fighter) -> void:
	if attacker.skill_id == "boss_quake":
		attacker.boss_attack_count += 1
		await _play_stone_golem_sequence(attacker, 50, 56, 0.075)
		if attacker.boss_attack_count % 3 == 0:
			await _play_stone_golem_laser(attacker, target)
		elif attacker.boss_attack_count % 3 == 2:
			await _play_stone_golem_melee(attacker, target)
		else:
			await _play_stone_golem_projectile(attacker, target)
		_set_stone_golem_frame(attacker, 0)
		return
	if attacker.attack_range == "melee":
		await _play_melee_contact(attacker, target)
		return
	var playback_scale := maxf(battle_speed, 0.01)
	var attack_tween := create_tween()
	attack_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	attack_tween.tween_property(attacker.sprite, "scale", attacker.base_scale * 1.28, 0.12 / playback_scale)
	attack_tween.tween_property(attacker.sprite, "scale", attacker.base_scale, 0.16 / playback_scale)
	await _play_element_projectile(attacker, target)


func _play_melee_contact(attacker: Fighter, target: Fighter) -> void:
	var start := attacker.sprite.position
	var target_center := _fighter_visual_center(target)
	var contact_x := target_center.x - attacker.sprite.size.x * (0.58 if attacker.player_side else 0.42)
	var contact_y := target_center.y - attacker.sprite.size.y * 0.5
	var contact := Vector2(contact_x, contact_y)
	var playback_scale := maxf(battle_speed, 0.01)
	var approach := create_tween()
	approach.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	approach.tween_property(attacker.sprite, "position", contact, 0.22 / playback_scale)
	await approach.finished
	# Damage and the red hit flash are triggered immediately after contact. The
	# attacker can return home independently without delaying the hit feedback.
	var retreat := create_tween()
	retreat.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	retreat.tween_property(attacker.sprite, "position", start, 0.24 / playback_scale)


func _play_element_projectile(attacker: Fighter, target: Fighter) -> void:
	var element := _fighter_element(attacker)
	var advanced := _uses_advanced_vfx(attacker)
	var config := _element_vfx_config(element, advanced)
	var frames := _sprite_frames_from_vfx_config(config, advanced)
	if frames == null:
		await get_tree().create_timer(0.24 / maxf(battle_speed, 0.01)).timeout
		return
	var projectile := AnimatedSprite2D.new()
	projectile.sprite_frames = frames
	projectile.animation = &"effect"
	projectile.centered = true
	projectile.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	projectile.flip_h = not attacker.player_side
	projectile.z_index = 21
	projectile.position = _fighter_attack_origin(attacker)
	projectile.scale = Vector2.ONE * (1.55 if advanced else 1.15)
	projectile.modulate = TRAIT_VFX_COLORS.get(element, Color.WHITE)
	add_child(projectile)
	projectile.speed_scale = maxf(battle_speed, 0.01)
	projectile.play()
	var travel := create_tween()
	travel.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	travel.tween_property(projectile, "position", _fighter_visual_center(target), 0.34 / maxf(battle_speed, 0.01))
	await travel.finished
	projectile.queue_free()


func _play_stone_golem_projectile(attacker: Fighter, target: Fighter) -> void:
	var projectile := TextureRect.new()
	projectile.texture = load("res://assets/boss/stone_golem/arm_projectile.png") as Texture2D
	projectile.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	projectile.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	projectile.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	projectile.size = Vector2(58, 58)
	projectile.position = _fighter_attack_origin(attacker) - projectile.size * 0.5
	projectile.z_index = 18
	add_child(projectile)
	var tween := create_tween()
	tween.tween_property(projectile, "position", _fighter_visual_center(target) - projectile.size * 0.5, 0.34 / maxf(battle_speed, 0.01))
	await tween.finished
	projectile.queue_free()


func _play_stone_golem_laser(attacker: Fighter, target: Fighter) -> void:
	var laser := TextureRect.new()
	laser.texture = load("res://assets/boss/stone_golem/laser_sheet.png") as Texture2D
	laser.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	laser.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	laser.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var start := _fighter_attack_origin(attacker)
	var target_pos := _fighter_visual_center(target)
	var distance := maxf(absf(target_pos.x - start.x), 120.0)
	laser.size = Vector2(distance, 86)
	laser.position = Vector2(start.x, start.y - 43.0)
	laser.scale.x = -1.0 if target_pos.x < start.x else 1.0
	laser.modulate = Color(0.72, 0.9, 1.0, 0.9)
	laser.z_index = 18
	add_child(laser)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(laser, "size:x", distance, 0.20 / maxf(battle_speed, 0.01))
	tween.tween_property(laser, "modulate:a", 0.15, 0.46 / maxf(battle_speed, 0.01))
	await tween.finished
	laser.queue_free()


func _play_stone_golem_melee(attacker: Fighter, target: Fighter) -> void:
	var start := attacker.sprite.position
	var direction := 1.0 if attacker.player_side else -1.0
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(attacker.sprite, "position:x", start.x + direction * 38.0, 0.12 / maxf(battle_speed, 0.01))
	tween.tween_property(attacker.sprite, "position:x", start.x, 0.18 / maxf(battle_speed, 0.01))
	await tween.finished
	var flash := _add_label("冲击", Rect2(_fighter_visual_center(target) - Vector2(42, 18), Vector2(84, 28)), 16, Color(0.85, 0.9, 1.0), HORIZONTAL_ALIGNMENT_CENTER, 24)
	var fade := create_tween()
	fade.tween_property(flash, "modulate:a", 0.0, 0.16 / maxf(battle_speed, 0.01))
	fade.tween_callback(flash.queue_free)


func _play_stone_golem_sequence(fighter: Fighter, first_frame: int, last_frame: int, delay: float) -> void:
	for frame in range(first_frame, last_frame + 1):
		if not is_instance_valid(fighter.sprite):
			return
		_set_stone_golem_frame(fighter, frame)
		await get_tree().create_timer(delay / maxf(battle_speed, 0.01)).timeout


func _play_hit_feedback(target: Fighter, damage: int) -> void:
	if not is_instance_valid(target.sprite):
		return
	var hit_tween := create_tween()
	hit_tween.tween_property(target.sprite, "modulate", Color(1.0, 0.25, 0.25), 0.08)
	hit_tween.tween_property(target.sprite, "modulate", Color.WHITE, 0.18)

	var damage_label := _add_label(str(damage), Rect2(target.sprite.position.x - 8, target.sprite.position.y - 18, 92, 42), 27, Color("ffd83d"), HORIZONTAL_ALIGNMENT_CENTER, 30)
	var bold_font := FontVariation.new()
	bold_font.base_font = source_han_font
	bold_font.variation_embolden = 0.85
	damage_label.add_theme_font_override("font", bold_font)
	damage_label.add_theme_color_override("font_color", Color("ffd83d"))
	damage_label.add_theme_color_override("font_outline_color", Color("111111"))
	damage_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.0))
	damage_label.add_theme_constant_override("outline_size", 4)
	damage_label.pivot_offset = damage_label.size * 0.5
	damage_label.scale = Vector2(0.72, 0.72)
	var playback_scale := maxf(battle_speed, 0.01)
	var pop_tween := create_tween()
	pop_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	pop_tween.tween_property(damage_label, "scale", Vector2(1.12, 1.12), 0.08 / playback_scale)
	pop_tween.tween_property(damage_label, "scale", Vector2.ONE, 0.04 / playback_scale)
	await pop_tween.finished
	if not is_instance_valid(damage_label):
		return
	var float_tween := create_tween().set_parallel(true)
	float_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	float_tween.tween_property(damage_label, "position:y", damage_label.position.y - 34, 1.04 / playback_scale)
	float_tween.tween_property(damage_label, "modulate:a", 0.0, 1.04 / playback_scale).set_delay(0.20 / playback_scale)
	float_tween.chain().tween_callback(damage_label.queue_free)

func _play_p7_projectile(attacker: Fighter, target: Fighter) -> void:
	var projectile := AnimatedSprite2D.new()
	projectile.sprite_frames = _get_p7_projectile_frames()
	projectile.animation = &"attack"
	projectile.centered = true
	projectile.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	projectile.flip_h = not attacker.player_side
	projectile.z_index = 18
	projectile.position = _fighter_attack_origin(attacker)
	add_child(projectile)

	var playback_scale := maxf(battle_speed, 0.01)
	projectile.speed_scale = playback_scale
	projectile.play()
	projectile.animation_finished.connect(projectile.queue_free, CONNECT_ONE_SHOT)

	# Frames 0-15 are the launch and flying orb; frames 16-21 are the impact.
	var travel_duration := float(P7_PROJECTILE_TRAVEL_FRAMES) / P7_PROJECTILE_FPS / playback_scale
	var travel_tween := create_tween()
	travel_tween.set_trans(Tween.TRANS_LINEAR)
	travel_tween.tween_property(projectile, "position", _fighter_visual_center(target), travel_duration)
	await travel_tween.finished


func _get_p7_projectile_frames() -> SpriteFrames:
	if p7_projectile_frames != null:
		return p7_projectile_frames
	p7_projectile_frames = SpriteFrames.new()
	p7_projectile_frames.remove_animation(&"default")
	p7_projectile_frames.add_animation(&"attack")
	p7_projectile_frames.set_animation_loop(&"attack", false)
	p7_projectile_frames.set_animation_speed(&"attack", P7_PROJECTILE_FPS)
	for frame_index in P7_PROJECTILE_FRAME_COUNT:
		var frame_texture := AtlasTexture.new()
		frame_texture.atlas = P7_PROJECTILE_SHEET
		frame_texture.region = Rect2i(
			frame_index * P7_PROJECTILE_FRAME_SIZE.x,
			0,
			P7_PROJECTILE_FRAME_SIZE.x,
			P7_PROJECTILE_FRAME_SIZE.y
		)
		p7_projectile_frames.add_frame(&"attack", frame_texture)
	return p7_projectile_frames


func _fighter_visual_center(fighter: Fighter) -> Vector2:
	return fighter.sprite.position + fighter.sprite.size * 0.5


func _fighter_attack_origin(fighter: Fighter) -> Vector2:
	var horizontal_ratio := 0.86 if fighter.player_side else 0.14
	return fighter.sprite.position + Vector2(fighter.sprite.size.x * horizontal_ratio, fighter.sprite.size.y * 0.48)


func _play_element_contact_vfx(attacker: Fighter, target: Fighter) -> void:
	var element := _fighter_element(attacker)
	var advanced := _uses_advanced_vfx(attacker)
	var config := _element_vfx_config(element, advanced)
	_play_vfx_config(config, target, advanced, TRAIT_VFX_COLORS.get(element, Color.WHITE))


func _play_vfx_config(config: Array, target: Fighter, advanced: bool, tint := Color.WHITE) -> void:
	var frames := _sprite_frames_from_vfx_config(config, advanced)
	if frames == null:
		return
	var effect := AnimatedSprite2D.new()
	effect.sprite_frames = frames
	effect.animation = &"effect"
	effect.position = _fighter_visual_center(target)
	effect.scale = Vector2.ONE * (2.2 if advanced else 1.55)
	effect.modulate = tint
	effect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	effect.z_index = 22
	effect.animation_finished.connect(effect.queue_free)
	add_child(effect)
	effect.play()


func _fighter_element(fighter: Fighter) -> String:
	for candidate in CATALOG.ELEMENTS:
		if fighter.traits.has(candidate):
			return candidate
	return ""


func _uses_advanced_vfx(fighter: Fighter) -> bool:
	var data: Dictionary = CATALOG.data_for_texture(fighter.texture_path)
	var rarity := CATALOG.rarity_for_texture(fighter.texture_path) if not data.is_empty() else 0
	return fighter.level >= 2 or rarity >= 3 or fighter.skill_id == "boss_quake"


func _element_vfx_config(element: String, advanced: bool) -> Array:
	var fallback := "res://assets/battle/vfx/hit_advanced.png" if advanced else "res://assets/battle/vfx/hit_basic.png"
	return ELEMENT_VFX.get(element, {}).get("advanced" if advanced else "basic", [fallback, Vector2i(48, 48), 7])


func _sprite_frames_from_vfx_config(config: Array, advanced: bool) -> SpriteFrames:
	var sheet := load(String(config[0])) as Texture2D
	var frame_size: Vector2i = config[1]
	var frame_count := int(config[2])
	if sheet == null or frame_size.x <= 0 or frame_size.y <= 0:
		return null
	var columns := maxi(sheet.get_width() / frame_size.x, 1)
	var available_frames := columns * maxi(sheet.get_height() / frame_size.y, 1)
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	frames.add_animation(&"effect")
	frames.set_animation_speed(&"effect", 18.0 if advanced else 15.0)
	frames.set_animation_loop(&"effect", false)
	for index in mini(frame_count, available_frames):
		var atlas := AtlasTexture.new()
		atlas.atlas = sheet
		atlas.region = Rect2i((index % columns) * frame_size.x, (index / columns) * frame_size.y, frame_size.x, frame_size.y)
		frames.add_frame(&"effect", atlas)
	return frames


func _process_synergy_timers(delta: float) -> void:
	var nature_tier := CATALOG.active_tier("自然", int(player_synergies.get("自然", 0)))
	if nature_tier >= 0:
		nature_heal_elapsed += delta
		if nature_heal_elapsed >= 3.5:
			nature_heal_elapsed = 0.0
			_heal_lowest_player(0.10)

	var plant_tier := CATALOG.active_tier("植物", int(player_synergies.get("植物", 0)))
	if plant_tier >= 0:
		plant_growth_elapsed += delta
		var growth_interval := 4.0 if plant_tier >= 1 else 5.0
		if plant_growth_elapsed >= growth_interval:
			plant_growth_elapsed = 0.0
			_grow_plants(plant_tier)

	burn_elapsed += delta
	if burn_elapsed >= 1.5:
		burn_elapsed = 0.0
		_tick_burning()

	if healing_zone_ticks > 0:
		healing_zone_elapsed += delta
		if healing_zone_elapsed >= 1.5:
			healing_zone_elapsed = 0.0
			healing_zone_ticks -= 1
			for ally in _living_fighters(true):
				_heal_fighter(ally, maxi(roundi(ally.max_hp * 0.06), 1))


func _apply_damage(target: Fighter, damage: int) -> int:
	if battle_elapsed <= 5.0:
		damage = roundi(damage * (1.0 - _equipment_effect_amount(target, "opening_reduction")))
	var remaining := maxi(damage, 0)
	var shield_before := target.shield
	var hp_before := target.hp
	var absorbed_total := 0
	if target.shield > 0:
		var absorbed := mini(target.shield, remaining)
		absorbed_total = absorbed
		target.shield -= absorbed
		remaining -= absorbed
	if remaining > 0:
		target.hp = maxi(target.hp - remaining, 0)
	if target.skill_id == "boss_quake" and not target.boss_phase_triggered and target.hp > 0 and target.hp * 2 <= target.max_hp:
		target.boss_phase_triggered = true
		target.shield += roundi(target.max_hp * 0.22)
		target.base_charge_rate *= 1.28
		target.charge_rate = target.base_charge_rate
		_show_effect_label("晶核护盾", target, Color(0.55, 0.92, 1.0))
		var phase_flash := create_tween()
		phase_flash.tween_property(target.sprite, "modulate", Color(0.8, 0.95, 1.0), 0.08)
		phase_flash.tween_property(target.sprite, "modulate", Color.WHITE, 0.18)
		_play_stone_golem_sequence(target, 60, 69, 0.07)
	_update_hp_label(target)
	if shield_before > 0 and target.shield <= 0 and target.mechanical_shock_ready:
		target.mechanical_shock_ready = false
		_mechanical_shockwave(target)
	if shield_before > 0 and target.shield <= 0 and target.player_side and target.traits.has("岩"):
		target.rock_armor_stacks = 0
		if CATALOG.active_tier("岩", int(player_synergies.get("岩", 0))) >= 2:
			_slow_enemies_from_rock_break(target)
	if remaining > 0 and target.alive and target.player_side and target.traits.has("岩") and CATALOG.active_tier("岩", int(player_synergies.get("岩", 0))) >= 1:
		var armor_piece := maxi(roundi(target.max_hp * 0.04), 1)
		if target.rock_armor_stacks < 3:
			target.rock_armor_stacks += 1
			target.shield += armor_piece
			_show_effect_label("岩甲 ×%d" % target.rock_armor_stacks, target, Color(0.76, 0.78, 0.82))
			_update_hp_label(target)
	if not target.equipment_low_hp_triggered and target.hp > 0 and target.hp * 2 <= target.max_hp:
		var shield_ratio := _equipment_effect_amount(target, "low_hp_shield")
		if shield_ratio > 0.0:
			target.equipment_low_hp_triggered = true
			_grant_skill_shield(target, target, shield_ratio)
	return absorbed_total + (hp_before - target.hp)


func _apply_control(target: Fighter, kind: String, duration: float) -> void:
	if target.status_immune:
		_show_effect_label("免疫", target, Color(0.8, 0.8, 0.8))
		return
	if not target.equipment_control_immunity_used and _equipment_effect_amount(target, "control_immunity") > 0.0:
		target.equipment_control_immunity_used = true
		_grant_skill_charge(target, _equipment_effect_amount(target, "control_immunity"))
		_show_effect_label("装备免疫", target, Color(0.68, 0.88, 1.0))
		return
	var actual_duration := duration * (1.0 - clampf(target.control_resistance, 0.0, 0.9))
	if kind == "stun":
		target.stun_remaining = maxf(target.stun_remaining, actual_duration)
	else:
		target.slow_remaining = maxf(target.slow_remaining, actual_duration)
	_update_status_icons(target)


func _heal_fighter(fighter: Fighter, amount: int) -> void:
	if not fighter.alive or amount <= 0:
		return
	var missing := maxi(fighter.max_hp - fighter.hp, 0)
	var restored := mini(missing, amount)
	fighter.hp += restored
	var overflow := amount - restored
	if overflow > 0 and fighter.player_side and CATALOG.active_tier("自然", int(player_synergies.get("自然", 0))) >= 1:
		fighter.shield = mini(fighter.shield + overflow, roundi(fighter.max_hp * 0.35))
	_update_hp_label(fighter)
	if restored > 0 or overflow > 0:
		_show_effect_label("+%d" % amount, fighter, Color(0.45, 1.0, 0.55))


func _heal_lowest_player(ratio: float) -> void:
	var living := _living_fighters(true)
	if living.is_empty():
		return
	var target: Fighter = living[0]
	var lowest_ratio := float(target.hp) / float(maxi(target.max_hp, 1))
	for fighter in living:
		var hp_ratio := float(fighter.hp) / float(maxi(fighter.max_hp, 1))
		if hp_ratio < lowest_ratio:
			target = fighter
			lowest_ratio = hp_ratio
	_heal_fighter(target, maxi(roundi(target.max_hp * ratio), 1))


func _grow_plants(tier: int) -> void:
	for fighter in _living_fighters(true):
		if not fighter.traits.has("植物"):
			continue
		var growth := maxi(roundi(fighter.max_hp * (0.06 if tier >= 1 else 0.04)), 1)
		fighter.max_hp += growth
		fighter.hp += growth
		if tier >= 1:
			fighter.damage_multiplier += 0.05
		_update_hp_label(fighter)
		_show_effect_label("生长", fighter, Color(0.62, 1.0, 0.35))


func _tick_burning() -> void:
	for fighter in fighters.duplicate():
		if not fighter.alive or fighter.burn_stacks <= 0:
			continue
		var burn_bonus := GameState.accessory_effect_total("burn_damage") if not fighter.player_side else 0.0
		var damage: int = roundi(int(fighter.burn_stacks) * 3 * (1.0 + burn_bonus))
		_apply_damage(fighter, damage)
		fighter.burn_remaining = maxf(fighter.burn_remaining - 1.5, 0.0)
		if fighter.burn_remaining <= 0.0:
			fighter.burn_stacks = 0
		_show_effect_label("燃烧 -%d" % damage, fighter, Color(1.0, 0.42, 0.12))
		if fighter.hp <= 0:
			_defeat_fighter(fighter)
	_check_battle_end()


func _apply_fire_attack(attacker: Fighter, target: Fighter) -> void:
	if not attacker.player_side or not attacker.traits.has("火"):
		return
	var tier := CATALOG.active_tier("火", int(player_synergies.get("火", 0)))
	if tier < 0 or rng.randf() >= 0.35:
		return
	var max_stacks := 3 if tier >= 1 else 1
	target.burn_stacks = mini(target.burn_stacks + 1, max_stacks)
	target.burn_remaining = 4.5
	_show_effect_label("点燃 ×%d" % target.burn_stacks, target, Color(1.0, 0.48, 0.12))


func _apply_lightning_attack(attacker: Fighter, primary_target: Fighter, base_damage: int) -> void:
	if not attacker.player_side or not attacker.traits.has("雷"):
		return
	var tier := CATALOG.active_tier("雷", int(player_synergies.get("雷", 0)))
	if tier < 0:
		return
	if rng.randf() < 0.35:
		var candidates := _living_fighters(false)
		candidates.erase(primary_target)
		var chain_count := 2 if tier >= 1 else 1
		for index in mini(chain_count, candidates.size()):
			var pick := rng.randi_range(0, candidates.size() - 1)
			var chained: Fighter = candidates.pop_at(pick)
			_damage_secondary(chained, maxi(roundi(base_damage * 0.55), 1), Color(0.45, 0.75, 1.0), "连锁")
	if tier >= 2:
		for enemy in _living_fighters(false).duplicate():
			_damage_secondary(enemy, 4, Color(0.68, 0.55, 1.0), "落雷")


func _damage_secondary(target: Fighter, damage: int, color: Color, effect_name: String) -> void:
	if not target.alive:
		return
	_apply_damage(target, damage)
	_play_hit_feedback(target, damage)
	_show_effect_label("%s -%d" % [effect_name, damage], target, color)
	if target.hp <= 0:
		_defeat_fighter(target)


func _mechanical_shockwave(source: Fighter) -> void:
	if not source.player_side:
		return
	_show_effect_label("冲击波", source, Color(0.78, 0.86, 1.0))
	for enemy in _living_fighters(false).duplicate():
		_damage_secondary(enemy, 6, Color(0.72, 0.82, 1.0), "冲击")


func _mechanical_team_speed_bonus() -> float:
	if CATALOG.active_tier("机械", int(player_synergies.get("机械", 0))) < 2:
		return 0.0
	var alive_mechanical := 0
	for fighter in _living_fighters(true):
		if fighter.traits.has("机械"):
			alive_mechanical += 1
	return alive_mechanical * 0.08


func _insect_team_speed_bonus() -> float:
	if CATALOG.active_tier("虫群", int(player_synergies.get("虫群", 0))) < 2:
		return 0.0
	var alive_insects := 0
	for fighter in _living_fighters(true):
		if fighter.traits.has("虫群"):
			alive_insects += 1
	return alive_insects * 0.05


func _charge_other_insects(attacker: Fighter) -> void:
	if not attacker.player_side or not attacker.traits.has("虫群") or CATALOG.active_tier("虫群", int(player_synergies.get("虫群", 0))) < 1:
		return
	for ally in _living_fighters(true):
		if ally != attacker and ally.traits.has("虫群"):
			ally.charge = minf(ally.charge + 0.14, 1.0)
			_update_charge_bar(ally)


func _apply_dragon_splash(attacker: Fighter, primary_target: Fighter, base_damage: int) -> void:
	if not attacker.player_side or not attacker.traits.has("龙族") or CATALOG.active_tier("龙族", int(player_synergies.get("龙族", 0))) < 1:
		return
	var candidates := _living_fighters(false)
	candidates.erase(primary_target)
	if candidates.is_empty():
		return
	var target: Fighter = candidates[rng.randi_range(0, candidates.size() - 1)]
	_damage_secondary(target, maxi(roundi(base_damage * 0.45), 1), Color(0.72, 0.48, 1.0), "龙息")


func _slow_enemies_from_rock_break(source: Fighter) -> void:
	_show_effect_label("岩甲震荡", source, Color(0.78, 0.80, 0.86))
	for enemy in _living_fighters(false):
		enemy.base_charge_rate = maxf(enemy.base_charge_rate * 0.88, 0.08)
		_show_effect_label("减速", enemy, Color(0.68, 0.72, 0.80))


func _heal_other_undead(source: Fighter) -> void:
	for ally in _living_fighters(true):
		if ally != source and ally.traits.has("灵体"):
			_heal_fighter(ally, maxi(roundi(ally.max_hp * 0.14), 1))


func _fire_death_explosion(source: Fighter, stacks: int) -> void:
	for enemy in _living_fighters(false).duplicate():
		if enemy == source:
			continue
		_damage_secondary(enemy, maxi(stacks * 7, 1), Color(1.0, 0.3, 0.08), "爆炸")


func _spawn_healing_zone_visual(fighter: Fighter) -> void:
	var zone := ColorRect.new()
	zone.position = fighter.sprite.position + Vector2(-12, 54)
	zone.size = Vector2(100, 12)
	zone.color = Color(0.3, 1.0, 0.45, 0.58)
	zone.z_index = 9
	zone.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(zone)
	var fade := create_tween()
	fade.tween_property(zone, "modulate:a", 0.0, 4.5)
	fade.tween_callback(zone.queue_free)


func _show_effect_label(text: String, fighter: Fighter, color: Color) -> void:
	var label := _add_label(text, Rect2(fighter.sprite.position.x - 12, fighter.sprite.position.y - 18, 100, 24), 13, color, HORIZONTAL_ALIGNMENT_CENTER, 32)
	label.add_theme_color_override("font_color", color)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 24, 0.7)
	tween.tween_property(label, "modulate:a", 0.0, 0.7)
	tween.chain().tween_callback(label.queue_free)


func _play_critical_icon(target: Fighter) -> void:
	if target == null or not is_instance_valid(target.sprite):
		return
	var icon := TextureRect.new()
	icon.position = target.sprite.position + Vector2(30, -34)
	icon.size = Vector2(54, 54)
	icon.pivot_offset = icon.size * 0.5
	icon.texture = BATTLE_CRITICAL_ICON
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.z_index = 42
	icon.scale = Vector2(0.45, 0.45)
	add_child(icon)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(icon, "scale", Vector2.ONE, 0.11).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(icon, "position:y", icon.position.y - 12.0, 0.38)
	tween.tween_property(icon, "modulate:a", 0.0, 0.38).set_delay(0.14)
	tween.chain().tween_callback(icon.queue_free)


func _update_hp_label(fighter: Fighter) -> void:
	if fighter.hp_label == null:
		return
	fighter.hp_label.text = "%d/%d  ◆%d" % [fighter.hp, fighter.max_hp, fighter.shield] if fighter.shield > 0 else "%d/%d" % [fighter.hp, fighter.max_hp]
	_update_status_icons(fighter)


func _update_status_icons(fighter: Fighter) -> void:
	if fighter.status_row == null:
		return
	for child in fighter.status_row.get_children():
		child.queue_free()
	if fighter.shield > 0:
		fighter.status_row.add_child(_status_icon(0, "护盾 %d" % fighter.shield, BATTLE_SHIELD_ICON))
	if fighter.burn_stacks > 0:
		fighter.status_row.add_child(_status_icon(9, "燃烧 %d" % fighter.burn_stacks))
	if fighter.slow_remaining > 0.0:
		fighter.status_row.add_child(_status_icon(18, "减速 %.1fs" % fighter.slow_remaining))
	if fighter.stun_remaining > 0.0:
		fighter.status_row.add_child(_status_icon(19, "眩晕 %.1fs" % fighter.stun_remaining))
	if fighter.crit_chance > 0.05:
		fighter.status_row.add_child(_status_icon(20, "暴击率 %d%%" % roundi(fighter.crit_chance * 100.0)))
	if fighter.dodge_chance > 0.0:
		fighter.status_row.add_child(_status_icon(21, "闪避率 %d%%" % roundi(fighter.dodge_chance * 100.0)))
	if fighter.control_resistance > 0.0:
		fighter.status_row.add_child(_status_icon(22, "控制抗性 %d%%" % roundi(fighter.control_resistance * 100.0)))
	if fighter.revived_as_seedling or fighter.revived_as_spirit:
		fighter.status_row.add_child(_status_icon(26, "复活状态"))


func _status_icon(index: int, description: String, custom_texture: Texture2D = null) -> Control:
	var display_texture: Texture2D = custom_texture
	if display_texture == null:
		var atlas := AtlasTexture.new()
		atlas.atlas = STATUS_ICON_SHEET
		atlas.region = Rect2i(
			(index % 8) * STATUS_ICON_SIZE.x,
			(index / 8) * STATUS_ICON_SIZE.y,
			STATUS_ICON_SIZE.x,
			STATUS_ICON_SIZE.y,
		)
		display_texture = atlas
	var root := Control.new()
	root.custom_minimum_size = Vector2(18, 18)
	root.tooltip_text = ""
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	root.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	root.gui_input.connect(_on_status_icon_input.bind(description))
	var icon := TextureRect.new()
	root.add_child(icon)
	icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	icon.custom_minimum_size = Vector2(16, 16)
	icon.texture = display_texture
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var value_text := description.get_slice(" ", 1)
	if not value_text.is_empty():
		var amount := Label.new()
		amount.position = Vector2(8, 7)
		amount.size = Vector2(12, 11)
		amount.text = value_text.trim_suffix("s")
		amount.add_theme_font_override("font", source_han_font)
		amount.add_theme_font_size_override("font_size", 8)
		amount.add_theme_color_override("font_color", Color.WHITE)
		amount.add_theme_color_override("font_outline_color", Color.BLACK)
		amount.add_theme_constant_override("outline_size", 2)
		amount.mouse_filter = Control.MOUSE_FILTER_IGNORE
		root.add_child(amount)
	return root


func _on_status_icon_input(event: InputEvent, description: String) -> void:
	if not event is InputEventMouseButton:
		return
	var mouse_event := event as InputEventMouseButton
	if mouse_event.button_index != MOUSE_BUTTON_RIGHT or not mouse_event.pressed:
		return
	get_viewport().set_input_as_handled()
	_show_status_info(description)


func _show_status_info(description: String) -> void:
	if is_instance_valid(status_info_panel):
		status_info_panel.queue_free()
	status_info_panel = Panel.new()
	status_info_panel.size = Vector2(330, 112)
	var local_mouse := get_global_transform_with_canvas().affine_inverse() * get_viewport().get_mouse_position()
	status_info_panel.position = Vector2(clampf(local_mouse.x - 165.0, 10.0, DESIGN_SIZE.x - 340.0), clampf(local_mouse.y + 12.0, 10.0, DESIGN_SIZE.y - 122.0))
	status_info_panel.z_index = 180
	status_info_panel.add_theme_stylebox_override("panel", _preset_info_style())
	add_child(status_info_panel)
	var title := description.get_slice(" ", 0)
	var detail := _status_detail_text(description)
	var title_label := _add_info_label(status_info_panel, title, Rect2(20, 10, 290, 26), 17, Color("252b35"))
	var body := _add_info_label(status_info_panel, detail, Rect2(20, 38, 290, 60), 12, Color("596275"))
	_disable_info_shadow(title_label)
	_disable_info_shadow(body)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART


func _hide_status_info() -> void:
	if is_instance_valid(status_info_panel):
		status_info_panel.queue_free()
	status_info_panel = null


func _status_detail_text(description: String) -> String:
	if description.begins_with("护盾"):
		return "优先吸收即将受到的伤害；右侧数值为当前剩余护盾。"
	if description.begins_with("燃烧"):
		return "持续造成伤害，可叠加；数值表示当前层数。"
	if description.begins_with("减速"):
		return "降低普通攻击速度；数值表示剩余持续时间。"
	if description.begins_with("眩晕"):
		return "期间无法攻击或释放技能；数值表示剩余持续时间。"
	if description.begins_with("暴击率"):
		return "攻击触发暴击时造成更高伤害；数值为当前概率。"
	if description.begins_with("闪避率"):
		return "有概率完全避开一次攻击；数值为当前概率。"
	if description.begins_with("控制抗性"):
		return "缩短减速、眩晕等硬控的持续时间。"
	return "该单位已经触发一次复活效果，本场战斗不能再次触发。"


func _defeat_fighter(fighter: Fighter) -> void:
	if not fighter.alive:
		return
	if not fighter.equipment_revive_used:
		var revive_ratio := _equipment_effect_amount(fighter, "revive")
		if revive_ratio > 0.0:
			fighter.equipment_revive_used = true
			fighter.hp = maxi(roundi(fighter.max_hp * revive_ratio), 1)
			fighter.charge = 0.0
			_update_hp_label(fighter)
			_update_charge_bar(fighter)
			_show_effect_label("复苏", fighter, Color(0.72, 1.0, 0.68))
			return
	if fighter.player_side and fighter.traits.has("灵体"):
		var undead_tier := CATALOG.active_tier("灵体", int(player_synergies.get("灵体", 0)))
		if undead_tier >= 1:
			_heal_other_undead(fighter)
		if undead_tier >= 2 and not fighter.revived_as_spirit:
			fighter.revived_as_spirit = true
			var revive_bonus := GameState.accessory_effect_total("revive_power")
			fighter.hp = maxi(roundi(fighter.max_hp * (0.30 + revive_bonus)), 1)
			fighter.charge = 0.35
			fighter.damage_multiplier *= 0.82
			fighter.sprite.modulate = Color(0.68, 0.62, 0.92, 0.88)
			_update_hp_label(fighter)
			_update_charge_bar(fighter)
			status_label.text = "灵体羁绊触发：单位以灵魂形态复活"
			return
	if fighter.player_side and fighter.traits.has("植物") and not fighter.revived_as_seedling and CATALOG.active_tier("植物", int(player_synergies.get("植物", 0))) >= 2:
		fighter.revived_as_seedling = true
		var seedling_bonus := GameState.accessory_effect_total("revive_power")
		fighter.hp = maxi(roundi(fighter.max_hp * (0.35 + seedling_bonus)), 1)
		fighter.charge = 0.0
		fighter.damage_multiplier *= 0.72
		fighter.sprite.modulate = Color(0.58, 1.0, 0.48, 1.0)
		fighter.sprite.scale = fighter.base_scale * 0.76
		_update_hp_label(fighter)
		_update_charge_bar(fighter)
		status_label.text = "植物羁绊触发：单位以幼苗状态复活"
		return
	fighter.alive = false
	fighter.charge = 0.0
	_update_charge_bar(fighter)
	fighter.charge_frame.modulate = Color(0.35, 0.35, 0.35, 0.55)
	fighter.hp_label.modulate = Color(0.5, 0.5, 0.5, 0.7)
	if fighter.skill_id == "boss_quake":
		_play_stone_golem_death(fighter)
		return
	var fall := create_tween().set_parallel(true)
	fall.tween_property(fighter.sprite, "modulate:a", 0.28, 0.35)
	fall.tween_property(fighter.sprite, "scale", fighter.base_scale * 0.72, 0.35)
	if fighter.player_side and fighter.traits.has("自然") and CATALOG.active_tier("自然", int(player_synergies.get("自然", 0))) >= 2:
		healing_zone_ticks += 3
		_spawn_healing_zone_visual(fighter)
	if not fighter.player_side and fighter.burn_stacks > 0 and CATALOG.active_tier("火", int(player_synergies.get("火", 0))) >= 2:
		var explosion_stacks := fighter.burn_stacks
		fighter.burn_stacks = 0
		_fire_death_explosion(fighter, explosion_stacks)


func _play_stone_golem_death(fighter: Fighter) -> void:
	await _play_stone_golem_sequence(fighter, 70, 83, 0.085)
	if not is_instance_valid(fighter.sprite):
		return
	var fade := create_tween().set_parallel(true)
	fade.tween_property(fighter.sprite, "modulate:a", 0.0, 0.4)
	fade.tween_property(fighter.sprite, "position:y", fighter.sprite.position.y + 22.0, 0.4)


func _update_charge_bar(fighter: Fighter) -> void:
	var fill_height := 58.0 * fighter.charge
	fighter.charge_fill.position.y = 61.0 - fill_height
	fighter.charge_fill.size.y = fill_height


func _living_fighters(player_side: bool) -> Array[Fighter]:
	var living: Array[Fighter] = []
	for fighter in fighters:
		if fighter.player_side == player_side and fighter.alive:
			living.append(fighter)
	return living


func _check_battle_end() -> void:
	if _living_fighters(false).is_empty():
		_finish_battle(true)
	elif _living_fighters(true).is_empty():
		_finish_battle(false)


func _finish_battle(player_won: bool) -> void:
	if battle_over:
		return
	battle_over = true
	if player_won:
		var first_battle_victory := _is_first_battle_node()
		for defeated in fighters:
			if not defeated.player_side and defeated.texture_path != MIMIC_TEXTURE:
				GameState.mark_creature_defeated(defeated.texture_path)
		for team_index in GameState.player_team.size():
			var texture_path := GameState.player_team[team_index]
			if not texture_path.is_empty():
				var level := GameState.player_team_levels[team_index] if team_index < GameState.player_team_levels.size() else 1
				GameState.mark_creature_owned(texture_path, level)
				GameState.mark_creature_win(texture_path)
		var node_type := GameState.current_map_node_type() if GameState.map_initialized else "battle"
		var gold_reward := GameState.battle_gold_breakdown(node_type)
		GameState.add_coins(int(gold_reward["total"]))
		result_gold_reward = int(gold_reward["total"])
		victory_reward_text = "+%d（基础 %d" % [int(gold_reward["total"]), int(gold_reward["base"])]
		if int(gold_reward["node_bonus"]) > 0:
			victory_reward_text += "，节点 +%d" % int(gold_reward["node_bonus"])
		if int(gold_reward["accessory_gold"]) > 0:
			victory_reward_text += "，饰品 +%d" % int(gold_reward["accessory_gold"])
		victory_reward_text += "，利息 +%d）" % int(gold_reward["interest"])
		GameState.battle_victories += 1
		if GameState.battle_victories % 3 == 0:
			_grant_battle_streak_item()
			result_reward_sources.append("三战奖励")
		if GameState.map_initialized:
			GameState.complete_current_map_node()
			if first_battle_victory:
				_grant_first_battle_chest()
				result_reward_sources.append("宝箱奖励")
			elif _is_mimic_battle():
				_grant_mimic_chest_reward()
				result_reward_sources.append("宝箱奖励")
	else:
		GameState.lose_run_life()
		if GameState.run_lives > 0 and GameState.map_initialized:
			# A lost encounter still consumes the route node. Hearts are the run's
			# failure budget; the player continues forward instead of replaying it.
			var loss_reward := GameState.battle_gold_breakdown("battle")
			var loss_gold := int(loss_reward["base"]) + int(loss_reward["interest"])
			GameState.add_coins(loss_gold)
			victory_reward_text = "失去 1 颗心 · 剩余生命：%d\n战败补给：+%d（基础 %d，利息 +%d）" % [GameState.run_lives, loss_gold, int(loss_reward["base"]), int(loss_reward["interest"])]
			GameState.complete_current_map_node()
		elif GameState.run_lives <= 0:
			victory_reward_text = "远征止步于区域 %d · 第 %d 层\n完成战斗：%d · 最终金币：%d" % [GameState.region, GameState.floor, GameState.battle_victories, GameState.coins]
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0, 0, 0, 0.7)
	shade.z_index = 100
	add_child(shade)
	_add_label("胜 利" if player_won else "战斗失败", Rect2(390, 245, 500, 80), 38, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, 110)
	if not victory_reward_text.is_empty():
		if result_gold_reward > 0:
			var text_width := ceilf(source_han_font.get_string_size(victory_reward_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 15).x)
			var reward_row_width := 28.0 + 10.0 + text_width
			var reward_row_x := floorf((DESIGN_SIZE.x - reward_row_width) * 0.5)
			_create_result_coin_icon(Vector2(reward_row_x, 330))
			var gold_label := _add_label(victory_reward_text, Rect2(reward_row_x + 38.0, 315, text_width + 4.0, 58), 15, Color("ffd159"), HORIZONTAL_ALIGNMENT_LEFT, 110)
			gold_label.name = "ResultGoldText"
			_create_result_gold_hitbox(Rect2(reward_row_x - 5.0, 315, reward_row_width + 10.0, 58))
		else:
			_add_label(victory_reward_text, Rect2(300, 315, 680, 58), 15, Color("ffd159"), HORIZONTAL_ALIGNMENT_CENTER, 110)
	if not result_reward_sources.is_empty():
		var source_label := _add_label("    ".join(result_reward_sources), Rect2(390, 362, 500, 34), 15, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, 110)
		source_label.name = "ResultRewardSources"
	var reward_gap := 15.0
	var reward_width := result_item_rewards.size() * 140.0 + maxi(result_item_rewards.size() - 1, 0) * reward_gap
	var reward_start_x := floorf((DESIGN_SIZE.x - reward_width) * 0.5)
	for reward_index in result_item_rewards.size():
		_create_result_item_card(result_item_rewards[reward_index], Vector2(reward_start_x + reward_index * (140.0 + reward_gap), 398))
	var result_button_y := 535.0 if not result_item_rewards.is_empty() else (405.0 if not victory_reward_text.is_empty() else 350.0)
	if player_won and not GameState.map_initialized:
		var retry := _create_result_button("重新战斗", Vector2(435, result_button_y))
		retry.pressed.connect(_restart_battle)
	elif not player_won:
		if GameState.run_lives <= 0:
			var failed_run := _create_result_button("远征结束", Vector2(545, result_button_y))
			failed_run.pressed.connect(_return_to_main_after_defeat)
			return
		var continue_run := _create_result_button("继续远征", Vector2(545, result_button_y))
		continue_run.pressed.connect(_back_to_prep)
		return
	var back_position := Vector2(545, result_button_y) if player_won and GameState.map_initialized else Vector2(655, result_button_y)
	var back := _create_result_button("返回地图" if GameState.map_initialized else "返回备战", back_position)
	back.pressed.connect(_back_to_prep)


func _grant_first_battle_chest() -> String:
	var reward_rng := RandomNumberGenerator.new()
	reward_rng.seed = GameState.map_seed + 17041
	var first_entry := ITEM_CATALOG.random_entry("item", reward_rng, -1, "chest")
	var second_entry := ITEM_CATALOG.random_entry("item", reward_rng, -1, "chest")
	var reroll_attempts := 0
	while int(second_entry.get("id", 0)) == int(first_entry.get("id", 0)) and reroll_attempts < 8:
		second_entry = ITEM_CATALOG.random_entry("item", reward_rng, -1, "chest")
		reroll_attempts += 1
	GameState.add_item(first_entry)
	GameState.add_item(second_entry)
	result_item_rewards.append(first_entry)
	result_item_rewards.append(second_entry)
	var coin_reward := GameState.FIRST_BATTLE_CHEST_GOLD
	GameState.add_coins(coin_reward)
	return "获得开局宝箱：%s、%s，金币 +%d" % [String(first_entry["name"]), String(second_entry["name"]), coin_reward]


func _grant_mimic_chest_reward() -> String:
	var reward_rng := RandomNumberGenerator.new()
	reward_rng.seed = GameState.map_seed + GameState.current_map_node * 3571 + GameState.floor * 101
	var chest_roll := reward_rng.randi_range(0, 9)
	if chest_roll < 4:
		var gold_range := GameState.chest_gold_range()
		var gold := reward_rng.randi_range(gold_range.x, gold_range.y)
		GameState.add_coins(gold)
		return "宝箱奖励：金币 +%d" % gold
	if chest_roll < 8:
		var roll := reward_rng.randf()
		var kind := "equipment" if roll < 0.30 else ("accessory" if roll < 0.55 else "item")
		var entry := EQUIPMENT_CATALOG.random_entry(reward_rng, -1, "chest") if kind == "equipment" else ITEM_CATALOG.random_entry(kind, reward_rng, -1, "chest")
		return "宝箱奖励：%s" % _store_item_reward(entry, kind)
	var textures: Array[String] = []
	for texture_path in CATALOG.all_textures():
		if int(GameState.creature_shop_pool.get(texture_path, 0)) > 0:
			textures.append(texture_path)
	if textures.is_empty():
		GameState.add_coins(5)
		return "宝箱奖励：共享角色池已空，金币 +5"
	var texture_path: String = textures[reward_rng.randi_range(0, textures.size() - 1)]
	if GameState.add_creature_reward(texture_path):
		GameState.take_creature_from_pool(texture_path)
		GameState.mark_creature_seen(texture_path)
		return "宝箱奖励：%s加入备战席" % CATALOG.name_for_texture(texture_path)
	var rarity := CATALOG.rarity_for_texture(texture_path)
	var sell_value := GameState.creature_sell_value(rarity, 1)
	GameState.add_coins(sell_value)
	return "宝箱奖励：队伍已满，角色转化为金币 +%d" % sell_value


func _grant_battle_streak_item() -> String:
	var reward_rng := RandomNumberGenerator.new()
	reward_rng.seed = GameState.map_seed + GameState.battle_victories * 7919 + GameState.current_map_node * 101
	var node_type := GameState.current_map_node_type() if GameState.map_initialized else "battle"
	var source := node_type if node_type in ["elite", "boss"] else "battle"
	var kind := "equipment" if node_type in ["elite", "boss"] else "item"
	var entry := EQUIPMENT_CATALOG.random_entry(reward_rng, -1, source) if kind == "equipment" else ITEM_CATALOG.random_entry("item", reward_rng, -1, source)
	return _store_item_reward(entry, kind)


func _store_item_reward(entry: Dictionary, kind: String) -> String:
	var stored := GameState.add_equipment(entry) if kind == "equipment" else (GameState.add_accessory(entry) if kind == "accessory" else GameState.add_item(entry))
	if not stored.is_empty():
		result_item_rewards.append(entry)
		return String(entry["name"])
	var conversion := int(entry.get("sell_price", 1))
	GameState.add_coins(conversion)
	return "%s（达到上限，转化为 %d 金币）" % [String(entry["name"]), conversion]


func _create_result_item_card(entry: Dictionary, position: Vector2) -> void:
	var rarity := clampi(int(entry.get("rarity", 0)), 0, 2)
	var rarity_colors := [Color("b8bdc5"), Color("3e95d8"), Color("c45ad9")]
	var card := Panel.new()
	card.name = "ResultItemCard"
	card.position = position
	card.size = Vector2(140, 118)
	card.z_index = 112
	card.add_theme_stylebox_override("panel", _panel_style(Color("171925"), rarity_colors[rarity], 3))
	add_child(card)
	var icon := TextureRect.new()
	icon.position = Vector2(34, 8)
	icon.size = Vector2(72, 72)
	icon.texture = load(String(entry.get("path", ""))) as Texture2D
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(icon)
	var name_label := _add_info_label(card, String(entry.get("name", "未知道具")), Rect2(8, 82, 124, 28), 12, rarity_colors[rarity], HORIZONTAL_ALIGNMENT_CENTER)
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART


func _create_result_coin_icon(position: Vector2) -> void:
	var coin := TextureRect.new()
	coin.name = "ResultCoinIcon"
	coin.position = position
	coin.size = Vector2(28, 28)
	coin.texture = RESULT_COIN_ICON
	coin.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	coin.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	coin.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	coin.z_index = 112
	coin.tooltip_text = ""
	coin.mouse_filter = Control.MOUSE_FILTER_STOP
	coin.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	coin.gui_input.connect(_on_result_coin_input)
	add_child(coin)


func _on_result_coin_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		_show_result_gold_info()
		get_viewport().set_input_as_handled()


func _create_result_gold_hitbox(rect: Rect2) -> void:
	var hitbox := Control.new()
	hitbox.name = "ResultGoldHitbox"
	hitbox.position = rect.position
	hitbox.size = rect.size
	hitbox.z_index = 113
	hitbox.mouse_filter = Control.MOUSE_FILTER_STOP
	hitbox.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	hitbox.gui_input.connect(_on_result_coin_input)
	add_child(hitbox)


func _show_result_gold_info() -> void:
	_hide_result_gold_info()
	result_gold_info_panel = Panel.new()
	result_gold_info_panel.position = Vector2(430, 356)
	result_gold_info_panel.size = Vector2(420, 112)
	result_gold_info_panel.z_index = 125
	result_gold_info_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	result_gold_info_panel.add_theme_stylebox_override("panel", _preset_info_style())
	add_child(result_gold_info_panel)
	var result_title := _add_info_label(result_gold_info_panel, "金币奖励明细", Rect2(22, 10, 376, 30), 18, Color("252b35"), HORIZONTAL_ALIGNMENT_CENTER)
	var detail := victory_reward_text.trim_prefix("+%d" % result_gold_reward).strip_edges()
	var body := _add_info_label(result_gold_info_panel, "本次获得 %d 金币  %s" % [result_gold_reward, detail], Rect2(24, 44, 372, 48), 14, Color("596275"), HORIZONTAL_ALIGNMENT_CENTER)
	_disable_info_shadow(result_title)
	_disable_info_shadow(body)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART


func _hide_result_gold_info() -> void:
	if is_instance_valid(result_gold_info_panel):
		result_gold_info_panel.queue_free()
	result_gold_info_panel = null


func _create_result_button(text: String, position: Vector2) -> Button:
	var button := Button.new()
	button.position = position
	button.size = Vector2(190, 52)
	button.text = text
	button.add_theme_font_override("font", source_han_font)
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_outline_color", Color.BLACK)
	button.add_theme_constant_override("outline_size", 1)
	var normal := StyleBoxTexture.new()
	normal.texture = MENU_BUTTON_NORMAL
	var pressed := StyleBoxTexture.new()
	pressed.texture = MENU_BUTTON_PRESSED
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", normal)
	button.add_theme_stylebox_override("pressed", pressed)
	button.z_index = 110
	add_child(button)
	return button


func _play_transition_in() -> void:
	var curtain := ColorRect.new()
	curtain.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	curtain.color = Color.BLACK
	curtain.z_index = 200
	curtain.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(curtain)
	var reveal := create_tween()
	reveal.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	reveal.tween_interval(0.12)
	reveal.tween_property(curtain, "color:a", 0.0, 0.65)
	reveal.tween_callback(curtain.queue_free)


func _restart_battle() -> void:
	SceneManager.reload_scene()


func _back_to_prep() -> void:
	SceneManager.change_scene("res://map.tscn" if GameState.map_initialized else "res://battle_prep.tscn")


func _return_to_main_after_defeat() -> void:
	GameState.reset_run()
	GameState.has_started_new_game = false
	GameState.clear_run_save()
	SceneManager.change_scene("res://main.tscn")


func _add_texture(path: String, rect: Rect2, z: int, stretch := TextureRect.STRETCH_KEEP_ASPECT_CENTERED) -> TextureRect:
	var node := TextureRect.new()
	node.position = rect.position
	node.size = rect.size
	node.texture = load(path) as Texture2D
	node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	node.stretch_mode = stretch
	node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.z_index = z
	add_child(node)
	return node


func _add_label(text: String, rect: Rect2, font_size: int, _color: Color, alignment: HorizontalAlignment, z: int) -> Label:
	var label := Label.new()
	label.position = rect.position
	label.size = rect.size
	label.text = text
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", source_han_font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 1)
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.z_index = z
	add_child(label)
	return label


func _add_info_label(parent: Control, text: String, rect: Rect2, font_size: int, color: Color, alignment := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := Label.new()
	label.position = rect.position
	label.size = rect.size
	label.text = text
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", source_han_font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 1)
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label


func _add_detail_texture(parent: Control, rect: Rect2) -> TextureRect:
	var texture_rect := TextureRect.new()
	texture_rect.position = rect.position
	texture_rect.size = rect.size
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(texture_rect)
	return texture_rect


func _disable_info_shadow(label: Label) -> void:
	label.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	label.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
	label.add_theme_constant_override("outline_size", 0)
	label.add_theme_constant_override("shadow_offset_x", 0)
	label.add_theme_constant_override("shadow_offset_y", 0)


func _rounded_style(fill: Color, border: Color, width: int, radius: int) -> StyleBoxFlat:
	var style := _panel_style(fill, border, width)
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	return style


func _make_fighter_detail_background(rarity_color: Color, trait_color: Color) -> GradientTexture2D:
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.42, 1.0])
	gradient.colors = PackedColorArray([rarity_color.lightened(0.80), trait_color.lightened(0.76), Color("f7f8fb")])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = 64
	texture.height = 64
	texture.fill = GradientTexture2D.FILL_LINEAR
	texture.fill_from = Vector2(0.0, 0.0)
	texture.fill_to = Vector2(1.0, 1.0)
	return texture


func _preset_info_style() -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = PRESET_INFO_FRAME
	style.texture_margin_left = 20.0
	style.texture_margin_top = 18.0
	style.texture_margin_right = 20.0
	style.texture_margin_bottom = 20.0
	style.content_margin_left = 18.0
	style.content_margin_top = 14.0
	style.content_margin_right = 18.0
	style.content_margin_bottom = 16.0
	style.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
	style.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
	return style


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
