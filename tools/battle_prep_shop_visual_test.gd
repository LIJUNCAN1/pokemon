extends Node

const PREP_SCENE: PackedScene = preload("res://battle_prep.tscn")
const ITEM_CATALOG = preload("res://scripts/item_catalog.gd")
const CREATURES: Array[String] = [
	"res://素材/宝可梦图/1 (1).png",
	"res://素材/宝可梦图/1 (9).png",
	"res://素材/宝可梦图/图层 4.png",
	"res://素材/宝可梦图/图层 5.png",
	"res://素材/宝可梦图/图层 6.png",
]


func _ready() -> void:
	GameState.reset_run()
	GameState.coins = 12
	GameState.run_lives = 3
	var prep := PREP_SCENE.instantiate()
	add_child(prep)
	await get_tree().process_frame
	await get_tree().process_frame

	var entries: Array[Dictionary] = [
		_creature_entry(CREATURES[0], 0),
		_creature_entry(CREATURES[1], 1),
		_creature_entry(CREATURES[2], 2),
		_creature_entry(CREATURES[3], 0),
		_creature_entry(CREATURES[4], 1),
	]
	prep.shop_data = entries
	for index in prep.shop_data.size():
		prep._render_shop_card(index)
	prep._sync_coins()
	await get_tree().create_timer(0.9).timeout
	await _capture("res://battle_prep_shop_final.png")

	prep._on_lock_pressed()
	await _capture("res://battle_prep_shop_locked.png")
	prep._on_lock_pressed()
	await get_tree().create_timer(0.2).timeout
	_assert(prep.shop_lock_overlays[0].visible, "unlock animation must remain visible while fading")
	_assert(prep.shop_lock_overlays[0].modulate.a > 0.0 and prep.shop_lock_overlays[0].modulate.a < 1.0, "unlock animation alpha must fade gradually")
	await _capture("res://battle_prep_shop_unlocking.png")

	prep._show_shop_card_tooltip(2)
	prep.shop_detail_icons[2].texture = load(prep.DETAIL_ICON_PRESSED) as Texture2D
	_assert(prep.card_tooltip.visible, "right-click detail panel must be visible")
	await _capture("res://battle_prep_shop_detail.png")

	_assert(prep.shop_buttons.size() == 5, "shop must contain exactly five cards")
	_assert(is_equal_approx(prep.shop_buttons[0].position.y, 574.0), "card row must use the Aseprite-authored vertical offset")
	_assert(not prep.shop_hp_badges[0].visible and not prep.shop_special_badges[0].visible, "legacy red and blue stat boxes must stay hidden")
	_assert(prep.shop_element_icon_backgrounds[0].texture != null, "attribute frame must come from the exported Aseprite asset")
	_assert(prep.coin_label.text == "12G", "coin label must reflect GameState immediately")
	_assert(prep.health_icons.size() == 3, "run health must contain three heart icons")
	_assert(prep.shop_card_outlines[0].get_theme_stylebox("panel").border_color == prep.SHOP_RARITY_COLORS[0], "normal rarity border color")
	_assert(prep.shop_card_outlines[1].get_theme_stylebox("panel").border_color == prep.SHOP_RARITY_COLORS[1], "rare rarity border color")
	_assert(prep.shop_card_outlines[2].get_theme_stylebox("panel").border_color == prep.SHOP_RARITY_COLORS[2], "epic rarity border color")
	print("BATTLE_PREP_SHOP_VISUAL_TEST: PASS")
	get_tree().quit()


func _creature_entry(path: String, rarity: int) -> Dictionary:
	return {"kind": "creature", "path": path, "rarity": rarity, "price": rarity + 1}


func _capture(path: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	var error := get_viewport().get_texture().get_image().save_png(ProjectSettings.globalize_path(path))
	_assert(error == OK, "failed to save %s" % path)


func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	push_error("BATTLE_PREP_SHOP_VISUAL_TEST: %s" % message)
	get_tree().quit(1)
