extends Node

const ITEM_CATALOG = preload("res://scripts/item_catalog.gd")
const CREATURE_CATALOG = preload("res://scripts/creature_catalog.gd")
const BATTLE_SCRIPT = preload("res://scripts/battle.gd")
const EQUIPMENT_CATALOG = preload("res://scripts/equipment_catalog.gd")

var failures: Array[String] = []


func _ready() -> void:
	GameState.reset_run()
	_test_economy_rules()
	_test_enemy_curve()
	_test_equipment_combat()
	_test_catalog_assets()
	_test_inventory_effects()
	await _test_shop_rolls()
	await _test_collection_ui()
	if failures.is_empty():
		print("ITEM_SYSTEM_TEST: PASS")
		get_tree().quit()
		return
	for failure in failures:
		push_error(failure)
	get_tree().quit(1)


func _test_economy_rules() -> void:
	GameState.coins = 29
	var regular := GameState.battle_gold_breakdown("battle")
	var elite := GameState.battle_gold_breakdown("elite")
	var boss := GameState.battle_gold_breakdown("boss")
	_check(int(regular["total"]) == 14, "Regular battle gold must include 9 base and 5 interest")
	_check(int(elite["total"]) == 19, "Elite battle gold must include the region-one node bonus")
	_check(int(boss["total"]) == 24, "Boss battle gold must include the region-one node bonus")
	GameState.coins = 0
	GameState.region = 2
	_check(int(GameState.battle_gold_breakdown("battle")["total"]) == 11, "Region two regular reward must be 11")
	_check(int(GameState.battle_gold_breakdown("elite")["total"]) == 18, "Region two elite reward must include a 7-gold bonus")
	GameState.region = 3
	_check(int(GameState.battle_gold_breakdown("battle")["total"]) == 13, "Region three regular reward must be 13")
	_check(int(GameState.battle_gold_breakdown("boss")["total"]) == 28, "Region three boss reward must include a 15-gold bonus")
	GameState.region = 1
	GameState.coins = 100
	_check(int(GameState.battle_gold_breakdown("battle")["interest"]) == 8, "Interest must be capped at 8")
	var expected_sell_values := [[1, 2, 4], [2, 4, 8], [3, 6, 12], [4, 8, 16], [5, 10, 21]]
	for rarity in expected_sell_values.size():
		for level in 3:
			_check(GameState.creature_sell_value(rarity, level + 1) == expected_sell_values[rarity][level], "Unexpected sell value for rarity %d level %d" % [rarity, level + 1])
	_check(GameState.CREATURE_STAR_COPIES == [1, 3, 6], "Creature merging must use 3 one-stars for level 2 and 2 two-stars for level 3")
	for copies in GameState.CREATURE_POOL_COPIES:
		_check(copies >= GameState.CREATURE_STAR_COPIES[2], "Every rarity pool must contain enough copies to reach 3 stars")
	GameState.coins = GameState.STARTING_COINS


func _test_enemy_curve() -> void:
	GameState.map_initialized = true
	GameState.battle_victories = 2
	GameState.current_map_node = 0
	GameState.map_nodes = [{"id": 0, "type": "battle", "column": 8}]
	var battle := BATTLE_SCRIPT.new()
	_check(int(battle.call("_enemy_count_for_current_node")) == 5, "Late normal encounters must cap at five enemies")
	GameState.map_nodes[0]["type"] = "elite"
	_check(int(battle.call("_enemy_count_for_current_node")) == 6, "Elite encounters may add one enemy above the normal cap")
	battle.free()
	GameState.map_initialized = false
	GameState.map_nodes.clear()
	GameState.current_map_node = 0


func _test_equipment_combat() -> void:
	var battle := BATTLE_SCRIPT.new()
	var fighter := BATTLE_SCRIPT.Fighter.new()
	fighter.max_hp = 100
	fighter.hp = 100
	fighter.equipment = ["stoneplate", "berserker_claw"]
	battle._apply_equipment_base_stats(fighter)
	_check(fighter.max_hp == 115 and fighter.hp == 115, "Equipment health must apply to the individual fighter")
	_check(is_equal_approx(fighter.damage_multiplier, 1.12), "Equipment damage must apply to the individual fighter")
	_check(is_equal_approx(battle._equipment_effect_amount(fighter, "low_hp_shield"), 0.20), "Equipment special effects must be readable in combat")
	battle.free()


func _test_catalog_assets() -> void:
	for kind in ["item", "accessory"]:
		var ids: Array[int] = ITEM_CATALOG.CONSUMABLE_IDS if kind == "item" else ITEM_CATALOG.ACCESSORY_IDS
		var names: Dictionary = {}
		for id in ids:
			var entry := ITEM_CATALOG.entry_for_id(kind, id)
			_check(ResourceLoader.exists(String(entry["path"])), "Missing normalized icon: %s" % entry["path"])
			_check(not String(entry["name"]).is_empty(), "Generated name is empty: %s/%d" % [kind, id])
			_check(not String(entry["effect"]).is_empty(), "Generated effect is empty: %s/%d" % [kind, id])
			_check(not names.has(entry["name"]), "Formal item names must be unique: %s" % entry["name"])
			names[entry["name"]] = true
			_check(int(entry.get("stack_limit", 0)) > 0, "Item stack rule is missing: %s/%d" % [kind, id])
			_check(not Array(entry.get("sources", [])).is_empty(), "Item drop sources are missing: %s/%d" % [kind, id])
	var equipment_ids: Dictionary = {}
	for entry in EQUIPMENT_CATALOG.all():
		_check(not equipment_ids.has(entry["id"]), "Equipment ID must be unique: %s" % entry["id"])
		equipment_ids[entry["id"]] = true
		_check(ResourceLoader.exists(String(entry["path"])), "Missing equipment icon: %s" % entry["path"])
		_check(not String(entry["effect"]).is_empty(), "Equipment effect must not be empty: %s" % entry["name"])
	_check(equipment_ids.size() == 12, "The first equipment release must contain 12 entries")
	var first_equipment := EQUIPMENT_CATALOG.all()[0]
	_check(not GameState.add_equipment(first_equipment).is_empty(), "Equipment could not be added to inventory")
	_check(GameState.has_seen_equipment(String(first_equipment["id"])), "Obtained equipment must unlock its dex entry")
	GameState.set_player_team([CREATURE_CATALOG.all_textures()[0]], [1], [[String(first_equipment["id"])]])
	_check(GameState.player_team_equipment.size() == 1 and GameState.player_team_equipment[0].size() == 1, "Equipped items must persist with the creature slot")
	GameState.set_player_team([], [])
	var migrated := ITEM_CATALOG.normalize_entry({"id": ITEM_CATALOG.CONSUMABLE_IDS[0], "kind": "item", "name": "旧名称"})
	_check(String(migrated["name"]) == String(ITEM_CATALOG.entry_for_id("item", ITEM_CATALOG.CONSUMABLE_IDS[0])["name"]), "Old saves must migrate to the formal catalog name")
	var source_rng := RandomNumberGenerator.new()
	source_rng.seed = 20260811
	for source in ["battle", "elite", "boss"]:
		for _iteration in 40:
			var reward := ITEM_CATALOG.random_entry("item", source_rng, -1, source)
			_check(source in Array(reward.get("sources", [])), "Random rewards must respect their drop source: %s" % source)


func _test_inventory_effects() -> void:
	var accessory := ITEM_CATALOG.entry_for_id("accessory", 2)
	var effect_type := String(accessory["effect_type"])
	var before := _run_bonus(effect_type)
	GameState.add_accessory(accessory)
	_check(GameState.accessory_inventory.size() == 1, "Accessory was not stored")
	_check(GameState.has_seen_item(accessory, "accessory"), "Accessory was not unlocked in the dex")
	_check(is_equal_approx(_run_bonus(effect_type), before + float(accessory["amount"])), "Accessory buff was not applied")

	var consumable := ITEM_CATALOG.entry_for_id("item", 1)
	GameState.add_item(consumable)
	_check(GameState.item_inventory.size() == 1, "Consumable was not stored")
	_check(GameState.has_seen_item(consumable, "item"), "Consumable was not unlocked in the dex")
	var result := GameState.use_item(0)
	_check(not result.is_empty(), "Consumable returned no result")
	_check(GameState.item_inventory.is_empty(), "Consumable was not removed after use")
	_check(GameState.has_seen_item(consumable, "item"), "Consumed item disappeared from the dex")
	var bonuses := GameState.take_next_battle_bonuses()
	_check(float(bonuses["health"]) > 0.0, "Next-battle consumable buff was not queued")
	var consumed := GameState.take_next_battle_bonuses()
	_check(is_zero_approx(float(consumed["health"])), "Next-battle consumable buff was applied more than once")

	for _copy in 3:
		GameState.add_item(consumable)
	_check(not GameState.can_add_item(consumable), "Consumable stack limit must reject a fourth common copy")
	_check(GameState.add_item(consumable).is_empty(), "Rejected consumable must not enter the inventory")

	var discount_accessory := ITEM_CATALOG.entry_for_id("accessory", 10)
	_check(not GameState.add_accessory(discount_accessory).is_empty(), "Economy accessory was not accepted")
	_check(GameState.shop_price(5) == 4, "Shop discount accessory must reduce prices above one")
	_check(GameState.creature_sell_value(4, 1) == 4, "A discounted one-star creature must sell for its actual purchase price")
	_check(not GameState.can_add_accessory(discount_accessory), "Economy accessories in the same group must be unique")
	var battle_gold_accessory := ITEM_CATALOG.entry_for_id("accessory", 6)
	GameState.add_accessory(battle_gold_accessory)
	GameState.coins = 0
	_check(int(GameState.battle_gold_breakdown("battle")["total"]) == GameState.BATTLE_BASE_GOLD + 1, "Battle-gold accessory must add one victory coin")
	var interest_accessory := ITEM_CATALOG.entry_for_id("accessory", 9)
	GameState.add_accessory(interest_accessory)
	GameState.coins = 100
	_check(int(GameState.battle_gold_breakdown("battle")["interest"]) == GameState.MAX_INTEREST_GOLD + 1, "Interest accessory must raise the interest cap")

	var pool_path: String = CREATURE_CATALOG.all_textures()[0]
	var pool_before := int(GameState.creature_shop_pool[pool_path])
	_check(GameState.take_creature_from_pool(pool_path), "Shared creature pool must allow taking an available copy")
	_check(int(GameState.creature_shop_pool[pool_path]) == pool_before - 1, "Shared creature pool did not decrement")
	GameState.return_creature_to_pool(pool_path)
	_check(int(GameState.creature_shop_pool[pool_path]) == pool_before, "Selling must return copies to the shared creature pool")


func _test_shop_rolls() -> void:
	var prep := preload("res://battle_prep.tscn").instantiate()
	add_child(prep)
	await get_tree().process_frame
	GameState.floor = 1
	var early_chances: PackedFloat32Array = prep._shop_rarity_chances()
	GameState.floor = GameState.MAX_FLOORS
	var late_chances: PackedFloat32Array = prep._shop_rarity_chances()
	_check(is_equal_approx(Array(early_chances).reduce(func(total, value): return total + value, 0.0), 1.0), "Early shop rarity chances must sum to one")
	_check(is_equal_approx(Array(late_chances).reduce(func(total, value): return total + value, 0.0), 1.0), "Late shop rarity chances must sum to one")
	_check(late_chances[4] > early_chances[4], "Legendary shop chance must increase with floor")
	GameState.floor = 1
	for iteration in 500:
		var entries: Array = prep.call("_roll_shop_entries")
		var item_count := 0
		var accessory_count := 0
		var equipment_count := 0
		var creature_count := 0
		var local_creature_counts: Dictionary = {}
		for entry_value in entries:
			var entry: Dictionary = entry_value
			item_count += 1 if entry["kind"] == "item" else 0
			accessory_count += 1 if entry["kind"] == "accessory" else 0
			equipment_count += 1 if entry["kind"] == "equipment" else 0
			if entry["kind"] == "creature":
				creature_count += 1
				var texture_path := String(entry["path"])
				local_creature_counts[texture_path] = int(local_creature_counts.get(texture_path, 0)) + 1
		_check(item_count <= 1, "Shop refresh generated more than one consumable")
		_check(accessory_count <= 1, "Shop refresh generated more than one accessory")
		_check(equipment_count <= 1, "Shop refresh generated more than one equipment card")
		_check(item_count + accessory_count + equipment_count <= 1, "Shop refresh generated more than one non-creature card")
		_check(creature_count >= 3, "Shop refresh must preserve at least three creature slots")
		for texture_path in local_creature_counts:
			_check(int(local_creature_counts[texture_path]) <= int(GameState.creature_shop_pool.get(texture_path, 0)), "A shop refresh cannot draw more copies than the shared pool contains")
	var sell_path: String = prep.CREATURE_TEXTURES[0]
	var sell_rarity := CREATURE_CATALOG.rarity_for_texture(sell_path)
	var pool_before_purchase := int(GameState.creature_shop_pool[sell_path])
	GameState.coins = 20
	prep.shop_data[0] = {"kind": "creature", "path": sell_path, "rarity": sell_rarity, "price": GameState.shop_price(GameState.CREATURE_BUY_PRICES[sell_rarity])}
	prep._render_shop_card(0)
	prep._on_shop_card_pressed(0)
	_check(prep.creature_data[0] == sell_path, "Purchased creature must enter the bench")
	_check(int(GameState.creature_shop_pool[sell_path]) == pool_before_purchase - 1, "Purchasing must remove one shared-pool copy")
	var equipment_entry := EQUIPMENT_CATALOG.all()[0]
	prep.selected_slot = 0
	_check(prep.equip_selected_creature(equipment_entry), "Selected creature could not equip an inventory item")
	_check(String(equipment_entry["id"]) in prep.creature_equipment[0], "Equipment did not stay on the selected creature slot")
	var sell_value := GameState.creature_sell_value(sell_rarity, 1)
	var coins_before_sale := GameState.coins
	prep._show_shop_sell_target(0)
	_check(prep.shop_sell_overlay.visible, "Dragging a creature must reveal the shop sell target")
	_check(prep.shop_sell_label.text == "售出  +%dG" % sell_value, "Sell target must show the exact sale value")
	prep._drop_shop_sell_data(Vector2.ZERO, {"kind": "creature_slot", "source_index": 0})
	_check(prep.creature_data[0].is_empty(), "Sold creature was not removed from its slot")
	_check(GameState.coins == coins_before_sale + sell_value, "Selling a creature granted the wrong amount of gold")
	_check(int(GameState.creature_shop_pool[sell_path]) == pool_before_purchase, "Selling must return the creature to the shared pool")
	_check(GameState.equipment_inventory.any(func(entry: Dictionary) -> bool: return String(entry.get("id", "")) == String(equipment_entry["id"])), "Selling a creature must return its equipment to inventory")
	_check(not prep.shop_sell_overlay.visible, "Sell target remained visible after the sale")
	prep.queue_free()


func _test_collection_ui() -> void:
	var common_item := ITEM_CATALOG.entry_for_id("item", 1)
	var epic_item := ITEM_CATALOG.entry_for_id("item", 109)
	GameState.add_item(common_item)
	GameState.add_item(epic_item)
	var inventory := preload("res://inventory_popup.tscn").instantiate()
	add_child(inventory)
	await get_tree().process_frame
	inventory._select_tab("item")
	await get_tree().process_frame
	_check(inventory.item_grid.columns == 3, "Inventory must show three items per row")
	_check(inventory.item_grid.get_child_count() >= 24, "Inventory must preserve eight rows before scrolling")
	var first_slot := inventory.item_grid.get_child(0) as Control
	var first_item := epic_item
	_check(first_slot.tooltip_text.is_empty(), "Inventory slots must not open hover information boxes")
	var rarity_found := false
	for child in first_slot.get_children():
		if child is Label and child.text == ITEM_CATALOG.RARITY_NAMES[int(first_item["rarity"])]:
			rarity_found = true
	_check(rarity_found, "Inventory items must display their rarity")
	var right_click := InputEventMouseButton.new()
	right_click.button_index = MOUSE_BUTTON_RIGHT
	right_click.pressed = true
	inventory._on_item_slot_gui_input(right_click, common_item, "持有 1/99")
	_check(inventory.item_info_panel.visible, "Right-clicking an inventory item must open its fixed detail panel")
	_check(inventory.item_info_name.text == String(common_item["name"]), "Inventory detail panel must show the selected item")
	_check(inventory.item_info_dismiss_layer.visible, "Opening item details must enable the blank-area dismiss layer")
	inventory.item_info_dismiss_layer.pressed.emit()
	_check(not inventory.item_info_panel.visible and not inventory.item_info_dismiss_layer.visible, "Clicking blank inventory space must close item details")
	inventory._select_tab("equipment")
	await get_tree().process_frame
	_check(inventory.equipment_tab.disabled, "Inventory must provide a selectable equipment tab")
	var equipment_entry := EQUIPMENT_CATALOG.all()[0]
	GameState.add_equipment(equipment_entry)
	inventory.show_entry_info(equipment_entry, "已装备 · 每名角色最多装备两件")
	_check(inventory.item_info_panel.visible and inventory.item_info_name.text == String(equipment_entry["name"]), "Equipment details must reuse the item detail panel")
	_check(inventory.item_info_type.text == "✦ 装备", "Equipment details must use the equipment type label")
	inventory.queue_free()

	GameState.mark_creature_seen("res://素材/宝可梦图/1 (1).png")
	var dex := preload("res://dex_overlay.tscn").instantiate()
	add_child(dex)
	await get_tree().process_frame
	_check(dex.level_buttons.size() == 4, "Dex must build four level buttons")
	_check("装备" in dex.TAB_NAMES and dex.equipment_entries.size() == 12, "Dex must provide a complete equipment collection page")
	dex._on_tab_pressed(dex.TAB_NAMES.find("装备"))
	_check(dex.equipment_cards.size() == 12 and dex.equipment_cards[0].visible, "Equipment dex cards must be visible on the equipment tab")
	dex._on_tab_pressed(0)
	dex._on_level_pressed(2)
	_check(dex.level_buttons[2].disabled and not dex.level_buttons[0].disabled, "Dex selected level color must move with the selected level")
	for button in dex.level_buttons:
		_check(button.tooltip_text.is_empty(), "Dex level buttons must not show hover name boxes")
	_check(dex.detail_description.get_theme_color("font_shadow_color").a == 0.0, "Dex dark text must not keep a black shadow")
	dex.queue_free()


func _run_bonus(effect_type: String) -> float:
	match effect_type:
		"health": return GameState.run_health_bonus
		"damage": return GameState.run_damage_bonus
		"charge": return GameState.run_charge_bonus
	return 0.0


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

