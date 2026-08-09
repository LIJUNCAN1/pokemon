extends Node

const ITEM_CATALOG = preload("res://scripts/item_catalog.gd")

var failures: Array[String] = []


func _ready() -> void:
	GameState.reset_run()
	_test_catalog_assets()
	_test_inventory_effects()
	await _test_shop_rolls()
	if failures.is_empty():
		print("ITEM_SYSTEM_TEST: PASS")
		get_tree().quit()
		return
	for failure in failures:
		push_error(failure)
	get_tree().quit(1)


func _test_catalog_assets() -> void:
	for kind in ["item", "accessory"]:
		var ids: Array[int] = ITEM_CATALOG.CONSUMABLE_IDS if kind == "item" else ITEM_CATALOG.ACCESSORY_IDS
		for id in ids:
			var entry := ITEM_CATALOG.entry_for_id(kind, id)
			_check(ResourceLoader.exists(String(entry["path"])), "Missing normalized icon: %s" % entry["path"])
			_check(not String(entry["name"]).is_empty(), "Generated name is empty: %s/%d" % [kind, id])
			_check(not String(entry["effect"]).is_empty(), "Generated effect is empty: %s/%d" % [kind, id])


func _test_inventory_effects() -> void:
	var accessory := ITEM_CATALOG.entry_for_id("accessory", 2)
	var effect_type := String(accessory["effect_type"])
	var before := _run_bonus(effect_type)
	GameState.add_accessory(accessory)
	_check(GameState.accessory_inventory.size() == 1, "Accessory was not stored")
	_check(is_equal_approx(_run_bonus(effect_type), before + float(accessory["amount"])), "Accessory buff was not applied")

	var consumable := ITEM_CATALOG.entry_for_id("item", 204)
	GameState.add_item(consumable)
	_check(GameState.item_inventory.size() == 1, "Consumable was not stored")
	var result := GameState.use_item(0)
	_check(not result.is_empty(), "Consumable returned no result")
	_check(GameState.item_inventory.is_empty(), "Consumable was not removed after use")
	var bonuses := GameState.take_next_battle_bonuses()
	_check(float(bonuses["health"]) > 0.0, "Next-battle consumable buff was not queued")
	var consumed := GameState.take_next_battle_bonuses()
	_check(is_zero_approx(float(consumed["health"])), "Next-battle consumable buff was applied more than once")


func _test_shop_rolls() -> void:
	var prep := preload("res://battle_prep.tscn").instantiate()
	add_child(prep)
	await get_tree().process_frame
	for iteration in 500:
		var entries: Array = prep.call("_roll_shop_entries")
		var item_count := 0
		var accessory_count := 0
		for entry_value in entries:
			var entry: Dictionary = entry_value
			item_count += 1 if entry["kind"] == "item" else 0
			accessory_count += 1 if entry["kind"] == "accessory" else 0
		_check(item_count <= 1, "Shop refresh generated more than one consumable")
		_check(accessory_count <= 1, "Shop refresh generated more than one accessory")
	prep.queue_free()


func _run_bonus(effect_type: String) -> float:
	match effect_type:
		"health": return GameState.run_health_bonus
		"damage": return GameState.run_damage_bonus
		"charge": return GameState.run_charge_bonus
	return 0.0


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

