extends Node

const PREP_SCENE: PackedScene = preload("res://battle_prep.tscn")
const ITEM_CATALOG = preload("res://scripts/item_catalog.gd")
const CREATURE_CATALOG = preload("res://scripts/creature_catalog.gd")
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
		_creature_entry(CREATURES[3], 4),
		ITEM_CATALOG.entry_for_id("item", 109),
	]
	prep.shop_data = entries
	for index in prep.shop_data.size():
		prep._render_shop_card(index)
	prep.creature_data[4] = CREATURES[0]
	prep.creature_levels[4] = 1
	prep._render_creature_slot(4)
	prep._update_synergies()
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
	var inspected_rarity := CREATURE_CATALOG.rarity_for_texture(CREATURES[2])
	_assert(prep.card_tooltip_rarity.get_theme_color("font_color") == prep.SHOP_RARITY_COLORS[inspected_rarity], "detail rarity text must match the card rarity color")
	await _capture("res://battle_prep_shop_detail.png")
	inspect_event.pressed = false
	prep._on_shop_card_gui_input(inspect_event, 2)
	_assert(not CursorManager.inspecting_card, "releasing right-click must restore the normal cursor")
	prep._show_item_card_tooltip(entries[4])
	_assert(prep.card_tooltip.size == Vector2(292, 206), "item details must use the Aseprite-authored aspect ratio")
	_assert(prep.item_tooltip_effect.text.contains("[color=#4f83c2]"), "item values must be highlighted in blue")
	await _capture("res://battle_prep_item_detail.png")
	prep._hide_card_tooltip()
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
	_assert(prep.health_icons[0].position == Vector2(38, 17), "run health must stay at the top-left reference position")
	_assert(not prep.shop_card_outlines[0].visible, "shop cards must not draw a second outer outline")
	_assert(prep.shop_outer_layers[0].visible, "shop cards must use the exported pixel frame")
	_assert(prep.shop_trait_backgrounds[0].texture is GradientTexture2D, "creature cards must use a rarity gradient")
	_assert((prep.shop_trait_backgrounds[0].texture as GradientTexture2D).width == 16, "rarity gradient must use pixel-sized color steps")
	_assert(prep.shop_trait_backgrounds[4].texture is GradientTexture2D, "item cards must use a rarity gradient")
	_assert(prep.shop_trait_backgrounds[4].visible, "item rarity background must remain visible")
	var epic_gradient := (prep.shop_trait_backgrounds[4].texture as GradientTexture2D).gradient.colors
	_assert(epic_gradient[1] == prep.SHOP_RARITY_COLORS[3].lightened(0.34), "epic items must preserve the purple global rarity in the strengthened gradient")
	_assert(not prep.shop_name_labels[0].text.is_empty() and prep.shop_name_labels[0].z_index > prep.shop_attribute_layers[0].z_index, "shop names must stay visible above the card frame")
	_assert(prep.shop_price_labels[0].text == "$1" and prep.shop_price_labels[0].z_index > prep.shop_attribute_layers[0].z_index, "shop prices must stay visible above the card frame")
	_assert(not prep.shop_element_icon_backgrounds[4].visible and not prep.shop_extra_icon_backgrounds[4].visible and not prep.shop_race_icon_backgrounds[4].visible, "item cards must not show trait slots")
	_assert(prep.lock_label.get_theme_font("font").resource_path.ends_with("SourceHanSansSC-Heavy.otf"), "lock text must use the global Source Han Heavy UI font")
	_assert(is_equal_approx(prep.coin_label.position.y + prep.coin_label.size.y * 0.5, 551.0), "coin amount must align to the shop header center")
	_assert(is_equal_approx(prep.shop_star_rows[0].position.x, 8.0), "shop stars must be placed at the top-left")
	_assert(not prep.shop_star_rows[0].get_child(0).visible, "one-star cards must not display a star")
	_assert(is_equal_approx(prep.creature_star_rows[0].position.x, 7.0), "bench stars must be placed at the top-left")
	_assert(is_equal_approx(prep.creature_star_rows[4].position.x, 5.0), "team stars must be placed at the top-left")
	_assert(not prep.creature_hp_badges[0].visible and not prep.creature_special_badges[0].visible, "bench cards must remove red and blue stat boxes")
	_assert(prep.creature_element_icon_backgrounds[0].visible, "bench traits must use colored icon frames")
	_assert(prep.creature_rarity_frames[0].visible, "bench cards must show their rarity frame")
	_assert(prep.creature_star_rows[0].get_child(0).visible and prep.creature_star_rows[0].get_child(1).visible, "two-star creatures must show exactly two stars")
	_assert(not prep.creature_star_rows[0].get_child(2).visible, "two-star creatures must not show a third star")
	var synergy_texture := prep.synergy_icons["自然"].texture as Texture2D
	_assert(synergy_texture != null, "synergy icons must load after importing the project")
	_assert(prep.synergy_icons["自然"].modulate == Color.WHITE, "synergy masks must stay white above the new coloured icon cell")
	_assert(prep.synergy_icon_cells["自然"].color == CREATURE_CATALOG.synergy_color("自然"), "synergy icon cells must use their configured colour")
	_assert(prep.synergy_row_frames["自然"].size == Vector2(282, 30), "synergy rows must match the compact reference proportions")
	_assert(prep.synergy_count_labels["自然"].text == "1/5", "synergy rows must report current count against the final threshold")
	_assert(prep.synergy_count_labels["植物"].text == "1/5", "three-tier synergies must use their final threshold, not tier count, as denominator")
	_assert(prep.synergy_count_labels["自然"].get_theme_color("font_color") == Color.WHITE, "synergy counts must use white text")
	var spirit_thresholds: Array = CREATURE_CATALOG.synergy_thresholds("灵体")
	_assert(spirit_thresholds == [2, 3, 4], "spirit synergy must keep three effects at thresholds 2, 3 and 4")
	_assert(not prep.synergy_step_boxes["自然"][0].visible, "a synergy below its first threshold must not show a tier marker")
	prep._show_synergy_tooltip("植物")
	_assert(prep.synergy_tooltip_tier_rows[2].visible, "three-tier synergy details must show all tiers")
	_assert(not prep.synergy_tooltip_tier_fills[0].visible, "inactive synergy tiers must keep their circles hollow")
	_assert(prep.synergy_tooltip_tier_texts[0].text.contains("[color=#"), "synergy effect values must use the trait colour")
	await _capture("res://synergy_tooltip_polished.png")
	prep._hide_synergy_tooltip()
	prep.shop_data[0] = {}
	prep._render_shop_card(0)
	_assert(not prep.shop_attribute_layers[0].visible, "sold cards must hide the attribute layer")
	_assert(prep.shop_sold_out_shades[0].visible, "sold cards must show a black shade")
	_assert(prep.shop_sold_out_overlays[0].size == Vector2(80, 30), "sold-out stamp must be scaled down by 50 percent")
	_assert(is_equal_approx(prep.shop_sold_out_overlays[0].rotation, deg_to_rad(-30.0)), "sold-out stamp must rotate 30 degrees to the left")
	_assert(is_equal_approx(prep.shop_sold_out_overlays[0].position.y + prep.shop_sold_out_overlays[0].size.y * 0.5, 50.0), "sold-out stamp must be centered in the gray portrait area")
	await _capture("res://battle_prep_shop_sold.png")

	GameState.add_accessory(ITEM_CATALOG.entry_for_id("accessory", 2))
	GameState.add_accessory(ITEM_CATALOG.entry_for_id("accessory", 79))
	GameState.add_item(ITEM_CATALOG.entry_for_id("item", 1))
	GameState.add_item(ITEM_CATALOG.entry_for_id("item", 109))
	prep._open_inventory()
	await get_tree().process_frame
	_assert(prep.inventory_popup.item_grid.columns == 3, "inventory must show three entries per row")
	await _capture("res://inventory_popup_polished.png")
	var inventory_detail_entry := ITEM_CATALOG.entry_for_id("accessory", 2)
	prep.inventory_popup._show_item_info(inventory_detail_entry, "叠加上限 1")
	_assert(prep.inventory_popup.item_info_effect_rich.text.contains("[color=#4f83c2]"), "inventory detail values must be blue")
	await _capture("res://inventory_item_detail.png")
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
	prep.dex_overlay._on_tab_pressed(2)
	await get_tree().process_frame
	await _capture("res://dex_items_centered.png")
	print("BATTLE_PREP_SHOP_VISUAL_TEST: PASS")
	get_tree().quit()


func _creature_entry(path: String, rarity: int) -> Dictionary:
	return {"kind": "creature", "path": path, "rarity": rarity, "price": rarity + 1}


func _capture(path: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await get_tree().process_frame
	await get_tree().process_frame
	var error := get_viewport().get_texture().get_image().save_png(ProjectSettings.globalize_path(path))
	_assert(error == OK, "failed to save %s" % path)


func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	push_error("BATTLE_PREP_SHOP_VISUAL_TEST: %s" % message)
	get_tree().quit(1)
