extends Control

class Fighter:
	var sprite: TextureRect
	var charge_frame: Panel
	var charge_fill: ColorRect
	var hp_label: Label
	var hp: int
	var max_hp: int
	var charge := 0.0
	var charge_rate: float
	var base_charge_rate: float
	var player_side: bool
	var alive := true
	var home_position: Vector2
	var base_scale := Vector2.ONE
	var traits := PackedStringArray()
	var damage_multiplier := 1.0
	var damage_reduction := 0.0
	var heal_on_cast := 0.0
	var shield := 0
	var burn_stacks := 0
	var revived_as_seedling := false
	var revived_as_spirit := false
	var mechanical_shock_ready := false
	var rock_armor_stacks := 0


const SOURCE_HAN_FONT: FontFile = preload("res://assets/fonts/SourceHanSansSC-Heavy.otf")
const CATALOG = preload("res://scripts/creature_catalog.gd")
const DESIGN_SIZE := Vector2(1280, 720)
const FULL_HD_SCALE := Vector2(1.5, 1.5)
const SCENE_ASSETS := "res://素材/场景/"
const POKEMON := "res://素材/宝可梦图/"
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


func _ready() -> void:
	_apply_full_hd_layout()
	rng.randomize()
	source_han_font = SOURCE_HAN_FONT.duplicate() as FontFile
	source_han_font.antialiasing = TextServer.FONT_ANTIALIASING_GRAY
	source_han_font.hinting = TextServer.HINTING_NORMAL
	source_han_font.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	source_han_font.oversampling = FULL_HD_SCALE.x
	source_han_font.allow_system_fallback = false
	_build_battlefield()
	_play_transition_in.call_deferred()


func _apply_full_hd_layout() -> void:
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	position = Vector2.ZERO
	size = DESIGN_SIZE
	scale = FULL_HD_SCALE


func _process(delta: float) -> void:
	if battle_over:
		return
	_process_synergy_timers(delta)
	var team_speed_bonus := _mechanical_team_speed_bonus() + _insect_team_speed_bonus()
	for fighter in fighters:
		if not fighter.alive:
			continue
		var current_charge_rate := fighter.base_charge_rate
		if fighter.player_side:
			current_charge_rate *= 1.0 + team_speed_bonus
		fighter.charge = minf(fighter.charge + delta * current_charge_rate, 1.0)
		_update_charge_bar(fighter)
		if fighter.charge >= 1.0:
			fighter.charge = 0.0
			_perform_skill(fighter)


func _build_battlefield() -> void:
	var sky := _add_texture(SCENE_ASSETS + "图层 2.png", Rect2(0, 0, 1280, 220), 0)
	sky.stretch_mode = TextureRect.STRETCH_SCALE

	_add_texture(SCENE_ASSETS + "图层 5.png", Rect2(0, 215, 1280, 405), 1, TextureRect.STRETCH_SCALE)
	_add_texture(SCENE_ASSETS + "图层 3.png", Rect2(0, 82, 1280, 149), 3, TextureRect.STRETCH_SCALE)
	_build_platforms()
	_spawn_teams()
	_add_texture(SCENE_ASSETS + "图层 1.png", Rect2(0, 400, 1280, 315), 20, TextureRect.STRETCH_SCALE)
	_build_hud()


func _build_platforms() -> void:
	for group_x in [170.0, 670.0]:
		_add_texture(SCENE_ASSETS + "图层 6.png", Rect2(group_x, 307, 440, 52), 4, TextureRect.STRETCH_SCALE)
	_add_texture(SCENE_ASSETS + "图层 7.png", Rect2(135, 410, 446, 55), 4, TextureRect.STRETCH_SCALE)
	_add_texture(SCENE_ASSETS + "图层 7.png", Rect2(702, 410, 446, 55), 4, TextureRect.STRETCH_SCALE)


func _spawn_teams() -> void:
	var player_team: Array[String] = GameState.player_team.duplicate()
	if player_team.is_empty():
		player_team = FALLBACK_TEAM.duplicate()
	player_synergies = CATALOG.count_synergies(player_team)
	for index in 6:
		var row := index / 3
		var column := index % 3
		var row_x_positions := TOP_X_POSITIONS if row == 0 else BOTTOM_X_POSITIONS
		if index < player_team.size():
			_create_fighter(player_team[index], Vector2(row_x_positions[column], ROW_POSITIONS[row]), true, index)
		GameState.mark_creature_seen(ENEMY_TEAM[index])
		_create_fighter(ENEMY_TEAM[index], Vector2(row_x_positions[column + 3], ROW_POSITIONS[row]), false, index)


func _create_fighter(texture_path: String, center: Vector2, player_side: bool, index: int) -> void:
	var fighter := Fighter.new()
	fighter.player_side = player_side
	fighter.traits = CATALOG.traits_for_texture(texture_path)
	var base_hp := 72 + index * 7
	if player_side:
		base_hp = roundi(base_hp * (1.0 + GameState.run_health_bonus))
		fighter.damage_multiplier *= 1.0 + GameState.run_damage_bonus
	if not player_side and GameState.map_initialized:
		match GameState.current_map_node_type():
			"elite":
				base_hp = roundi(base_hp * 1.35)
				fighter.damage_multiplier = 1.22
			"boss":
				base_hp = roundi(base_hp * 1.75)
				fighter.damage_multiplier = 1.48
	fighter.max_hp = base_hp
	fighter.hp = fighter.max_hp
	fighter.base_charge_rate = rng.randf_range(0.18, 0.29)
	if player_side:
		fighter.base_charge_rate *= 1.0 + GameState.run_charge_bonus
	if not player_side and GameState.map_initialized:
		if GameState.current_map_node_type() == "elite":
			fighter.base_charge_rate *= 1.12
		elif GameState.current_map_node_type() == "boss":
			fighter.base_charge_rate *= 1.25
	fighter.charge_rate = fighter.base_charge_rate
	if player_side and fighter.traits.has("岩"):
		fighter.damage_reduction = CATALOG.effect_value("岩", int(player_synergies.get("岩", 0)))
	if player_side and fighter.traits.has("虫群"):
		fighter.base_charge_rate *= 1.0 + CATALOG.effect_value("虫群", int(player_synergies.get("虫群", 0)))
	if player_side and fighter.traits.has("龙族"):
		fighter.damage_multiplier *= 1.0 + CATALOG.effect_value("龙族", int(player_synergies.get("龙族", 0)))
	if player_side and fighter.traits.has("亡灵"):
		fighter.heal_on_cast = CATALOG.effect_value("亡灵", int(player_synergies.get("亡灵", 0)))
	if player_side and fighter.traits.has("机械"):
		var mechanical_tier := CATALOG.active_tier("机械", int(player_synergies.get("机械", 0)))
		if mechanical_tier >= 0:
			fighter.shield = roundi(fighter.max_hp * 0.20)
			fighter.mechanical_shock_ready = mechanical_tier >= 1

	var sprite := TextureRect.new()
	sprite.position = center + Vector2(-38, -66)
	sprite.size = Vector2(76, 78)
	sprite.texture = load(texture_path) as Texture2D
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sprite.pivot_offset = sprite.size * 0.5
	sprite.scale = Vector2.ONE if player_side else Vector2(-1, 1)
	sprite.z_index = 10
	add_child(sprite)
	fighter.sprite = sprite
	fighter.base_scale = sprite.scale
	fighter.home_position = sprite.position

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
	_update_hp_label(fighter)
	fighters.append(fighter)


func _build_hud() -> void:
	var battle_title := "第 1 天 · 战斗"
	if GameState.map_initialized:
		match GameState.current_map_node_type():
			"elite": battle_title = "精 英 战"
			"boss": battle_title = "B O S S 战"
	_add_label(battle_title, Rect2(430, 7, 420, 48), 30, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, 45)
	_add_label("我方", Rect2(14, 270, 120, 28), 17, Color.WHITE, HORIZONTAL_ALIGNMENT_LEFT, 45)
	_add_label("敌方", Rect2(1146, 270, 120, 28), 17, Color.WHITE, HORIZONTAL_ALIGNMENT_RIGHT, 45)
	status_label = _add_label("技能条充满后自动攻击随机目标", Rect2(360, 665, 560, 34), 14, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, 45)
	var exit_button := Button.new()
	exit_button.position = Vector2(1150, 10)
	exit_button.size = Vector2(110, 45)
	exit_button.text = "撤退"
	exit_button.add_theme_font_override("font", source_han_font)
	exit_button.add_theme_font_size_override("font_size", 16)
	exit_button.add_theme_color_override("font_color", Color.WHITE)
	exit_button.add_theme_color_override("font_outline_color", Color.BLACK)
	exit_button.add_theme_constant_override("outline_size", 1)
	exit_button.add_theme_stylebox_override("normal", _panel_style(Color(0.6, 0.09, 0.18, 0.95), Color.WHITE, 2))
	exit_button.z_index = 45
	exit_button.pressed.connect(_back_to_prep)
	add_child(exit_button)


func _perform_skill(attacker: Fighter) -> void:
	if battle_over or not attacker.alive:
		return
	var targets := _living_fighters(not attacker.player_side)
	if targets.is_empty():
		_finish_battle(attacker.player_side)
		return
	var target: Fighter = targets[rng.randi_range(0, targets.size() - 1)]
	var attack_multiplier := attacker.damage_multiplier
	if attacker.player_side and attacker.traits.has("龙族") and attacker.hp * 2 < attacker.max_hp and CATALOG.active_tier("龙族", int(player_synergies.get("龙族", 0))) >= 2:
		attack_multiplier *= 1.35
	var damage := roundi(rng.randi_range(9, 17) * attack_multiplier * (1.0 - target.damage_reduction))
	damage = maxi(damage, 1)
	var dealt := _apply_damage(target, damage)
	status_label.text = "%s发动技能，造成 %d 点伤害" % ["我方" if attacker.player_side else "敌方", dealt]
	_play_attack_animation(attacker, target, dealt)
	_apply_fire_attack(attacker, target)
	_apply_lightning_attack(attacker, target, dealt)
	_apply_dragon_splash(attacker, target, dealt)
	_charge_other_insects(attacker)
	if attacker.heal_on_cast > 0.0 and attacker.hp > 0:
		var healed := roundi(attacker.max_hp * attacker.heal_on_cast)
		_heal_fighter(attacker, healed)
	if target.hp <= 0:
		_defeat_fighter(target)
	_check_battle_end()


func _play_attack_animation(attacker: Fighter, target: Fighter, damage: int) -> void:
	var attack_tween := create_tween()
	attack_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	attack_tween.tween_property(attacker.sprite, "scale", attacker.base_scale * 1.28, 0.12)
	attack_tween.tween_property(attacker.sprite, "scale", attacker.base_scale, 0.16)

	var hit_tween := create_tween()
	hit_tween.tween_property(target.sprite, "modulate", Color(1.0, 0.25, 0.25), 0.08)
	hit_tween.tween_property(target.sprite, "modulate", Color.WHITE, 0.18)

	var damage_label := _add_label("-%d" % damage, Rect2(target.sprite.position.x, target.sprite.position.y - 10, 76, 28), 18, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, 30)
	var float_tween := create_tween().set_parallel(true)
	float_tween.tween_property(damage_label, "position:y", damage_label.position.y - 28, 0.55)
	float_tween.tween_property(damage_label, "modulate:a", 0.0, 0.55)
	float_tween.chain().tween_callback(damage_label.queue_free)


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
	var remaining := maxi(damage, 0)
	var shield_before := target.shield
	if target.shield > 0:
		var absorbed := mini(target.shield, remaining)
		target.shield -= absorbed
		remaining -= absorbed
	if remaining > 0:
		target.hp = maxi(target.hp - remaining, 0)
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
	return damage


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
		var damage: int = int(fighter.burn_stacks) * 3
		_apply_damage(fighter, damage)
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
		if ally != source and ally.traits.has("亡灵"):
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


func _update_hp_label(fighter: Fighter) -> void:
	if fighter.hp_label == null:
		return
	fighter.hp_label.text = "%d/%d  ◆%d" % [fighter.hp, fighter.max_hp, fighter.shield] if fighter.shield > 0 else "%d/%d" % [fighter.hp, fighter.max_hp]


func _defeat_fighter(fighter: Fighter) -> void:
	if not fighter.alive:
		return
	if fighter.player_side and fighter.traits.has("亡灵"):
		var undead_tier := CATALOG.active_tier("亡灵", int(player_synergies.get("亡灵", 0)))
		if undead_tier >= 1:
			_heal_other_undead(fighter)
		if undead_tier >= 2 and not fighter.revived_as_spirit:
			fighter.revived_as_spirit = true
			fighter.hp = maxi(roundi(fighter.max_hp * 0.30), 1)
			fighter.charge = 0.35
			fighter.damage_multiplier *= 0.82
			fighter.sprite.modulate = Color(0.68, 0.62, 0.92, 0.88)
			_update_hp_label(fighter)
			_update_charge_bar(fighter)
			status_label.text = "亡灵羁绊触发：单位以灵魂形态复活"
			return
	if fighter.player_side and fighter.traits.has("植物") and not fighter.revived_as_seedling and CATALOG.active_tier("植物", int(player_synergies.get("植物", 0))) >= 2:
		fighter.revived_as_seedling = true
		fighter.hp = maxi(roundi(fighter.max_hp * 0.35), 1)
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
		for texture_path in GameState.player_team:
			GameState.unlock_creature_achievement(texture_path, GameState.ACHIEVEMENT_STAR)
		if GameState.map_initialized:
			GameState.complete_current_map_node()
			match GameState.current_map_node_type():
				"battle": GameState.coins += 2
				"elite": GameState.coins += 5
				"boss": GameState.coins += 10
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0, 0, 0, 0.7)
	shade.z_index = 100
	add_child(shade)
	_add_label("胜 利" if player_won else "战斗失败", Rect2(390, 245, 500, 80), 38, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, 110)
	if not player_won or not GameState.map_initialized:
		var retry := _create_result_button("重新战斗", Vector2(435, 350))
		retry.pressed.connect(_restart_battle)
	var back_position := Vector2(545, 350) if player_won and GameState.map_initialized else Vector2(655, 350)
	var back := _create_result_button("返回地图" if GameState.map_initialized else "返回备战", back_position)
	back.pressed.connect(_back_to_prep)


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
	button.add_theme_stylebox_override("normal", _panel_style(Color(0.05, 0.35, 0.45, 1.0), Color.WHITE, 2))
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
	get_tree().reload_current_scene()


func _back_to_prep() -> void:
	get_tree().change_scene_to_file("res://map.tscn" if GameState.map_initialized else "res://battle_prep.tscn")


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
