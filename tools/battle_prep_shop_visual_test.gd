extends Node

const PREP_SCENE: PackedScene = preload("res://battle_prep.tscn")
const ITEM_CATALOG = preload("res://scripts/item_catalog.gd")
const CREATURES: Array[String] = [
	"res://素材/图鉴/角色/1 (3).png",
	"res://素材/图鉴/角色/1 (2).png",
	"res://素材/图鉴/角色/1 (1).png",
	"res://素材/图鉴/角色/1 (12).png",
	"res://素材/图鉴/角色/1 (14).png",
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
		ITEM_CATALOG.entry_for_id("item", 109),
	]
	prep.shop_data = entries
	for index in prep.shop_data.size():
		prep._render_shop_card(index)
	prep._sync_coins()
	await get_tree().create_timer(0.9).timeout
	await _capture("res://battle_prep_shop_final.png")

	prep._on_lock_pressed()
	_assert(prep.shop_star_rows[0].visible, "locking the shop must not hide creature stars")
	await _capture("res://battle_prep_shop_locked.png")
	prep._on_lock_pressed()
	await get_tree().create_timer(0.2).timeout
	_assert(prep.shop_lock_overlays[0].visible, "unlock animation must remain visible while fading")
	_assert(prep.shop_lock_overlays[0].modulate.a > 0.0 and prep.shop_lock_overlays[0].modulate.a < 1.0, "unlock animation alpha must fade gradually")
	await _capture("res://battle_prep_shop_unlocking.png")

	var inspect_event := InputEventMouseButton.new()
	inspect_event.button_index = MOUSE_BUTTON_RIGHT
	inspect_event.pressed = true
	prep._on_shop_card_gui_input(inspect_event, 2)
	_assert(prep.card_tooltip.visible, "right-click detail panel must be visible")
	_assert(CursorManager.inspecting_card, "right-click must switch to the detail cursor")
	_assert(prep.card_tooltip_rarity.get_theme_color("font_color") == prep.SHOP_RARITY_COLORS[2], "detail rarity text must match the card rarity color")
	await _capture("res://battle_prep_shop_detail.png")
	inspect_event.pressed = false
	prep._on_shop_card_gui_input(inspect_event, 2)
	_assert(not CursorManager.inspecting_card, "releasing right-click must restore the normal cursor")
	prep.creature_data[0] = CREATURES[0]
	prep.creature_levels[0] = 2
	prep._render_creature_slot(0)
	prep._show_shop_sell_target(0)
	_assert(prep.shop_sell_overlay.visible, "dragging a creature must reveal the shop sell overlay")
	_assert(prep.shop_sell_label.text == "售出  +2G", "sell overlay must show the star-adjusted sale value")
	await _capture("res://battle_prep_shop_sell.png")
	prep._clear_drag_exchange_targets()

	_assert(prep.shop_buttons.size() == 5, "shop must contain exactly five cards")
	_assert(is_equal_approx(prep.shop_buttons[0].position.y, 574.0), "card row must use the Aseprite-authored vertical offset")
	_assert(not prep.shop_hp_badges[0].visible and not prep.shop_special_badges[0].visible, "legacy red and blue stat boxes must stay hidden")
	_assert(prep.shop_element_icon_backgrounds[0].texture != null, "attribute frame must come from the exported Aseprite asset")
	_assert(prep.coin_label.text == "12G", "coin label must reflect GameState immediately")
	_assert(prep.health_icons.size() == 3, "run health must contain three heart icons")
	_assert(prep.shop_card_outlines[0].get_theme_stylebox("panel").border_color == prep.SHOP_RARITY_COLORS[0], "normal rarity border color")
	_assert(prep.shop_card_outlines[1].get_theme_stylebox("panel").border_color == prep.SHOP_RARITY_COLORS[1], "rare rarity border color")
	_assert(prep.shop_card_outlines[2].get_theme_stylebox("panel").border_color == prep.SHOP_RARITY_COLORS[2], "epic rarity border color")
	_assert(prep.shop_card_outlines[0].get_theme_stylebox("panel").border_width_left == 4, "rarity border must extend one pixel farther inward")
	_assert(prep.shop_card_outlines[0].get_theme_stylebox("panel").corner_radius_top_left == 0, "rarity border corners must not leak white pixels")
	_assert(prep.shop_trait_backgrounds[0].texture is GradientTexture2D, "creature cards must use a rarity gradient")
	_assert(prep.shop_trait_backgrounds[4].texture is GradientTexture2D, "item cards must use a rarity gradient")
	_assert(prep.shop_trait_backgrounds[4].visible, "item rarity background must remain visible")
	_assert(not prep.shop_element_icon_backgrounds[4].visible and not prep.shop_extra_icon_backgrounds[4].visible and not prep.shop_race_icon_backgrounds[4].visible, "item cards must not show trait slots")
	_assert(prep.lock_label.get_theme_font("font") == prep.source_han_font, "lock text must use the same UI font as the shop header")
	_assert(is_equal_approx(prep.coin_label.position.y + prep.coin_label.size.y * 0.5, 551.0), "coin amount must align to the shop header center")
	_assert(is_equal_approx(prep.shop_star_rows[0].position.x, 8.0), "shop stars must be placed at the top-left")
	_assert(is_equal_approx(prep.creature_star_rows[0].position.x, 7.0), "bench stars must be placed at the top-left")
	_assert(is_equal_approx(prep.creature_star_rows[4].position.x, 5.0), "team stars must be placed at the top-left")
	_assert(prep.creature_element_icons[0].position.x < prep.creature_hp_badges[0].position.x, "bench traits must be left of the stat badges")
	_assert(prep.creature_element_icons[4].position.x < prep.creature_hp_badges[4].position.x, "team traits must match the shop's left-to-right content order")
	prep.shop_data[0] = {}
	prep._render_shop_card(0)
	_assert(not prep.shop_attribute_layers[0].visible, "sold cards must hide the attribute layer")
	_assert(prep.shop_sold_out_shades[0].visible, "sold cards must show a black shade")
	_assert(prep.shop_sold_out_overlays[0].size == Vector2(80, 30), "sold-out stamp must be scaled down by 50 percent")
	_assert(is_equal_approx(prep.shop_sold_out_overlays[0].rotation, deg_to_rad(-30.0)), "sold-out stamp must rotate 30 degrees to the left")
	await _capture("res://battle_prep_shop_sold.png")

	GameState.add_accessory(ITEM_CATALOG.entry_for_id("accessory", 2))
	GameState.add_accessory(ITEM_CATALOG.entry_for_id("accessory", 79))
	GameState.add_item(ITEM_CATALOG.entry_for_id("item", 1))
	GameState.add_item(ITEM_CATALOG.entry_for_id("item", 109))
	prep._open_inventory()
	await get_tree().process_frame
	_assert(prep.inventory_popup.item_grid.columns == 3, "inventory must show three entries per row")
	await _capture("res://inventory_popup_polished.png")
	prep.inventory_popup.queue_free()
	await get_tree().process_frame

	GameState.mark_creature_seen(CREATURES[0])
	prep._open_dex()
	await get_tree().process_frame
	var dex_index: int = prep.dex_overlay.CREATURES.find(CREATURES[0])
	prep.dex_overlay._select_creature(dex_index)
	prep.dex_overlay._on_level_pressed(2)
	_assert(prep.dex_overlay.level_buttons[2].disabled, "selected dex level must move to the pressed button")
	await _capture("res://dex_overlay_polished.png")
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
