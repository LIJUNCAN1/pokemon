extends Node

const PREP_SCENE: PackedScene = preload("res://battle_prep.tscn")
const ITEM_CATALOG = preload("res://scripts/item_catalog.gd")
const CREATURE_CATALOG = preload("res://scripts/creature_catalog.gd")
const RARITY_TAG = preload("res://scripts/rarity_tag_style.gd")
const REFERENCE_CREATURE := "res://素材/宝可梦图/1 (1).png"
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
	for rarity_index in RARITY_TAG.KEYS.size():
		var tag_texture := RARITY_TAG.texture(rarity_index)
		var expected_tag_size := Vector2(104, 53) if rarity_index == 2 else Vector2(834, 449)
		_assert(tag_texture != null and tag_texture.get_size() == expected_tag_size, "rarity tag must retain its authored native size")
		var tag_image := tag_texture.get_image()
		_assert(tag_image.get_pixel(0, 0).a == 0.0 and tag_image.get_pixel(tag_image.get_width() - 1, tag_image.get_height() - 1).a == 0.0, "shared rarity tags must have transparent screenshot backgrounds")

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
	for formation_index in 6:
		var slot_index := formation_index + 4
		prep.creature_data[slot_index] = CREATURES[formation_index % CREATURES.size()]
		prep.creature_levels[slot_index] = formation_index % 3 + 1
		prep._render_creature_slot(slot_index)
	prep._update_synergies()
	prep._sync_coins()
	await get_tree().create_timer(0.9).timeout
	var original_reference_entry: Dictionary = prep.shop_data[0].duplicate(true)
	prep.shop_data[0] = _creature_entry(REFERENCE_CREATURE, 0)
	prep._render_shop_card(0)
	await _capture("res://battle_prep_shop_final.png")
	prep.shop_data[0] = original_reference_entry
	prep._render_shop_card(0)
	for slot_index in range(5, 10):
		prep.creature_data[slot_index] = ""
		prep.creature_levels[slot_index] = 0
		prep._render_creature_slot(slot_index)
	prep._update_synergies()

	prep._on_lock_pressed()
	_assert(not prep.shop_star_rows[0].visible, "the compact Aseprite card intentionally omits shop stars")
	await _capture("res://battle_prep_shop_locked.png")
	prep._on_lock_pressed()
	await get_tree().create_timer(0.2).timeout
	_assert(prep.shop_lock_overlays[0].visible, "unlock animation must remain visible while fading")
	_assert(prep.shop_lock_overlays[0].modulate.a > 0.0 and prep.shop_lock_overlays[0].modulate.a < 1.0, "unlock animation alpha must fade gradually")
	await _capture("res://battle_prep_shop_unlocking.png")

	var inspect_event := InputEventMouseButton.new()
	inspect_event.button_index = MOUSE_BUTTON_RIGHT
	inspect_event.pressed = true
	prep._on_shop_card_gui_input(inspect_event, 3)
	_assert(prep.card_tooltip.visible, "right-click detail panel must be visible")
	_assert(prep.card_tooltip.size.is_equal_approx(Vector2(369, 305)), "creature details must use the 1229x1017 reference aspect ratio")
	_assert(prep.card_tooltip.get_theme_stylebox("panel").border_color == Color.BLACK, "creature details must retain the black outer frame")
	_assert(prep.card_tooltip_skill_icon.texture != null, "creature details must show the melee/ranged icon in the lower-left skill slot")
	_assert(prep.card_tooltip.find_children("*", "ProgressBar", true, false).is_empty(), "creature details must not recreate the removed health bar")
	_assert(CursorManager.inspecting_card, "right-click must switch to the detail cursor")
	_assert(prep.card_tooltip_rarity.visible and not prep.card_tooltip_rarity.text.is_empty(), "creature detail top-right must show the rarity badge")
	_assert(not prep.card_tooltip_price.visible, "the new detail reference removes the price label")
	_assert(prep.card_tooltip_element_icon.material is ShaderMaterial and prep.card_tooltip_race_icon.material is ShaderMaterial, "detail synergy icons must use solid trait-color fills")
	_assert(prep.card_tooltip_name.get_theme_color("font_color") == Color("252b35"), "creature name must use black text")
	var inspected_rarity: int = CREATURE_CATALOG.rarity_for_texture(CREATURES[3])
	_assert(prep.card_tooltip_rarity.get_theme_color("font_color") == RARITY_TAG.text_color(inspected_rarity), "right-click rarity text must use its sampled quality text color")
	_assert(prep.card_tooltip_name.get_theme_color("font_shadow_color") == Color.TRANSPARENT and prep.card_tooltip_rarity.get_theme_color("font_shadow_color") == Color.TRANSPARENT, "name and rarity text must not have shadows")
	_assert(prep.card_tooltip_name.get_theme_constant("outline_size") == 0 and prep.card_tooltip_rarity.get_theme_constant("outline_size") == 0, "name and rarity text must not have outlines")
	_assert(is_equal_approx(prep.card_tooltip_name.position.y + prep.card_tooltip_name.size.y * 0.5, prep.card_tooltip_rarity.position.y + prep.card_tooltip_rarity.size.y * 0.5), "name and rarity must be centered in the header row")
	var header_center: float = (4.0 + prep.card_tooltip_header_divider.position.y) * 0.5
	_assert(is_equal_approx(prep.card_tooltip_name.position.y + prep.card_tooltip_name.size.y * 0.5, header_center), "header content must be centered between the black top edge and lower divider")
	_assert(prep.card_tooltip_element.get_theme_color("font_color") == Color.WHITE and prep.card_tooltip_race.get_theme_color("font_color") == Color.WHITE, "both trait names must use white text")
	_assert(prep.card_tooltip_clock_icon.texture == prep.CHARACTER_INFO_TIME_ICON, "attack interval must use the supplied time icon")
	_assert(prep.card_tooltip_cooldown_caption.position.x == 308.0 and prep.card_tooltip_role.position.x == 308.0, "attack interval caption and value must include the additional five-pixel left shift")
	_assert(is_zero_approx(prep.card_tooltip_role.get_theme_color("font_shadow_color").a) and is_zero_approx(prep.card_tooltip_cooldown_caption.get_theme_color("font_shadow_color").a), "attack interval labels must not have shadows")
	_assert(is_zero_approx(prep.card_tooltip_skill_text.get_theme_color("font_shadow_color").a), "skill description must not have a shadow")
	_assert(is_equal_approx(prep.card_tooltip_skill_name.position.y + prep.card_tooltip_skill_name.size.y * 0.5, prep.card_tooltip_skill_damage.position.y + prep.card_tooltip_skill_damage.size.y * 0.5), "skill name and maximum-damage badge must share one vertical center")
	_assert(is_equal_approx(prep.card_tooltip_skill_damage.position.y + prep.card_tooltip_skill_damage.size.y * 0.5, prep.card_tooltip_clock_icon.position.y + prep.card_tooltip_clock_icon.size.y * 0.5), "maximum damage and attack interval must share one vertical center")
	var cooldown_group_center: float = (prep.card_tooltip_cooldown_caption.position.y + prep.card_tooltip_role.position.y + prep.card_tooltip_role.size.y) * 0.5
	_assert(is_equal_approx(cooldown_group_center, prep.card_tooltip_skill_name.position.y + prep.card_tooltip_skill_name.size.y * 0.5), "attack-interval text group must be centered with the skill name")
	_assert(is_equal_approx(prep.card_tooltip_skill_text.position.x, prep.card_tooltip_skill_name.position.x), "skill description must align with the skill-name left edge")
	_assert(prep.card_tooltip_skill_text.autowrap_mode != TextServer.AUTOWRAP_OFF, "long skill descriptions must wrap")
	_assert(prep.card_tooltip_skill_text.position.x + prep.card_tooltip_skill_text.size.x < prep.card_tooltip_clock_icon.position.x, "wrapped skill text must reserve space before the cooldown group")
	_assert(prep.card_tooltip_clock_icon.position.x + prep.card_tooltip_clock_icon.size.x < prep.card_tooltip_cooldown_caption.position.x, "time icon and attack-interval caption must not overlap")
	_assert(is_equal_approx(prep.card_tooltip_shadow.position.x + prep.card_tooltip_shadow.size.x * 0.5, prep.card_tooltip_portrait_panel.position.x + prep.card_tooltip_portrait_panel.size.x * 0.5), "portrait shadow must be centered beneath the creature")
	_assert(prep.card_tooltip_shadow.size.x > prep.card_tooltip_shadow.size.y * 8.0, "portrait shadow must be a flat oval")
	var expected_damage_x: float = prep.card_tooltip_skill_name.position.x + prep.card_tooltip_skill_name.size.x + prep.CHARACTER_INFO_DAMAGE_GAP
	_assert(is_equal_approx(prep.card_tooltip_skill_damage.position.x, expected_damage_x), "maximum-damage badge must keep a fixed gap after the measured skill-name width")
	var skill_group_center: float = (prep.card_tooltip_skill_backdrop.position.y + prep.card_tooltip_active_label.position.y + prep.card_tooltip_active_label.size.y) * 0.5
	var bottom_panel_center: float = prep.card_tooltip_bottom_panel.position.y + prep.card_tooltip_bottom_panel.size.y * 0.5
	_assert(is_equal_approx(skill_group_center, bottom_panel_center), "role icon, frame and active-skill label must be vertically centered as one group")
	await _capture("res://battle_prep_shop_detail.png")
	prep._show_card_tooltip(CREATURES[1], 1)
	var rare_badge_style := prep.card_tooltip_rarity.get_theme_stylebox("normal") as StyleBoxTexture
	_assert(rare_badge_style != null and rare_badge_style.texture.resource_path.ends_with("/rare.png"), "rare detail must use the shared transparent rare tag")
	_assert(prep.card_tooltip_rarity.horizontal_alignment == HORIZONTAL_ALIGNMENT_CENTER and prep.card_tooltip_rarity.vertical_alignment == VERTICAL_ALIGNMENT_CENTER, "rarity text must be centered inside its badge")
	await _capture("res://battle_prep_shop_detail_rare.png")
	var common_texture := ""
	for texture_path in CREATURE_CATALOG.all_textures():
		if CREATURE_CATALOG.rarity_for_texture(texture_path) == 0:
			common_texture = texture_path
			break
	_assert(not common_texture.is_empty(), "catalog must contain a common creature for rarity-frame validation")
	prep._show_card_tooltip(common_texture, 1)
	var common_badge_style := prep.card_tooltip_rarity.get_theme_stylebox("normal") as StyleBoxTexture
	_assert(common_badge_style != null and common_badge_style.texture.resource_path.ends_with("/common.png"), "common detail must use the shared transparent common tag")
	await _capture("res://battle_prep_shop_detail_common.png")
	inspect_event.pressed = false
	prep._on_shop_card_gui_input(inspect_event, 3)
	_assert(not CursorManager.inspecting_card, "releasing right-click must restore the normal cursor")
	prep._show_item_card_tooltip(entries[4])
	_assert(prep.card_tooltip.size == Vector2(292, 206), "item details must use the Aseprite-authored aspect ratio")
	_assert(prep.item_tooltip_effect.text.contains("[color=#4f83c2]"), "item values must be highlighted in blue")
	_assert(prep.item_tooltip_type.position.x == 155.0, "item type icon and label must include the additional five-pixel right shift")
	_assert(prep.item_tooltip_effect.position.x == 157.0 and prep.item_tooltip_rule.position.x == 157.0 and prep.item_tooltip_divider.position.x == 157.0, "item effect, divider and stack-limit copy must include the additional five-pixel right shift")
	_assert(prep.card_tooltip_name.get_theme_color("font_color") == Color.WHITE, "item detail names must use white text on the dark header")
	var item_rarity_index := clampi(int(entries[4]["rarity"]), 0, prep.ITEM_CATALOG.RARITY_NAMES.size() - 1)
	var item_display_rarity_index: int = prep._item_display_rarity_index(item_rarity_index)
	_assert(prep.card_tooltip_rarity.get_theme_color("font_color") == RARITY_TAG.text_color(item_display_rarity_index), "item rarity text must use the sampled tag text color")
	_assert(prep.card_tooltip_name.position == Vector2(18, 12), "item name must retain the measured reference origin")
	_assert(prep.card_tooltip_rarity.position == Vector2(232, 16) and prep.card_tooltip_rarity.size == Vector2(43, 22), "item rarity must retain the Aseprite-authored badge bounds")
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
	_assert(is_equal_approx(prep.shop_buttons[0].position.y, 584.0), "card row must use the compact Aseprite vertical offset")
	_assert(is_equal_approx(prep.shop_buttons[0].size.x / prep.shop_buttons[0].size.y, 115.0 / 94.0), "shop card must preserve the authored 115x94 aspect ratio")
	_assert(not prep.shop_hp_badges[0].visible and not prep.shop_special_badges[0].visible, "legacy red and blue stat boxes must stay hidden")
	_assert(prep.shop_element_icon_backgrounds[0].texture != null, "attribute frame must come from the exported Aseprite asset")
	_assert(prep.coin_label.text == "12G", "coin label must reflect GameState immediately")
	var expected_price_y: float = prep.shop_buttons[0].size.y * 72.0 / 94.0 + 0.75
	_assert(is_equal_approx(prep.shop_price_labels[0].position.y, expected_price_y), "shop coin numerals must use the adjusted vertical baseline")
	_assert(prep.health_icons.size() == 3, "run health must contain three heart icons")
	_assert(prep.health_icons[0].position == Vector2(38, 17), "run health must stay at the top-left reference position")
	_assert(not prep.shop_card_outlines[0].visible, "shop cards must not draw a second outer outline")
	_assert(not prep.shop_outer_layers[0].visible, "legacy shop frames must be removed")
	_assert(prep.shop_attribute_layers[0].texture.resource_path == prep.SHOP_CARD_ASSETS[0], "shop cards must use the newly exported Aseprite frame for their rarity")
	_assert(prep.shop_trait_backgrounds[0].texture is GradientTexture2D, "creature cards must use a rarity gradient")
	var shop_gradient := prep.shop_trait_backgrounds[0].texture as GradientTexture2D
	_assert(shop_gradient.width == 256 and shop_gradient.height == 256, "rarity gradient must render as a continuous straight gradient")
	_assert(shop_gradient.fill_from == Vector2.ZERO and shop_gradient.fill_to == Vector2.ONE, "rarity gradient must run diagonally from top-left to bottom-right")
	_assert(shop_gradient.gradient.colors[0] == prep.SHOP_RARITY_COLORS[0].darkened(0.28), "rarity gradient top-left must use the darker rarity color")
	_assert(shop_gradient.gradient.colors[-1] == prep.SHOP_RARITY_COLORS[0].lightened(0.38), "rarity gradient bottom-right must use the lighter rarity color")
	_assert(prep.shop_trait_backgrounds[4].texture is GradientTexture2D, "item cards must use a rarity gradient")
	_assert(prep.shop_trait_backgrounds[4].visible, "item rarity background must remain visible")
	var epic_gradient := (prep.shop_trait_backgrounds[4].texture as GradientTexture2D).gradient.colors
	_assert(epic_gradient[1] == prep.SHOP_RARITY_COLORS[3].lightened(0.38), "epic items must preserve the purple global rarity in the strengthened gradient")
	_assert(not prep.shop_name_labels[0].text.is_empty() and prep.shop_name_labels[0].z_index > prep.shop_attribute_layers[0].z_index, "shop names must stay visible above the card frame")
	_assert(prep.shop_price_labels[0].text == "1" and prep.shop_price_labels[0].z_index > prep.shop_attribute_layers[0].z_index, "shop prices must stay visible above the card frame without a duplicated currency symbol")
	_assert(prep.shop_coin_icons[0].visible, "shop prices must use the coin icon from the reference")
	_assert(is_equal_approx(prep.shop_coin_icons[0].position.x, prep.shop_buttons[0].size.x - 28.666667) and is_equal_approx(prep.shop_price_labels[0].position.x, prep.shop_buttons[0].size.x - 17.5), "coin and price must align as one compact right-hand group")
	_assert(is_equal_approx(prep.shop_name_labels[0].position.x, 7.0) and is_equal_approx(prep.shop_name_labels[0].position.y, prep.shop_buttons[0].size.y * 72.0 / 94.0), "shop name must retain the pixel-measured reference origin")
	_assert(not prep.shop_element_labels[0].text.is_empty() and not prep.shop_secondary_trait_labels[0].text.is_empty(), "creature shop cards must show two compact trait rows")
	_assert(prep.shop_element_icon_backgrounds[0].position == Vector2(8, 46) and prep.shop_extra_icon_backgrounds[0].position.is_equal_approx(Vector2(8, 69.416667)), "trait icon-and-text groups must occupy the pixel-measured reference rows")
	_assert(prep.shop_element_labels[0].position == Vector2(28.5, 42) and prep.shop_secondary_trait_labels[0].position.is_equal_approx(Vector2(28.5, 65.666667)), "trait text must use the pixel-measured reference origins")
	_assert(prep.shop_sprites[0].position.is_equal_approx(Vector2(24.4, -14.85)) and prep.shop_sprites[0].size.is_equal_approx(Vector2(121.2, 108.7)), "creature art must use the fitted reference placement")
	_assert(prep.shop_portrait_clips[0].clip_contents, "portrait pixels outside the authored inner black frame must be clipped")
	_assert(prep.shop_sprites[0].position.x + prep.shop_sprites[0].size.x > prep.shop_portrait_clips[0].size.x, "oversized creature art must intentionally extend into the clip boundary")
	_assert(not prep.shop_element_icon_backgrounds[4].visible and not prep.shop_extra_icon_backgrounds[4].visible and not prep.shop_race_icon_backgrounds[4].visible, "item cards must not show trait slots")
	_assert(prep.lock_label.get_theme_font("font").resource_path.ends_with("SourceHanSansSC-Heavy.otf"), "lock text must use the global Source Han Heavy UI font")
	_assert(is_equal_approx(prep.coin_label.position.y + prep.coin_label.size.y * 0.5, 551.0), "coin amount must align to the shop header center")
	_assert(not prep.shop_star_rows[0].visible, "compact shop cards must not add a star over the authored layout")
	for shop_roll_index in 200:
		var rolled_entries: Array[Dictionary] = prep._roll_shop_entries(true)
		var non_creature_count := 0
		for rolled_entry in rolled_entries:
			if not rolled_entry.is_empty() and String(rolled_entry.get("kind", "creature")) != "creature":
				non_creature_count += 1
		_assert(non_creature_count <= 1, "a shop refresh must contain at most one item or accessory")
	_assert(prep.find_children("*", "Label", true, false).all(func(label): return (label as Label).text != "商店"), "shop title must be removed so rarity probabilities can occupy its row")
	_assert(is_equal_approx(prep.creature_star_rows[0].position.x, 7.0), "bench stars must be placed at the top-left")
	_assert(prep.get_node_or_null("PreparationGrassBackground") != null, "preparation must use the supplied full-screen grass background")
	_assert(prep.get_node_or_null("FormationTopPlatform") != null and prep.get_node_or_null("FormationBottomPlatform") != null, "team cards must be replaced by the battle formation platforms")
	_assert(prep.get_node("FormationTopPlatform").position == Vector2(170, 307) + prep.PREP_FORMATION_GROUP_OFFSET and prep.get_node("FormationBottomPlatform").position == Vector2(135, 410) + prep.PREP_FORMATION_GROUP_OFFSET, "the complete battle formation must receive one shared screen-centering offset")
	var formation_left: float = prep.get_node("FormationBottomPlatform").position.x
	var formation_right: float = prep.get_node("FormationTopPlatform").position.x + prep.get_node("FormationTopPlatform").size.x
	_assert(absf((formation_left + formation_right) * 0.5 - prep.DESIGN_SIZE.x * 0.5) <= 0.5, "the complete formation platform bounds must be centered on screen")
	_assert(prep.creature_buttons[4].get_meta("formation_slot", false), "team entries must use formation slots")
	_assert(prep.creature_buttons[4].size == prep.PREP_FORMATION_SLOT_SIZE, "formation hitboxes must keep the measured battle-sized bounds")
	_assert(prep.creature_sprites[4].size == prep.PREP_FORMATION_SPRITE_SIZE, "formation portraits must reuse the complete battle-scene size without cropping")
	_assert(prep.creature_buttons[4].position + prep.creature_sprites[4].position == prep.PREP_FORMATION_TOP_CENTERS[0] + prep.PREP_FORMATION_GROUP_OFFSET + Vector2(-38, -66), "portraits and platforms must share the same offset while preserving the exact battle-scene fighter anchor")
	_assert(prep.creature_buttons.slice(4, 10).all(func(slot): return not slot.clip_contents), "formation hitboxes must never crop creature portraits")
	_assert(not prep.creature_trait_backgrounds[4].visible and not prep.creature_rarity_frames[4].visible, "formation creatures must not retain the old card background or frame")
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
	prep.synergy_current_counts["植物"] = 2
	prep._show_synergy_tooltip("植物")
	_assert(prep.synergy_tooltip_tier_rows[2].visible, "three-tier synergy details must show all tiers")
	_assert(prep.synergy_tooltip_tier_fills[0].visible and not prep.synergy_tooltip_tier_circles[0].visible, "active synergy tiers must use a solid circle without the old outer frame")
	_assert(not prep.synergy_tooltip_tier_fills[1].visible and prep.synergy_tooltip_tier_circles[1].visible, "inactive synergy tiers must keep their circles hollow")
	_assert(prep.synergy_tooltip_tier_texts[0].text.contains("[color=#"), "synergy effect values must use the trait colour")
	_assert(prep.synergy_tooltip.size == Vector2(320, 243), "synergy drawer must preserve its original compact size")
	_assert(prep.synergy_tooltip_content.scale == Vector2.ONE, "synergy content must not change the original drawer scale")
	_assert(prep.synergy_tooltip_icon.position == Vector2(22, 15) and prep.synergy_tooltip_icon.size == Vector2(25, 25), "synergy header icon must match the adjusted reference bounds")
	_assert(prep.synergy_tooltip_count.position.x == 16.0 and prep.synergy_tooltip_count.get_theme_color("font_color") == Color.WHITE, "current synergy count must move left one pixel and use white text")
	_assert(prep.synergy_tooltip.get_node_or_null("IconShadow") == null and prep.synergy_tooltip.get_node_or_null("IconBorder") == null and prep.synergy_tooltip.get_node_or_null("IconFill") == null, "synergy header must remove the old icon frame layers")
	_assert(prep.synergy_tooltip_tier_rows[1].position.y - prep.synergy_tooltip_tier_rows[0].position.y == 48.0, "synergy tiers must keep the scaled reference vertical rhythm")
	_assert(prep.synergy_tooltip_tier_numbers[0].position.x == 20.0, "tier badge numbers must align with the compact reference badge")
	_assert(prep.synergy_tooltip_tier_badges[0].position.y == 5.0 and prep.synergy_tooltip_tier_badges[2].position.y == 5.0, "all tier number frames must move down one pixel")
	_assert((prep.synergy_tooltip_tier_circles[1].material as ShaderMaterial).get_shader_parameter("tint_color") == Color.WHITE, "inactive synergy circles must use white instead of purple")
	_assert(prep.synergy_tooltip_tier_rows[0].position.x == 20.0 and prep.synergy_tooltip_tier_texts[0].position.x == 44.0, "synergy tier group and copy must align with the adjusted reference")
	_assert(prep.synergy_tooltip_tier_texts[0].position.y == 0.0 and prep.synergy_tooltip_tier_texts[1].position.y == 6.0, "single-line synergy effects must be vertically centered while wrapped effects stay top-aligned")
	await _capture("res://synergy_tooltip_polished.png")
	prep._hide_synergy_tooltip()
	prep.shop_data[0] = {}
	prep._render_shop_card(0)
	_assert(prep.shop_attribute_layers[0].visible, "sold cards must retain the authored card frame beneath the shade")
	_assert(prep.shop_sold_out_shades[0].visible, "sold cards must show a black shade")
	_assert(prep.shop_sold_out_overlays[0].size == Vector2(80, 30), "sold-out stamp must be scaled down by 50 percent")
	_assert(is_equal_approx(prep.shop_sold_out_overlays[0].rotation, deg_to_rad(-30.0)), "sold-out stamp must rotate 30 degrees to the left")
	_assert(is_equal_approx(prep.shop_sold_out_overlays[0].position.y + prep.shop_sold_out_overlays[0].size.y * 0.5, prep.shop_buttons[0].size.y * 72.0 / 94.0 * 0.5), "sold-out stamp must be centered in the portrait area")
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
	_assert(prep.dex_overlay.sidebar_root == null, "reference dex layout must remove the legacy left sidebar")
	for tab_index in prep.dex_overlay.tab_buttons.size():
		_assert(prep.dex_overlay.tab_buttons[tab_index].text == prep.dex_overlay.TAB_NAMES[tab_index] and prep.dex_overlay.tab_buttons[tab_index].icon == null, "dex category tabs must contain text only")
	_assert(prep.dex_overlay.card_trophy_icons.all(func(icon): return not icon.visible) and prep.dex_overlay.card_medal_icons.all(func(icon): return not icon.visible) and prep.dex_overlay.card_star_icons.all(func(icon): return not icon.visible), "creature cards must remove the three achievement marks")
	var first_card_center: float = prep.dex_overlay.creature_cards[0].size.x * 0.5
	var first_sprite_center: float = prep.dex_overlay.card_creature_sprites[0].position.x + prep.dex_overlay.card_creature_sprites[0].size.x * 0.5
	_assert(is_equal_approx(first_card_center, first_sprite_center), "creature silhouettes must be horizontally centered in their cards")
	_assert(prep.dex_overlay.detail_description_title.text.contains("最高") and prep.dex_overlay.detail_description_title.text.contains("点伤害"), "creature detail must show the skill name and maximum damage")
	_assert(prep.dex_overlay.detail_description.text.contains("[color=#"), "creature skill values must be highlighted with the primary element color")
	var selected_rarity: int = prep.dex_overlay.CATALOG.rarity_for_texture(prep.dex_overlay.CREATURES[dex_index])
	_assert(prep.dex_overlay.detail_rarity.get_theme_color("font_color") == RARITY_TAG.text_color(selected_rarity), "creature rarity text must use the sampled tag text color")
	_assert(prep.dex_overlay._creature_rarity_color(2) == prep.SHOP_RARITY_COLORS[2], "codex rarity colors must match the outside shop palette")
	_assert(prep.dex_overlay.detail_description.autowrap_mode != TextServer.AUTOWRAP_OFF, "codex skill descriptions must wrap")
	_assert(prep.dex_overlay.detail_clock_icon.position.x + prep.dex_overlay.detail_clock_icon.size.x < prep.dex_overlay.detail_cooldown.position.x, "codex time icon and attack interval must not overlap")
	var dex_rarity_style := prep.dex_overlay.detail_rarity.get_theme_stylebox("normal") as StyleBoxTexture
	_assert(dex_rarity_style != null and dex_rarity_style.texture == RARITY_TAG.texture(selected_rarity), "codex details must share the same rarity tag texture")
	var detail_inner_style: StyleBoxFlat = prep.dex_overlay.detail_inner_panel.get_theme_stylebox("panel")
	_assert(detail_inner_style.corner_radius_top_left == 18 and detail_inner_style.corner_radius_bottom_right == 18, "detail inner white background must match the rounded outer frame")
	_assert(not prep.dex_overlay.detail_outer_frame.visible, "rectangular white source frame must not protrude beyond the rounded detail background")
	_assert(prep.dex_overlay.collection_panel.get_child_count() == 0, "dex collection header filter bar must be removed")
	_assert(prep.dex_overlay.close_button.get_theme_stylebox("normal") == prep.dex_overlay.close_button.get_theme_stylebox("hover"), "dex close button idle and hover states must remain visually stable")
	_assert((prep.dex_overlay.close_button.get_theme_stylebox("pressed") as StyleBoxFlat).bg_color == Color("85899b") and prep.dex_overlay.close_button.get_theme_color("font_pressed_color") == Color.WHITE, "pressed close button must use a gray circle with a white x")
	_assert((prep.dex_overlay.tab_buttons[0].get_theme_stylebox("pressed") as StyleBoxFlat).corner_radius_top_left == (prep.dex_overlay.tab_buttons[0].get_theme_stylebox("normal") as StyleBoxFlat).corner_radius_top_left, "tab pressed and static states must share the same corner radius")
	_assert(prep.dex_overlay.detail_description.size.x == 196.0, "creature skill copy must use a shorter line length before wrapping")
	var active_icon_center_y: float = prep.dex_overlay.detail_role_panel.position.y + prep.dex_overlay.detail_role_icon.position.y + prep.dex_overlay.detail_role_icon.size.y * 0.5
	var cooldown_icon_center_y: float = prep.dex_overlay.detail_skill_panel.position.y + prep.dex_overlay.detail_clock_icon.position.y + prep.dex_overlay.detail_clock_icon.size.y * 0.5
	_assert(absf(active_icon_center_y - cooldown_icon_center_y) <= 2.0, "attack interval icon must align vertically with the active-skill icon row")
	_assert(prep.dex_overlay.monster_scroll.get_v_scroll_bar().mouse_filter == Control.MOUSE_FILTER_STOP, "the visible vertical scrollbar must accept mouse dragging")
	_assert(prep.dex_overlay.scroll_thumb.mouse_filter == Control.MOUSE_FILTER_STOP, "the custom vertical thumb must accept mouse dragging")
	var scroll_before: int = prep.dex_overlay.monster_scroll.scroll_vertical
	prep.dex_overlay.scroll_thumb_dragging = true
	var scroll_motion := InputEventMouseMotion.new()
	scroll_motion.relative = Vector2(0, 24)
	prep.dex_overlay._on_scroll_thumb_gui_input(scroll_motion)
	_assert(prep.dex_overlay.monster_scroll.scroll_vertical > scroll_before, "dragging the custom vertical thumb must update collection scroll position")
	prep.dex_overlay.scroll_thumb_dragging = false
	_assert(prep.dex_overlay.counter_help_buttons.size() == 3, "all three collection counters must expose clickable help buttons")
	prep.dex_overlay.counter_help_buttons[0].emit_signal("pressed")
	_assert(prep.dex_overlay.counter_help_popup.visible and prep.dex_overlay.counter_help_text.text.contains("图鉴收集"), "counter help click must open its explanation popup")
	prep.dex_overlay.counter_help_popup.visible = false
	await _capture("res://dex_overlay_polished.png")
	var rare_detail_index: int = prep.dex_overlay.NAMES.find("铁壳蛛")
	_assert(rare_detail_index >= 0, "rare detail visual fixture must exist")
	GameState.mark_creature_seen(prep.dex_overlay.CREATURES[rare_detail_index])
	prep.dex_overlay._select_creature(rare_detail_index)
	await get_tree().process_frame
	_assert(prep.dex_overlay.detail_rarity.text == "稀有" and prep.dex_overlay.detail_rarity.get_theme_color("font_color") == RARITY_TAG.text_color(2), "rare creature detail must use the sampled blue text color")
	await _capture("res://dex_creature_detail_reference.png")
	var long_skill_index: int = prep.dex_overlay.NAMES.find("苍羽狮鹫")
	_assert(long_skill_index >= 0, "long skill description fixture must exist")
	GameState.mark_creature_seen(prep.dex_overlay.CREATURES[long_skill_index])
	prep.dex_overlay._select_creature(long_skill_index)
	await get_tree().process_frame
	await _capture("res://dex_creature_long_skill.png")
	prep.dex_overlay._on_tab_pressed(3)
	await get_tree().process_frame
	_assert(prep.dex_overlay.trainer_cards.all(func(card): return card.visible), "trainer tab must show trainer cards")
	_assert(prep.dex_overlay.trainer_selection_frames.all(func(frame): return frame is Panel), "trainer cards must use the creature-style selection border")
	_assert(prep.dex_overlay.trainer_cards[0].get_child(0) is Panel, "trainer cards must use the creature-style rounded panel frame")
	_assert(prep.dex_overlay.trainer_cards[0].size == Vector2(338, 438), "trainer frames and portraits must be enlarged to reduce empty space")
	_assert(prep.dex_overlay.monster_page.size.x > prep.dex_overlay.monster_scroll.size.x, "trainer page must scroll horizontally along the bottom")
	_assert(prep.dex_overlay.monster_scroll.get_h_scroll_bar().mouse_filter == Control.MOUSE_FILTER_STOP, "trainer horizontal scrollbar must accept mouse dragging")
	_assert(not prep.dex_overlay.scroll_track.visible and not prep.dex_overlay.scroll_thumb.visible, "trainer horizontal layout must hide the vertical decorative scrollbar")
	await _capture("res://dex_trainers_matching_cards.png")
	prep.dex_overlay._on_tab_pressed(2)
	await get_tree().process_frame
	_assert(not prep.dex_overlay.detail_skill_panel.visible, "item and accessory details must remove the legacy unknown status box")
	_assert(prep.dex_overlay.item_selection_frames.all(func(frame): return frame is Panel), "item cards must use the creature-style selection border")
	var dex_item_style := prep.dex_overlay.detail_rarity.get_theme_stylebox("normal") as StyleBoxTexture
	_assert(dex_item_style != null and dex_item_style.texture.resource_path.contains("/rarity_tags/"), "item codex details must use the shared rarity tag")
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
