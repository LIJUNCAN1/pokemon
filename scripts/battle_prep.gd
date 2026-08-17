extends Control

const SOURCE_HAN_FONT: FontFile = preload("res://assets/fonts/SourceHanSansSC-Heavy.otf")
const STAT_PIXEL_FONT: FontFile = preload("res://assets/fonts/ark-pixel-12px-proportional-zh_cn.ttf")
const CATALOG = preload("res://scripts/creature_catalog.gd")
const TRAINER_CATALOG = preload("res://scripts/trainer_catalog.gd")
const ITEM_CATALOG = preload("res://scripts/item_catalog.gd")
const EQUIPMENT_CATALOG = preload("res://scripts/equipment_catalog.gd")
const RARITY_TAG = preload("res://scripts/rarity_tag_style.gd")
const STAT_BADGE_SHADER: Shader = preload("res://shaders/stat_badge.gdshader")
const DEX_OVERLAY_SCENE: PackedScene = preload("res://dex_overlay.tscn")
const SETTINGS_OVERLAY_SCENE: PackedScene = preload("res://settings_overlay.tscn")
const INVENTORY_POPUP_SCENE: PackedScene = preload("res://inventory_popup.tscn")
const ITEM_INFO_TINT_SHADER: Shader = preload("res://assets/ui/item_info/rarity_tint.gdshader")
const SOLID_ICON_TINT_SHADER: Shader = preload("res://shaders/solid_icon_tint.gdshader")
const ITEM_INFO_ROOT := "res://assets/ui/item_info/"
const BATTLE_RANGED_ICON: Texture2D = preload("res://素材/战斗场景/图层 3.png")
const BATTLE_MELEE_ICON: Texture2D = preload("res://素材/战斗场景/图层 4.png")
const CHARACTER_INFO_TIME_ICON: Texture2D = preload("res://assets/ui/character_info/time.png")
const CHARACTER_INFO_DAMAGE_GAP := 12.0
const SYNERGY_TOOLTIP_ROOT := "res://assets/ui/synergy_tooltip/"
const SYNERGY_TOOLTIP_BASE_SIZE := Vector2(320, 243)
const SYNERGY_TOOLTIP_DISPLAY_SCALE := 1.0
const SYNERGY_TOOLTIP_SIZE := Vector2(320, 243)
const DESIGN_SIZE := Vector2(1280, 720)
const FULL_HD_SCALE := Vector2(0.5, 0.5)
const PREP_GRASS_BACKGROUND := "res://assets/ui/battle_prep/grass_background.png"
const PREP_FORMATION_TOP_PLATFORM := "res://素材/场景/图层 6.png"
const PREP_FORMATION_BOTTOM_PLATFORM := "res://素材/场景/图层 7.png"
const PREP_FORMATION_TOP_CENTERS: Array[Vector2] = [Vector2(230, 335), Vector2(392, 335), Vector2(550, 335)]
const PREP_FORMATION_BOTTOM_CENTERS: Array[Vector2] = [Vector2(194, 438), Vector2(356, 438), Vector2(518, 438)]
const PREP_FORMATION_GROUP_OFFSET := Vector2(268, 0)
const PREP_FORMATION_SLOT_SIZE := Vector2(112, 96)
const PREP_FORMATION_SLOT_OFFSET := Vector2(-56, -70)
const PREP_FORMATION_SPRITE_SIZE := Vector2(76, 78)
const UI := "res://素材/主菜单/"
const POKEMON := "res://素材/宝可梦图/"
const MAP_PREP_MUSIC := "res://assets/audio/pixel_mountain_quest.mp3"
const SHOP_PANEL_ASSET := "res://素材/事件/aseprite_export/shop_table/runtime/shop_panel.png"
const SHOP_CARD_FRAME_ASSET := "res://素材/事件/aseprite_export/shop_table/runtime/shop_card_frame.png"
const SHOP_CARD_TEMPLATE_ASSET := "res://素材/事件/aseprite_export/shop_table/runtime/shop_card_template.png"
const SHOP_ATTRIBUTE_FRAME_ASSET := "res://素材/事件/aseprite_export/shop_table/runtime/attribute_swatch.png"
const LOCK_ICON := "res://素材/主菜单/lock.png"
const LOCK_ICON_PRESSED := "res://素材/主菜单/lock2.png"
const STAR_ICON: Texture2D = preload("res://素材/事件/精灵图-0007.png")
const SOLD_OUT_ICON: Texture2D = preload("res://素材/事件/sold out.png")
const HEALTH_FRAMES: Array[Texture2D] = [
	preload("res://素材/主菜单/aseprite_export/health/runtime/heart_0.png"),
	preload("res://素材/主菜单/aseprite_export/health/runtime/heart_1.png"),
	preload("res://素材/主菜单/aseprite_export/health/runtime/heart_2.png"),
	preload("res://素材/主菜单/aseprite_export/health/runtime/heart_3.png"),
	preload("res://素材/主菜单/aseprite_export/health/runtime/heart_4.png"),
]
var CREATURE_TEXTURES: Array[String] = CATALOG.all_textures()
const ATTRIBUTE_COLORS: Array[Color] = [
	Color("e59a64"), Color("8eb9d1"), Color("a9b85f"),
	Color("b99b78"), Color("aebd57"), Color("aa91c5"),
]
const LEVEL_COLORS: Array[Color] = [Color.WHITE, Color("58d66b"), Color("ef4b52")]
var CREATURE_NAMES: Array[String] = CATALOG.all_names()
const SHOP_RARITY_NAMES: Array[String] = ["普通", "优秀", "稀有", "史诗", "传说"]
const SHOP_RARITY_COLORS: Array[Color] = [Color("b8bdc5"), Color("58b85f"), Color("3e95d8"), Color("c45ad9"), Color("e3a62f")]
const SHOP_CARD_ASSETS: Array[String] = [
	"res://assets/ui/shop_card/card_common.png",
	"res://assets/ui/shop_card/card_uncommon.png",
	"res://assets/ui/shop_card/card_rare.png",
	"res://assets/ui/shop_card/card_epic.png",
	"res://assets/ui/shop_card/card_legendary.png",
]
const SHOP_CARD_COIN_ICON := "res://素材/主菜单/精灵图-0001.png"
const PRESET_INFO_FRAME: Texture2D = preload("res://素材/主菜单/13_切图_13 拷贝.png")
const SHOP_CARD_COUNT := 5
const SHOP_ITEM_CHANCE := 0.58
const SHOP_ACCESSORY_CHANCE := 0.46
const SHOP_EQUIPMENT_CHANCE := 0.30
const TRAIT_ICON_PATHS: Dictionary = {
	"自然": "res://assets/ui/trait_icons/new_set/nature.png",
	"火": "res://assets/ui/trait_icons/new_set/fire.png",
	"雷": "res://assets/ui/trait_icons/new_set/lightning.png",
	"岩": "res://assets/ui/trait_icons/new_set/rock.png",
	"水": "res://assets/ui/trait_icons/new_set/water.png",
	"冰": "res://assets/ui/trait_icons/new_set/ice.png",
	"植物": "res://assets/ui/trait_icons/new_set/plant.png",
	"虫群": "res://assets/ui/trait_icons/new_set/insect.png",
	"龙族": "res://assets/ui/trait_icons/new_set/dragon.png",
	"机械": "res://assets/ui/trait_icons/new_set/mechanical.png",
	"灵体": "res://assets/ui/trait_icons/new_set/spirit.png",
	"守护": "res://assets/ui/trait_icons/guardian.png",
	"野兽": "res://assets/ui/trait_icons/beast.png",
	"月影": "res://assets/ui/trait_icons/new_set/moon.png",
	"星辉": "res://assets/ui/trait_icons/new_set/starlight.png",
	"格斗": "res://assets/ui/trait_icons/new_set/fighter.png",
	"飞行": "res://assets/ui/trait_icons/new_set/flying.png",
	"亡灵": "res://assets/ui/trait_icons/new_set/undead.png",
	"风": "res://assets/ui/trait_icons/new_set/wind.png",
	"晶石": "res://assets/ui/trait_icons/new_set/crystal.png",
}
const TRAIT_COLORS: Dictionary = {
	"自然": Color("a8a8a8"),
	"火": Color("fc9833"),
	"雷": Color("f7d542"),
	"岩": Color("d77e47"),
	"水": Color("4f9be6"),
	"冰": Color("76d4c9"),
	"植物": Color("57c061"),
	"虫群": Color("96c025"),
	"龙族": Color("137ed3"),
	"机械": Color("5195a1"),
	"灵体": Color("646dc2"),
	"守护": Color("d09a3d"),
	"野兽": Color("697078"),
	"月影": Color("70717e"),
	"星辉": Color("eb7ada"),
	"格斗": Color("dc3d4b"),
	"飞行": Color("91aee6"),
	"亡灵": Color("b65cce"),
	"风": Color("fd7c7a"),
	"晶石": Color("ceb984"),
}

var source_han_font: FontFile
var stat_pixel_font: FontFile
var creature_buttons: Array[Button] = []
var creature_sprites: Array[TextureRect] = []
var creature_level_labels: Array[Label] = []
var creature_star_rows: Array[Control] = []
var creature_hp_labels: Array[Label] = []
var creature_special_labels: Array[Label] = []
var creature_hp_badges: Array[TextureRect] = []
var creature_special_badges: Array[TextureRect] = []
var creature_element_icons: Array[TextureRect] = []
var creature_race_icons: Array[TextureRect] = []
var creature_extra_trait_icons: Array[TextureRect] = []
var creature_trait_backgrounds: Array[TextureRect] = []
var creature_element_icon_backgrounds: Array[TextureRect] = []
var creature_extra_icon_backgrounds: Array[TextureRect] = []
var creature_race_icon_backgrounds: Array[TextureRect] = []
var creature_rarity_frames: Array[Panel] = []
var creature_masks: Array[ColorRect] = []
var creature_selection_frames: Array[TextureRect] = []
var creature_data: Array[String] = []
var creature_levels: Array[int] = []
var creature_equipment: Array = []
var creature_equipment_icons: Array = []
var selected_slot := -1
var drag_source_slot := -1
var shop_sprites: Array[TextureRect] = []
var shop_portrait_clips: Array[Control] = []
var shop_buttons: Array[Button] = []
var shop_hp_labels: Array[Label] = []
var shop_special_labels: Array[Label] = []
var shop_hp_badges: Array[TextureRect] = []
var shop_special_badges: Array[TextureRect] = []
var shop_level_labels: Array[Label] = []
var shop_star_rows: Array[Control] = []
var shop_element_icons: Array[TextureRect] = []
var shop_race_icons: Array[TextureRect] = []
var shop_extra_trait_icons: Array[TextureRect] = []
var shop_trait_backgrounds: Array[TextureRect] = []
var shop_attribute_layers: Array[TextureRect] = []
var shop_creature_overlays: Array[TextureRect] = []
var shop_outer_layers: Array[TextureRect] = []
var shop_name_labels: Array[Label] = []
var shop_price_labels: Array[Label] = []
var shop_element_labels: Array[Label] = []
var shop_secondary_trait_labels: Array[Label] = []
var shop_coin_icons: Array[TextureRect] = []
var shop_sold_out_overlays: Array[TextureRect] = []
var shop_sold_out_shades: Array[ColorRect] = []
var shop_card_outlines: Array[Panel] = []
var shop_lock_overlays: Array[TextureRect] = []
var shop_element_icon_backgrounds: Array[TextureRect] = []
var shop_extra_icon_backgrounds: Array[TextureRect] = []
var shop_race_icon_backgrounds: Array[TextureRect] = []
var shop_data: Array[Dictionary] = []
var coin_label: Label
var lock_label: Label
var lock_button_texture: TextureRect
var inventory_count_label: Label
var coins := 5
var shop_locked := false
var lock_button: Button
var shop_sell_overlay: Panel
var shop_sell_label: Label
var health_icons: Array[TextureRect] = []
var dex_overlay: Control
var settings_overlay: Control
var inventory_popup: Control
var rng := RandomNumberGenerator.new()
var synergy_count_labels: Dictionary = {}
var synergy_icons: Dictionary = {}
var synergy_name_labels: Dictionary = {}
var synergy_row_frames: Dictionary = {}
var synergy_icon_cells: Dictionary = {}
var synergy_count_cells: Dictionary = {}
var synergy_step_boxes: Dictionary = {}
var synergy_step_labels: Dictionary = {}
var synergy_hover_buttons: Dictionary = {}
var synergy_row_positions: Dictionary = {}
var synergy_current_counts: Dictionary = {}
var synergy_scroll: ScrollContainer
var synergy_list: Control
var synergy_tooltip: Panel
var synergy_tooltip_content: Control
var synergy_tooltip_title: Label
var synergy_tooltip_body: Label
var synergy_tooltip_icon: TextureRect
var synergy_tooltip_count: Label
var synergy_tooltip_tier_rows: Array[Control] = []
var synergy_tooltip_tier_circles: Array[TextureRect] = []
var synergy_tooltip_tier_fills: Array[Panel] = []
var synergy_tooltip_tier_badges: Array[TextureRect] = []
var synergy_tooltip_tier_numbers: Array[Label] = []
var synergy_tooltip_tier_texts: Array[RichTextLabel] = []
var hovered_synergy := ""
var shop_hover_tweens: Dictionary = {}
var idle_wobble_time := 0.0
var selection_pulse_tween: Tween
var card_tooltip: Panel
var card_tooltip_legacy_header: ColorRect
var card_tooltip_name: Label
var card_tooltip_rarity: Label
var card_tooltip_sprite: TextureRect
var card_tooltip_portrait_panel: Panel
var card_tooltip_element_icon: TextureRect
var card_tooltip_element: Label
var card_tooltip_race_icon: TextureRect
var card_tooltip_race: Label
var card_tooltip_cooldown: Label
var card_tooltip_damage: Label
var card_tooltip_extra: Label
var card_tooltip_element_panel: Panel
var card_tooltip_race_panel: Panel
var card_tooltip_info_panel: Panel
var creature_tooltip_nodes: Array[CanvasItem] = []
var card_tooltip_gradient: TextureRect
var card_tooltip_shadow: Panel
var card_tooltip_star: TextureRect
var card_tooltip_star_label: Label
var card_tooltip_price: Label
var card_tooltip_role_icon: TextureRect
var card_tooltip_role: Label
var card_tooltip_cooldown_caption: Label
var card_tooltip_skill_icon: TextureRect
var card_tooltip_skill_backdrop: Panel
var card_tooltip_skill_name: Label
var card_tooltip_skill_damage: Label
var card_tooltip_skill_text: RichTextLabel
var card_tooltip_header_divider: ColorRect
var card_tooltip_bottom_panel: Panel
var card_tooltip_skill_divider: ColorRect
var card_tooltip_rarity_badge: Panel
var card_tooltip_clock_icon: TextureRect
var card_tooltip_active_label: Label
var card_tooltip_name_icon: Label
var card_tooltip_horizontal_divider: Control
var item_tooltip_layers: Array[CanvasItem] = []
var item_tooltip_type: Label
var item_tooltip_effect: RichTextLabel
var item_tooltip_rule: RichTextLabel
var item_tooltip_divider: Control
var trainer_skill_panel: Panel
var trainer_skill_button: Button
var trainer_skill_progress: Label
var trainer_skill_detail: Panel


func _ready() -> void:
	_apply_full_hd_layout()
	GameState.begin_preparation()
	# Map and preparation intentionally share one track. The global manager
	# keeps playback position instead of restarting it between both scenes.
	MusicManager.play_music(MAP_PREP_MUSIC, 1.2)
	rng.randomize()
	coins = GameState.coins
	source_han_font = SOURCE_HAN_FONT.duplicate() as FontFile
	source_han_font.antialiasing = TextServer.FONT_ANTIALIASING_GRAY
	source_han_font.multichannel_signed_distance_field = true
	source_han_font.msdf_pixel_range = 8
	source_han_font.msdf_size = 64
	source_han_font.hinting = TextServer.HINTING_NORMAL
	source_han_font.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	source_han_font.oversampling = FULL_HD_SCALE.x
	source_han_font.allow_system_fallback = false
	stat_pixel_font = STAT_PIXEL_FONT.duplicate() as FontFile
	stat_pixel_font.antialiasing = TextServer.FONT_ANTIALIASING_NONE
	stat_pixel_font.hinting = TextServer.HINTING_NONE
	stat_pixel_font.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	stat_pixel_font.oversampling = FULL_HD_SCALE.x
	stat_pixel_font.allow_system_fallback = false
	_build_interface()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		if not is_instance_valid(settings_overlay):
			get_viewport().set_input_as_handled()
			_on_settings_pressed()


func _process(delta: float) -> void:
	idle_wobble_time += delta
	for index in creature_sprites.size():
		var sprite := creature_sprites[index]
		if sprite.texture == null:
			sprite.rotation = 0.0
			continue
		sprite.rotation = sin(idle_wobble_time * 1.35 + index * 0.72) * deg_to_rad(1.35)


func _apply_full_hd_layout() -> void:
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	position = Vector2.ZERO
	size = DESIGN_SIZE
	scale = FULL_HD_SCALE


func _build_interface() -> void:
	var background := _add_texture(self, PREP_GRASS_BACKGROUND, Rect2(Vector2.ZERO, DESIGN_SIZE), TextureRect.STRETCH_KEEP_ASPECT_COVERED)
	background.name = "PreparationGrassBackground"
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	move_child(background, 0)
	_build_top_bar()
	_build_bench()
	_build_team()
	_resolve_all_creature_merges()
	_build_synergy()
	_build_shop()
	_build_footer_actions()
	_build_card_tooltip()


func _build_top_bar() -> void:
	var bar := ColorRect.new()
	bar.position = Vector2.ZERO
	bar.size = Vector2(1280, 72)
	bar.color = Color(0.02, 0.43, 0.62, 0.96)
	add_child(bar)
	var stripe := ColorRect.new()
	stripe.position = Vector2(0, 61)
	stripe.size = Vector2(1280, 5)
	stripe.color = Color(0.42, 0.9, 1.0, 0.9)
	bar.add_child(stripe)
	_build_health_display()
	_build_trainer_skill_control()
	_add_label(self, "远 征 准 备", Rect2(500, 7, 280, 54), 34, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	_add_icon_button(UI + "01_切图_1.png", Rect2(1068, 5, 58, 58), _open_inventory, "打开物品栏")
	_add_static_icon_button("res://assets/ui/collection_book_icon.png", Rect2(1137, 7, 52, 52), _open_dex, "打开图鉴")
	_add_icon_button("res://素材/地图/设置icon.png", Rect2(1202, 6, 56, 56), _on_settings_pressed, "设置")
	inventory_count_label = _add_label(self, "", Rect2(1101, 43, 24, 24), 18, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	_refresh_inventory_count()


func _build_trainer_skill_control() -> void:
	if GameState.trainer_id.is_empty():
		return
	var data := TRAINER_CATALOG.data(GameState.trainer_id)
	trainer_skill_panel = Panel.new()
	trainer_skill_panel.position = Vector2(182, 7)
	trainer_skill_panel.size = Vector2(58, 58)
	trainer_skill_panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	add_child(trainer_skill_panel)
	var skill_icon := _add_texture(trainer_skill_panel, String(data["skill_icon"]), Rect2(5, 5, 48, 48))
	skill_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	skill_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	trainer_skill_button = Button.new()
	trainer_skill_button.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	trainer_skill_button.flat = true
	trainer_skill_button.focus_mode = Control.FOCUS_NONE
	trainer_skill_button.tooltip_text = ""
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		trainer_skill_button.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	trainer_skill_button.pressed.connect(_on_trainer_skill_pressed)
	trainer_skill_button.gui_input.connect(_on_trainer_skill_gui_input)
	trainer_skill_panel.add_child(trainer_skill_button)
	_refresh_trainer_skill_control()


func _refresh_trainer_skill_control() -> void:
	if not is_instance_valid(trainer_skill_panel):
		return
	if is_instance_valid(trainer_skill_progress):
		trainer_skill_progress.text = GameState.trainer_skill_progress_text()
	var data := TRAINER_CATALOG.data(GameState.trainer_id)
	var unavailable := TRAINER_CATALOG.is_active(GameState.trainer_id) and (
		int(GameState.trainer_skill_state.get("uses", 0)) > 0 or GameState.coins < int(data.get("cost", 0))
	)
	trainer_skill_panel.modulate = Color(0.62, 0.62, 0.62, 1.0) if unavailable else Color.WHITE


func _on_trainer_skill_pressed() -> void:
	var data := TRAINER_CATALOG.data(GameState.trainer_id)
	if not TRAINER_CATALOG.is_active(GameState.trainer_id):
		_set_notice(String(data["description"]))
		return
	var result := GameState.activate_trainer_skill()
	_sync_coins()
	_refresh_trainer_skill_control()
	_set_notice(String(result["message"]))


func _on_trainer_skill_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		if is_instance_valid(trainer_skill_detail):
			trainer_skill_detail.queue_free()
			trainer_skill_detail = null
		else:
			_show_trainer_skill_detail()
		get_viewport().set_input_as_handled()


func _show_trainer_skill_detail() -> void:
	if is_instance_valid(trainer_skill_detail):
		trainer_skill_detail.queue_free()
	var data := TRAINER_CATALOG.data(GameState.trainer_id)
	trainer_skill_detail = Panel.new()
	trainer_skill_detail.position = Vector2(182, 68)
	trainer_skill_detail.size = Vector2(390, 136)
	trainer_skill_detail.z_index = 160
	trainer_skill_detail.mouse_filter = Control.MOUSE_FILTER_STOP
	trainer_skill_detail.add_theme_stylebox_override("panel", _preset_info_style())
	add_child(trainer_skill_detail)
	var title := _add_label(trainer_skill_detail, "%s · %s" % [String(data["skill_name"]), TRAINER_CATALOG.skill_type_name(GameState.trainer_id)], Rect2(20, 10, 350, 28), 17, Color("252b35"))
	var body := _add_label(trainer_skill_detail, String(data["description"]), Rect2(20, 42, 350, 56), 12, Color("596275"))
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	trainer_skill_progress = _add_label(trainer_skill_detail, GameState.trainer_skill_progress_text(), Rect2(20, 103, 350, 22), 11, Color(data["color"]), HORIZONTAL_ALIGNMENT_RIGHT)
	for label in [title, body, trainer_skill_progress]:
		label.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
		label.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		label.add_theme_constant_override("outline_size", 0)
		label.add_theme_constant_override("shadow_offset_x", 0)
		label.add_theme_constant_override("shadow_offset_y", 0)


func _build_health_display() -> void:
	health_icons.clear()
	for index in 3:
		var filled := index < GameState.run_lives
		var heart := _add_texture(self, HEALTH_FRAMES[0 if filled else 4].resource_path, Rect2(38 + index * 46, 17, 42, 36))
		heart.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		health_icons.append(heart)
	if GameState.pending_life_loss_animation and GameState.run_lives < 3:
		var lost_index := clampi(GameState.run_lives, 0, 2)
		health_icons[lost_index].texture = HEALTH_FRAMES[0]
		_play_life_loss_animation.call_deferred(lost_index)


func _play_life_loss_animation(index: int) -> void:
	GameState.pending_life_loss_animation = false
	await get_tree().create_timer(0.56).timeout
	for frame_index in range(1, HEALTH_FRAMES.size()):
		health_icons[index].texture = HEALTH_FRAMES[frame_index]
		await get_tree().create_timer(0.18).timeout


func _build_bench() -> void:
	_add_texture(self, UI + "备战框.png", Rect2(341, 82, 590, 155), TextureRect.STRETCH_SCALE)
	_add_label(self, "备战席", Rect2(353, 88, 120, 26), 15, Color.WHITE)
	var rects := [Rect2(352, 116, 136, 108), Rect2(498, 116, 136, 108), Rect2(644, 116, 136, 108), Rect2(790, 116, 136, 108)]
	for index in rects.size():
		var saved_texture := GameState.player_bench[index] if index < GameState.player_bench.size() else ""
		var saved_level := GameState.player_bench_levels[index] if index < GameState.player_bench_levels.size() else 1
		var saved_equipment: Array = GameState.player_bench_equipment[index] if index < GameState.player_bench_equipment.size() else []
		_create_creature_slot(rects[index], saved_texture, "备战 %d" % (index + 1), saved_level, false, saved_equipment)


func _build_team() -> void:
	var top_platform := _add_texture(self, PREP_FORMATION_TOP_PLATFORM, Rect2(Vector2(170, 307) + PREP_FORMATION_GROUP_OFFSET, Vector2(440, 52)), TextureRect.STRETCH_SCALE)
	top_platform.name = "FormationTopPlatform"
	var bottom_platform := _add_texture(self, PREP_FORMATION_BOTTOM_PLATFORM, Rect2(Vector2(135, 410) + PREP_FORMATION_GROUP_OFFSET, Vector2(446, 55)), TextureRect.STRETCH_SCALE)
	bottom_platform.name = "FormationBottomPlatform"
	var centers: Array[Vector2] = []
	centers.append_array(PREP_FORMATION_TOP_CENTERS)
	centers.append_array(PREP_FORMATION_BOTTOM_CENTERS)
	for index in centers.size():
		var saved_texture := GameState.player_team[index] if index < GameState.player_team.size() else ""
		var saved_level := GameState.player_team_levels[index] if index < GameState.player_team_levels.size() else 1
		var slot_rect := Rect2(centers[index] + PREP_FORMATION_GROUP_OFFSET + PREP_FORMATION_SLOT_OFFSET, PREP_FORMATION_SLOT_SIZE)
		var saved_equipment: Array = GameState.player_team_equipment[index] if index < GameState.player_team_equipment.size() else []
		_create_creature_slot(slot_rect, saved_texture, "上阵 %d" % (index + 1), saved_level, true, saved_equipment)


func _build_synergy() -> void:
	synergy_scroll = ScrollContainer.new()
	synergy_scroll.position = Vector2(970, 98)
	synergy_scroll.size = Vector2(292, 286)
	synergy_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	synergy_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	synergy_scroll.clip_contents = true
	synergy_scroll.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	add_child(synergy_scroll)
	synergy_list = Control.new()
	synergy_list.custom_minimum_size = Vector2(282, 286)
	synergy_list.size = synergy_list.custom_minimum_size
	synergy_scroll.add_child(synergy_list)
	var synergy_ids: Array[String] = CATALOG.synergy_ids()
	for index in synergy_ids.size():
		var synergy: String = synergy_ids[index]
		var y := index * 36.0
		var row := ColorRect.new()
		row.position = Vector2(0, y)
		row.size = Vector2(282, 30)
		row.color = Color("4f4a91")
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		synergy_list.add_child(row)
		synergy_row_frames[synergy] = row
		var icon_cell := ColorRect.new()
		icon_cell.position = Vector2(0, y)
		icon_cell.size = Vector2(34, 30)
		icon_cell.color = CATALOG.synergy_color(synergy)
		icon_cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
		synergy_list.add_child(icon_cell)
		synergy_icon_cells[synergy] = icon_cell
		var icon := _add_texture(synergy_list, CATALOG.synergy_icon_path(synergy), Rect2(5, y + 3, 24, 24))
		icon.modulate = Color.WHITE
		icon.z_index = 2
		var name_label := _add_label(synergy_list, synergy, Rect2(34, y + 1, 46, 28), 14, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
		var count_cell := ColorRect.new()
		count_cell.position = Vector2(224, y)
		count_cell.size = Vector2(58, 30)
		count_cell.color = Color("6961ad")
		count_cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
		synergy_list.add_child(count_cell)
		synergy_count_cells[synergy] = count_cell
		var count_label := _add_label(synergy_list, "", Rect2(224, y, 58, 30), 15, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
		count_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		synergy_icons[synergy] = icon
		synergy_name_labels[synergy] = name_label
		synergy_count_labels[synergy] = count_label
		var thresholds: Array = CATALOG.synergy_thresholds(synergy)
		var boxes: Array[ColorRect] = []
		var step_labels: Array[Label] = []
		for step_index in thresholds.size():
			var available_width := 144.0
			var step_width := available_width / maxf(float(thresholds.size()), 1.0)
			var step_x := 80.0 + step_index * step_width
			var active_box := ColorRect.new()
			active_box.position = Vector2(step_x, y)
			active_box.size = Vector2(step_width, 30)
			active_box.color = Color("d9344b")
			active_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
			active_box.visible = false
			synergy_list.add_child(active_box)
			boxes.append(active_box)
			var step_label := _add_label(synergy_list, "%d" % thresholds[step_index], Rect2(step_x, y, step_width, 30), 14, Color("3b3972"), HORIZONTAL_ALIGNMENT_CENTER)
			step_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			step_labels.append(step_label)
		synergy_step_boxes[synergy] = boxes
		synergy_step_labels[synergy] = step_labels
		var hover := Button.new()
		hover.position = Vector2(0, y)
		hover.size = Vector2(282, 30)
		hover.flat = true
		hover.focus_mode = Control.FOCUS_NONE
		hover.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		hover.mouse_entered.connect(_show_synergy_tooltip.bind(synergy))
		hover.mouse_exited.connect(_hide_synergy_tooltip)
		synergy_list.add_child(hover)
		synergy_hover_buttons[synergy] = hover
	_build_synergy_tooltip()
	_update_synergies()


func _build_synergy_tooltip() -> void:
	synergy_tooltip = Panel.new()
	# The supplied drawer artwork is authored at 1280x972 (4x the old
	# implementation).  Keep the native proportions and scale the complete
	# composition uniformly so the bitmap layers and text share one coordinate
	# system.
	synergy_tooltip.position = Vector2(648, 82)
	synergy_tooltip.size = SYNERGY_TOOLTIP_SIZE
	synergy_tooltip.z_index = 90
	synergy_tooltip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	synergy_tooltip.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	synergy_tooltip.visible = false
	add_child(synergy_tooltip)
	for asset_name in ["frame.png", "header.png", "body.png", "count_border.png", "count_fill.png"]:
		var layer := _add_texture(synergy_tooltip, SYNERGY_TOOLTIP_ROOT + asset_name, Rect2(0, 0, SYNERGY_TOOLTIP_SIZE.x, SYNERGY_TOOLTIP_SIZE.y), TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
		layer.name = asset_name.get_basename().to_pascal_case()
		layer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if asset_name in ["header.png", "count_border.png", "count_fill.png"]:
			var material := ShaderMaterial.new()
			material.shader = ITEM_INFO_TINT_SHADER
			layer.material = material
	synergy_tooltip_content = Control.new()
	synergy_tooltip_content.name = "ScaledContent"
	synergy_tooltip_content.position = Vector2.ZERO
	synergy_tooltip_content.size = SYNERGY_TOOLTIP_BASE_SIZE
	synergy_tooltip_content.scale = Vector2.ONE * SYNERGY_TOOLTIP_DISPLAY_SCALE
	synergy_tooltip_content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	synergy_tooltip.add_child(synergy_tooltip_content)
	synergy_tooltip_icon = _add_texture(synergy_tooltip_content, CATALOG.synergy_icon_path("自然"), Rect2(22, 15, 25, 25))
	synergy_tooltip_icon.name = "SynergyIcon"
	synergy_tooltip_title = _add_label(synergy_tooltip_content, "", Rect2(64, 9, 242, 34), 23, Color.WHITE)
	synergy_tooltip_count = _add_label(synergy_tooltip_content, "", Rect2(16, 55, 106, 27), 15, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	synergy_tooltip_body = _add_label(synergy_tooltip_content, "", Rect2(Vector2.ZERO, Vector2.ZERO), 1, Color.TRANSPARENT)
	for tier_index in 3:
		var row := Control.new()
		row.position = Vector2(20, 92 + tier_index * 48)
		row.size = Vector2(286, 45)
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		synergy_tooltip_content.add_child(row)
		synergy_tooltip_tier_rows.append(row)
		var circle := _add_texture(row, SYNERGY_TOOLTIP_ROOT + "tier_circle_trim.png", Rect2(0, 8, 14, 14))
		var circle_material := ShaderMaterial.new()
		circle_material.shader = SOLID_ICON_TINT_SHADER
		circle_material.set_shader_parameter("tint_color", Color.WHITE)
		circle.material = circle_material
		synergy_tooltip_tier_circles.append(circle)
		var fill := Panel.new()
		fill.position = Vector2(0, 8)
		fill.size = Vector2(14, 14)
		fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var fill_style := StyleBoxFlat.new()
		fill_style.bg_color = Color.WHITE
		fill_style.corner_radius_top_left = 7
		fill_style.corner_radius_top_right = 7
		fill_style.corner_radius_bottom_left = 7
		fill_style.corner_radius_bottom_right = 7
		fill.add_theme_stylebox_override("panel", fill_style)
		row.add_child(fill)
		fill.visible = false
		synergy_tooltip_tier_fills.append(fill)
		var badge := _add_texture(row, SYNERGY_TOOLTIP_ROOT + "tier_border_trim.png", Rect2(20, 5, 18, 20))
		synergy_tooltip_tier_badges.append(badge)
		var number := _add_label(row, "", Rect2(20, 3, 18, 21), 13, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
		synergy_tooltip_tier_numbers.append(number)
		var text_label := RichTextLabel.new()
		text_label.position = Vector2(44, 0)
		text_label.size = Vector2(236, 36)
		text_label.bbcode_enabled = true
		text_label.fit_content = false
		text_label.scroll_active = false
		text_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		text_label.add_theme_font_override("normal_font", source_han_font)
		text_label.add_theme_font_size_override("normal_font_size", 10)
		text_label.add_theme_color_override("default_color", Color.WHITE)
		text_label.scale.x = 1.0
		row.add_child(text_label)
		synergy_tooltip_tier_texts.append(text_label)
		if tier_index < 2:
			_make_dashed_divider(row, Vector2(0, 43), 281.0, 0)


func _show_synergy_tooltip(synergy: String) -> void:
	hovered_synergy = synergy
	var synergy_color := CATALOG.synergy_color(synergy)
	var count := int(synergy_current_counts.get(synergy, 0))
	var thresholds: Array = CATALOG.synergy_thresholds(synergy)
	var effects: Array = CATALOG.synergy_effect_lines(synergy)
	var active_tier := CATALOG.active_tier(synergy, count)
	for child in synergy_tooltip.get_children():
		if child is TextureRect and child.material is ShaderMaterial:
			var material := child.material as ShaderMaterial
			material.set_shader_parameter("rarity_color", synergy_color)
			material.set_shader_parameter("tint_strength", 0.84)
			material.set_shader_parameter("brightness", 0.72)
	synergy_tooltip_icon.texture = load(CATALOG.synergy_icon_path(synergy)) as Texture2D
	synergy_tooltip_title.text = "%s羁绊" % synergy
	synergy_tooltip_count.text = "当前数量：%d" % count
	for tier_index in 3:
		var row := synergy_tooltip_tier_rows[tier_index]
		var tier_visible := tier_index < thresholds.size()
		row.visible = tier_visible
		if not tier_visible:
			continue
		var activated := active_tier >= tier_index
		var fill := synergy_tooltip_tier_fills[tier_index]
		var circle := synergy_tooltip_tier_circles[tier_index]
		circle.visible = not activated
		fill.visible = activated
		var badge := synergy_tooltip_tier_badges[tier_index]
		var badge_material := ShaderMaterial.new()
		badge_material.shader = ITEM_INFO_TINT_SHADER
		badge_material.set_shader_parameter("rarity_color", synergy_color)
		badge_material.set_shader_parameter("tint_strength", 0.86)
		badge_material.set_shader_parameter("brightness", 0.72)
		badge.material = badge_material
		synergy_tooltip_tier_numbers[tier_index].text = "%d" % int(thresholds[tier_index])
		var effect_text := String(effects[tier_index])
		var effect_label := synergy_tooltip_tier_texts[tier_index]
		effect_label.position.y = 6.0 if source_han_font.get_string_size(effect_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x <= effect_label.size.x else 0.0
		effect_label.text = _synergy_colored_numbers(effect_text, synergy_color)
	synergy_tooltip.visible = true
	synergy_tooltip.move_to_front()


func _synergy_colored_numbers(text: String, color: Color) -> String:
	var value_pattern := RegEx.new()
	value_pattern.compile("([+-]?\\d+(?:\\.\\d+)?%?)")
	return value_pattern.sub(text, "[color=#%s]$1[/color]" % color.to_html(false), true)


func _hide_synergy_tooltip() -> void:
	hovered_synergy = ""
	synergy_tooltip.visible = false


func _update_synergies() -> void:
	var active_team: Array[String] = []
	for index in range(4, mini(creature_data.size(), 10)):
		if not creature_data[index].is_empty():
			active_team.append(creature_data[index])
	synergy_current_counts = CATALOG.count_synergies(active_team)
	var visible_row := 0
	for synergy in CATALOG.synergy_ids():
		var count := int(synergy_current_counts.get(synergy, 0))
		var row_visible := count > 0
		var row_y := visible_row * 36.0
		var row: ColorRect = synergy_row_frames[synergy]
		var icon_cell: ColorRect = synergy_icon_cells[synergy]
		var count_cell: ColorRect = synergy_count_cells[synergy]
		var icon: TextureRect = synergy_icons[synergy]
		var name_label: Label = synergy_name_labels[synergy]
		var count_label: Label = synergy_count_labels[synergy]
		var hover: Button = synergy_hover_buttons[synergy]
		row.visible = row_visible
		icon_cell.visible = row_visible
		count_cell.visible = row_visible
		icon.visible = row_visible
		name_label.visible = row_visible
		count_label.visible = row_visible
		hover.visible = row_visible
		if row_visible:
			row.position = Vector2(0, row_y)
			icon_cell.position = Vector2(0, row_y)
			icon.position = Vector2(5, row_y + 3)
			name_label.position = Vector2(34, row_y + 1)
			count_cell.position = Vector2(224, row_y)
			count_label.position = Vector2(224, row_y)
			hover.position = Vector2(0, row_y)
			synergy_row_positions[synergy] = 96.0 + row_y
			visible_row += 1
		var thresholds: Array = CATALOG.synergy_thresholds(synergy)
		var highlighted_step := CATALOG.active_tier(synergy, count)
		var maximum_threshold := int(thresholds[-1]) if not thresholds.is_empty() else 0
		count_label.text = "%d/%d" % [count, maximum_threshold]
		count_label.add_theme_color_override("font_color", Color.WHITE)
		var boxes: Array = synergy_step_boxes[synergy]
		var step_labels: Array = synergy_step_labels[synergy]
		for index in boxes.size():
			var step_width := 144.0 / maxf(float(thresholds.size()), 1.0)
			var step_x := 80.0 + index * step_width
			var box := boxes[index] as ColorRect
			var step_label := step_labels[index] as Label
			box.color = CATALOG.synergy_color(synergy)
			box.position = Vector2(step_x, row_y)
			box.size = Vector2(step_width, 30)
			step_label.position = Vector2(step_x, row_y)
			step_label.size = Vector2(step_width, 30)
			box.visible = row_visible and highlighted_step >= 0 and index == highlighted_step
			step_label.visible = row_visible
			step_label.add_theme_color_override("font_color", Color.WHITE if box.visible else Color("3b3972"))
	synergy_list.custom_minimum_size = Vector2(282, maxf(286.0, visible_row * 36.0))
	synergy_list.size = synergy_list.custom_minimum_size
	if not hovered_synergy.is_empty():
		if int(synergy_current_counts.get(hovered_synergy, 0)) > 0:
			_show_synergy_tooltip(hovered_synergy)
		else:
			_hide_synergy_tooltip()


func _build_shop() -> void:
	_add_texture(self, SHOP_PANEL_ASSET, Rect2(242, 526, 796, 190))
	var header_center_y := 551.0
	var rarity_chances := _shop_rarity_chances()
	var rarity_labels: Array[Label] = []
	for rarity_index in SHOP_RARITY_NAMES.size():
		var label_color := SHOP_RARITY_COLORS[rarity_index]
		var rarity_label := _add_label(
			self,
			"◆%d%%" % roundi(rarity_chances[rarity_index] * 100.0),
			Rect2(260 + rarity_index * 61, header_center_y - 12.0, 58, 24),
			10,
			label_color,
			HORIZONTAL_ALIGNMENT_CENTER
		)
		rarity_label.add_theme_color_override("font_shadow_color", Color(0.08, 0.10, 0.14, 0.82))
		rarity_label.add_theme_constant_override("shadow_offset_x", 1)
		rarity_label.add_theme_constant_override("shadow_offset_y", 1)
		rarity_labels.append(rarity_label)
	shop_data = _roll_shop_entries(true)
	for entry in shop_data:
		_mark_shop_creature_seen(entry)
	var card_width := 145.0
	var card_gap := 9.0
	var card_start_x := 264.0
	# Preserve the authored 115×94 Aseprite ratio at runtime.
	var card_height := card_width * 94.0 / 115.0
	for index in SHOP_CARD_COUNT:
		_create_shop_card(index, Rect2(card_start_x + index * (card_width + card_gap), 584, card_width, card_height))
	_add_texture(self, UI + "04_切图_4.png", Rect2(871, header_center_y - 10.0, 20, 20))
	coin_label = _add_label(self, "%dG" % coins, Rect2(895, header_center_y - 12.0, 58, 24), 13, Color("e4aa2f"), HORIZONTAL_ALIGNMENT_RIGHT)
	lock_button_texture = _add_texture(self, LOCK_ICON, Rect2(1000, header_center_y - 9.0, 18, 18))
	lock_button_texture.visible = false
	lock_button = Button.new()
	lock_button.position = Vector2(954, header_center_y - 16.0)
	lock_button.size = Vector2(70, 32)
	lock_button.flat = true
	lock_button.focus_mode = Control.FOCUS_NONE
	add_child(lock_button)
	lock_button.button_down.connect(_set_lock_button_pressed.bind(true))
	lock_button.button_up.connect(_set_lock_button_pressed.bind(false))
	lock_button.mouse_exited.connect(_set_lock_button_pressed.bind(false))
	lock_button.pressed.connect(_on_lock_pressed)
	lock_label = _add_label(self, "锁定", Rect2(954, header_center_y - 12.0, 70, 24), 10, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	_build_shop_sell_overlay()


func _build_shop_sell_overlay() -> void:
	shop_sell_overlay = Panel.new()
	shop_sell_overlay.position = Vector2(242, 526)
	shop_sell_overlay.size = Vector2(796, 190)
	shop_sell_overlay.z_index = 120
	shop_sell_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	shop_sell_overlay.add_theme_stylebox_override("panel", _slot_style(Color(0.015, 0.02, 0.025, 0.88), Color("e4aa2f"), 4))
	shop_sell_overlay.visible = false
	add_child(shop_sell_overlay)
	shop_sell_label = _add_label(shop_sell_overlay, "", Rect2(80, 50, 636, 90), 30, Color("ffd159"), HORIZONTAL_ALIGNMENT_CENTER)
	shop_sell_overlay.set_drag_forwarding(_get_shop_sell_drag_data, _can_drop_shop_sell_data, _drop_shop_sell_data)


func _build_footer_actions() -> void:
	var reroll := _add_texture_button(UI + "攻击力 (1).png", Rect2(5, 597, 198, 119), "刷新商店")
	reroll.focus_mode = Control.FOCUS_NONE
	reroll.pressed.connect(_on_reroll_pressed)
	_add_label(reroll, "刷新", Rect2(0, 23, 198, 36), 25, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	_add_label(reroll, "$1", Rect2(0, 62, 198, 32), 21, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	var shop_node := GameState.map_initialized and GameState.current_map_node_type() == "shop"
	var mimic_node := GameState.map_initialized and GameState.current_map_node_type() == "chest" and bool(GameState.current_map_node_data().get("mimic", false))
	var action_text := "离开商店" if shop_node else ("挑战宝箱怪" if mimic_node else "进入战斗")
	var battle := _add_texture_button(UI + "血量.png", Rect2(1075, 598, 198, 118), action_text)
	battle.focus_mode = Control.FOCUS_NONE
	if shop_node:
		battle.pressed.connect(_leave_shop)
	else:
		battle.pressed.connect(_on_battle_pressed)
	_add_label(battle, "返回地图" if shop_node else ("挑战宝箱怪" if mimic_node else "战斗！"), Rect2(0, 38, 198, 42), 27, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)


func _create_creature_slot(rect: Rect2, texture_path: String, slot_name: String, saved_level: int = 1, formation_slot := false, saved_equipment: Array = []) -> void:
	var compact_card := rect.size.y < 100.0
	var button := Button.new()
	button.name = slot_name
	button.position = rect.position
	button.size = rect.size
	button.set_meta("formation_slot", formation_slot)
	button.flat = true
	button.focus_mode = Control.FOCUS_NONE
	button.tooltip_text = ""
	button.add_theme_stylebox_override("normal", _slot_style(Color(0, 0, 0, 0), Color(0, 0, 0, 0)))
	button.add_theme_stylebox_override("hover", _slot_style(Color(0, 0, 0, 0), Color(0, 0, 0, 0)) if formation_slot else _slot_style(Color(0.1, 0.65, 0.8, 0.08), Color(0.3, 0.9, 1.0, 0.8), 2))
	add_child(button)
	var trait_background := TextureRect.new()
	trait_background.position = Vector2(3, 3)
	trait_background.size = rect.size - Vector2(6, 6)
	trait_background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	trait_background.stretch_mode = TextureRect.STRETCH_SCALE
	trait_background.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	trait_background.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	trait_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	trait_background.modulate = Color.WHITE
	trait_background.visible = false
	button.add_child(trait_background)
	var rarity_frame := Panel.new()
	rarity_frame.position = Vector2.ZERO
	rarity_frame.size = rect.size
	rarity_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rarity_frame.add_theme_stylebox_override("panel", _shop_card_outline_style(Color("737983")))
	rarity_frame.z_index = 35
	rarity_frame.visible = false
	button.add_child(rarity_frame)
	var sprite := TextureRect.new()
	sprite.position = Vector2(18, 4) if formation_slot else (Vector2(12, 7) if compact_card else Vector2(18, 9))
	sprite.size = PREP_FORMATION_SPRITE_SIZE if formation_slot else (Vector2(rect.size.x - 24, rect.size.y - 18) if compact_card else Vector2(rect.size.x - 36, rect.size.y - 25))
	sprite.pivot_offset = sprite.size * 0.5
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(sprite)
	var level_label := _add_label(button, "", Rect2(5, 2, 48, 17) if compact_card else Rect2(7, 3, 54, 19), 9 if compact_card else 10, Color.WHITE)
	level_label.visible = false
	var star_row := _create_star_row(button, Rect2(5, 2, 48, 17) if compact_card else Rect2(7, 3, 54, 19))
	var badge_width := 27.0 if compact_card else 30.0
	var badge_gap := 2.0 if compact_card else 3.0
	var badge_x := rect.size.x - badge_width * 2.0 - badge_gap - 3.0
	var badge_height := 21.0 if compact_card else 24.0
	var badge_y := rect.size.y - (23.0 if compact_card else 27.0)
	var hp_badge := _add_stat_badge(button, Rect2(badge_x, badge_y, badge_width, badge_height), Color("ef3f67"))
	var special_badge := _add_stat_badge(button, Rect2(badge_x + badge_width + badge_gap, badge_y, badge_width, badge_height), Color("3184a4"))
	var hp_label := _add_label(button, "", Rect2(badge_x, badge_y + 1, badge_width, badge_height - 3), 9 if compact_card else 10, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	var special_label := _add_label(button, "", Rect2(badge_x + badge_width + badge_gap, badge_y + 1, badge_width, badge_height - 3), 9 if compact_card else 10, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	_apply_stat_pixel_font(hp_label)
	_apply_stat_pixel_font(special_label)
	var trait_icon_size := 17.0
	var trait_icon_gap := 8.0
	var trait_icon_x := 10.0
	var trait_icon_y := rect.size.y - (21.0 if compact_card else 25.0)
	var icon_box_size := 21.0
	var element_background := _add_shop_icon_background(button, Rect2(trait_icon_x - 2, trait_icon_y - 2, icon_box_size, icon_box_size))
	var extra_background := _add_shop_icon_background(button, Rect2(trait_icon_x + trait_icon_size + trait_icon_gap - 2, trait_icon_y - 2, icon_box_size, icon_box_size))
	var race_background := _add_shop_icon_background(button, Rect2(trait_icon_x + (trait_icon_size + trait_icon_gap) * 2.0 - 2, trait_icon_y - 2, icon_box_size, icon_box_size))
	var element_icon := _add_texture(button, TRAIT_ICON_PATHS["自然"], Rect2(trait_icon_x, trait_icon_y, trait_icon_size, trait_icon_size))
	var extra_trait_icon := _add_texture(button, TRAIT_ICON_PATHS["雷"], Rect2(trait_icon_x + trait_icon_size + trait_icon_gap, trait_icon_y, trait_icon_size, trait_icon_size))
	var race_icon := _add_texture(button, TRAIT_ICON_PATHS["机械"], Rect2(trait_icon_x + (trait_icon_size + trait_icon_gap) * 2.0, trait_icon_y, trait_icon_size, trait_icon_size))
	element_icon.visible = false
	extra_trait_icon.visible = false
	race_icon.visible = false
	var replace_mask := ColorRect.new()
	replace_mask.position = Vector2(3, 3)
	replace_mask.size = rect.size - Vector2(6, 6)
	replace_mask.color = Color(0, 0, 0, 0.52)
	replace_mask.mouse_filter = Control.MOUSE_FILTER_IGNORE
	replace_mask.visible = false
	button.add_child(replace_mask)
	var selection_frame_rect := Rect2(8, 0, 96, 96) if formation_slot else Rect2(Vector2.ZERO, rect.size)
	var selection_frame := _add_texture(button, "res://素材/图鉴/image-1785681904517-raawndjoah.png", selection_frame_rect, TextureRect.STRETCH_SCALE)
	selection_frame.pivot_offset = selection_frame.size * 0.5
	selection_frame.visible = false
	creature_buttons.append(button)
	creature_sprites.append(sprite)
	creature_level_labels.append(level_label)
	creature_star_rows.append(star_row)
	creature_hp_labels.append(hp_label)
	creature_special_labels.append(special_label)
	creature_hp_badges.append(hp_badge)
	creature_special_badges.append(special_badge)
	creature_element_icons.append(element_icon)
	creature_race_icons.append(race_icon)
	creature_extra_trait_icons.append(extra_trait_icon)
	creature_trait_backgrounds.append(trait_background)
	creature_element_icon_backgrounds.append(element_background)
	creature_extra_icon_backgrounds.append(extra_background)
	creature_race_icon_backgrounds.append(race_background)
	creature_rarity_frames.append(rarity_frame)
	creature_masks.append(replace_mask)
	creature_selection_frames.append(selection_frame)
	creature_data.append(texture_path)
	creature_levels.append(0 if texture_path.is_empty() else clampi(saved_level, 1, 3))
	var equipment_slots: Array[String] = []
	for equipment_id in saved_equipment:
		var normalized_id := String(equipment_id)
		if not EQUIPMENT_CATALOG.data(normalized_id).is_empty() and normalized_id not in equipment_slots and equipment_slots.size() < 2:
			equipment_slots.append(normalized_id)
	creature_equipment.append(equipment_slots)
	var equipment_icons: Array[TextureRect] = []
	for equipment_index in 2:
		var equipment_icon := TextureRect.new()
		equipment_icon.position = Vector2(rect.size.x - 22, 6 + equipment_index * 21) if formation_slot else Vector2(5 + equipment_index * 21, rect.size.y - 45)
		equipment_icon.size = Vector2(18, 18)
		equipment_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		equipment_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		equipment_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		equipment_icon.mouse_filter = Control.MOUSE_FILTER_STOP
		equipment_icon.z_index = 42
		button.add_child(equipment_icon)
		equipment_icons.append(equipment_icon)
	creature_equipment_icons.append(equipment_icons)
	var slot_index := creature_buttons.size() - 1
	for equipment_index in 2:
		(equipment_icons[equipment_index] as TextureRect).gui_input.connect(_on_equipment_icon_input.bind(slot_index, equipment_index))
	button.set_drag_forwarding(
		_get_creature_drag_data.bind(slot_index),
		_can_drop_creature_data.bind(slot_index),
		_drop_creature_data.bind(slot_index)
	)
	button.mouse_entered.connect(_show_creature_selection_frame.bind(slot_index))
	button.mouse_exited.connect(_hide_card_tooltip)
	button.mouse_exited.connect(_hide_creature_selection_frame.bind(slot_index))
	button.gui_input.connect(_on_creature_card_gui_input.bind(slot_index))
	_render_creature_slot(slot_index)


func _create_shop_card(index: int, rect: Rect2) -> void:
	var button := Button.new()
	button.position = rect.position
	button.size = rect.size
	button.flat = true
	button.focus_mode = Control.FOCUS_NONE
	button.tooltip_text = ""
	button.add_theme_stylebox_override("normal", _slot_style(Color(0, 0, 0, 0), Color(0, 0, 0, 0)))
	button.add_theme_stylebox_override("hover", _slot_style(Color(1.0, 0.93, 0.66, 0.16), Color(1.0, 0.75, 0.12), 3))
	add_child(button)
	shop_buttons.append(button)
	var top_height := rect.size.y * 72.0 / 94.0
	var content_layer := _add_texture(button, SHOP_CARD_ASSETS[0], Rect2(Vector2.ZERO, rect.size), TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	var trait_background := TextureRect.new()
	trait_background.position = Vector2(rect.size.x * 5.0 / 115.0, rect.size.y * 5.0 / 94.0)
	trait_background.size = Vector2(rect.size.x * 105.0 / 115.0, rect.size.y * 66.0 / 94.0)
	trait_background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	trait_background.stretch_mode = TextureRect.STRETCH_SCALE
	trait_background.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	trait_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	trait_background.modulate = Color.WHITE
	trait_background.visible = false
	button.add_child(trait_background)
	var creature_overlay := TextureRect.new()
	creature_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(creature_overlay)
	var portrait_clip := Control.new()
	portrait_clip.position = trait_background.position
	portrait_clip.size = trait_background.size
	portrait_clip.clip_contents = true
	portrait_clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(portrait_clip)
	var sprite := TextureRect.new()
	# The reference intentionally lets the portrait exceed the inner image area;
	# the dedicated clip keeps those pixels behind the authored black frame.
	sprite.position = Vector2(24.4, -14.85)
	sprite.size = Vector2(121.2, 108.7)
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait_clip.add_child(sprite)
	var element_background := _add_shop_icon_background(button, Rect2(8, 46, 18, 18))
	var extra_background := _add_shop_icon_background(button, Rect2(8, 69.416667, 18, 18))
	var race_background := _add_shop_icon_background(button, Rect2(8, 69.416667, 18, 18))
	var element_icon := _add_texture(button, TRAIT_ICON_PATHS["自然"], Rect2(10, 48, 14, 14))
	var extra_trait_icon := _add_texture(button, TRAIT_ICON_PATHS["雷"], Rect2(10, 71.416667, 14, 14))
	var race_icon := _add_texture(button, TRAIT_ICON_PATHS["机械"], Rect2(10, 71.416667, 14, 14))
	var element_label := _add_label(button, "", Rect2(28.5, 42, 44.5, 20), 8, Color.WHITE)
	var secondary_trait_label := _add_label(button, "", Rect2(28.5, 65.666667, 44.5, 20), 8, Color.WHITE)
	element_background.visible = false
	extra_background.visible = false
	race_background.visible = false
	element_icon.visible = false
	extra_trait_icon.visible = false
	race_icon.visible = false
	var stat_width := 34.0
	var stat_gap := 4.0
	var stat_x := (rect.size.x - stat_width * 2.0 - stat_gap) * 0.5
	var stat_y := top_height - 27.0
	var hp_label := _add_label(button, "", Rect2(stat_x, stat_y, stat_width, 18), 9, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	var special_label := _add_label(button, "", Rect2(stat_x + stat_width + stat_gap, stat_y, stat_width, 18), 9, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	var hp_badge := _add_stat_badge(button, Rect2(stat_x, stat_y - 1, stat_width, 21), Color("ef3f67"))
	var special_badge := _add_stat_badge(button, Rect2(stat_x + stat_width + stat_gap, stat_y - 1, stat_width, 21), Color("3184a4"))
	hp_label.visible = false
	special_label.visible = false
	hp_badge.visible = false
	special_badge.visible = false
	hp_label.move_to_front()
	special_label.move_to_front()
	_apply_stat_pixel_font(hp_label)
	_apply_stat_pixel_font(special_label)
	var name_label := _add_label(button, "", Rect2(7, top_height, 96, 24), 9, Color("f4f5f6"))
	var coin_icon := _add_texture(button, SHOP_CARD_COIN_ICON, Rect2(rect.size.x - 28.666667, top_height + 8, 10, 10))
	# Keep the coin icon at its authored position and place the numerals one
	# pixel lower than the previous adjustment.
	var price_label := _add_label(button, "", Rect2(rect.size.x - 17.5, top_height + 0.75, 11, 24), 10, Color("f8df93"), HORIZONTAL_ALIGNMENT_RIGHT)
	name_label.z_index = 22
	price_label.z_index = 22
	var card_outline := Panel.new()
	card_outline.position = Vector2.ZERO
	card_outline.size = rect.size
	card_outline.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_outline.add_theme_stylebox_override("panel", _shop_card_outline_style(Color(0.66, 0.67, 0.72, 1.0)))
	button.add_child(card_outline)
	var outer_layer := _add_texture(button, SHOP_CARD_FRAME_ASSET, Rect2(Vector2.ZERO, rect.size))
	outer_layer.visible = false
	card_outline.move_to_front()
	var shop_level := _add_label(button, "", Rect2(8, 5, 64, 20), 9, Color.WHITE)
	shop_level.visible = false
	shop_level.add_theme_color_override("font_color", LEVEL_COLORS[0])
	var shop_stars := _create_star_row(button, Rect2(8, 4, 54, 20))
	var sold_out := _add_texture(button, SOLD_OUT_ICON.resource_path, Rect2((rect.size.x - 160.0) * 0.5, (top_height - 60.0) * 0.5, 160, 60))
	var sold_shade := ColorRect.new()
	sold_shade.position = Vector2(3, 3)
	sold_shade.size = rect.size - Vector2(6, 6)
	sold_shade.color = Color(0, 0, 0, 0.68)
	sold_shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sold_shade.visible = false
	sold_shade.z_index = 25
	button.add_child(sold_shade)
	sold_out.position = Vector2((rect.size.x - 80.0) * 0.5, (top_height - 30.0) * 0.5)
	sold_out.size = Vector2(80, 30)
	sold_out.pivot_offset = sold_out.size * 0.5
	sold_out.rotation = deg_to_rad(-30.0)
	sold_out.visible = false
	sold_out.z_index = 30
	var lock_overlay := _add_texture(button, LOCK_ICON, Rect2(rect.size.x - 31, 3, 26, 26))
	lock_overlay.visible = false
	lock_overlay.z_index = 40
	lock_overlay.pivot_offset = lock_overlay.size * 0.5
	shop_sprites.append(sprite)
	shop_portrait_clips.append(portrait_clip)
	shop_hp_labels.append(hp_label)
	shop_special_labels.append(special_label)
	shop_hp_badges.append(hp_badge)
	shop_special_badges.append(special_badge)
	shop_level_labels.append(shop_level)
	shop_star_rows.append(shop_stars)
	shop_element_icons.append(element_icon)
	shop_race_icons.append(race_icon)
	shop_extra_trait_icons.append(extra_trait_icon)
	shop_trait_backgrounds.append(trait_background)
	shop_attribute_layers.append(content_layer)
	shop_creature_overlays.append(creature_overlay)
	shop_outer_layers.append(outer_layer)
	shop_name_labels.append(name_label)
	shop_price_labels.append(price_label)
	shop_element_labels.append(element_label)
	shop_secondary_trait_labels.append(secondary_trait_label)
	shop_coin_icons.append(coin_icon)
	shop_sold_out_overlays.append(sold_out)
	shop_sold_out_shades.append(sold_shade)
	shop_card_outlines.append(card_outline)
	shop_lock_overlays.append(lock_overlay)
	shop_element_icon_backgrounds.append(element_background)
	shop_extra_icon_backgrounds.append(extra_background)
	shop_race_icon_backgrounds.append(race_background)
	button.pressed.connect(_on_shop_card_pressed.bind(index))
	button.mouse_entered.connect(_shake_shop_card.bind(button))
	button.mouse_exited.connect(_hide_card_tooltip)
	button.gui_input.connect(_on_shop_card_gui_input.bind(index))
	_render_shop_card(index)


func _add_shop_icon_background(parent: Control, rect: Rect2) -> TextureRect:
	var background := _add_texture(parent, SHOP_ATTRIBUTE_FRAME_ASSET, rect, TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	background.modulate = Color.WHITE
	return background


func _build_card_tooltip() -> void:
	card_tooltip = Panel.new()
	card_tooltip.size = Vector2(292, 331)
	card_tooltip.z_index = 180
	card_tooltip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_tooltip.add_theme_stylebox_override("panel", _slot_style(Color(0.97, 0.97, 0.98, 0.99), Color(0.18, 0.2, 0.24, 1.0), 4))
	card_tooltip.visible = false
	add_child(card_tooltip)
	card_tooltip_legacy_header = ColorRect.new()
	card_tooltip_legacy_header.position = Vector2(8, 8)
	card_tooltip_legacy_header.size = Vector2(276, 38)
	card_tooltip_legacy_header.color = Color(0.43, 0.43, 0.48, 1.0)
	card_tooltip_legacy_header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_tooltip.add_child(card_tooltip_legacy_header)
	card_tooltip_name = _add_label(card_tooltip, "", Rect2(18, 8, 165, 38), 19, Color.WHITE)
	card_tooltip_rarity = _add_label(card_tooltip, "", Rect2(180, 8, 94, 38), 16, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	card_tooltip_portrait_panel = Panel.new()
	card_tooltip_portrait_panel.position = Vector2(16, 58)
	card_tooltip_portrait_panel.size = Vector2(128, 128)
	card_tooltip_portrait_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_tooltip_portrait_panel.add_theme_stylebox_override("panel", _slot_style(Color(0.99, 0.99, 1.0, 1.0), Color(0.68, 0.69, 0.74, 1.0), 3))
	card_tooltip.add_child(card_tooltip_portrait_panel)
	card_tooltip_sprite = _add_texture(card_tooltip_portrait_panel, CREATURE_TEXTURES[0], Rect2(12, 12, 104, 104))
	card_tooltip_element_panel = Panel.new()
	card_tooltip_element_panel.position = Vector2(158, 70)
	card_tooltip_element_panel.size = Vector2(116, 44)
	card_tooltip_element_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_tooltip_element_panel.add_theme_stylebox_override("panel", _slot_style(Color("9eaa38"), Color(0.58, 0.61, 0.22), 1))
	card_tooltip.add_child(card_tooltip_element_panel)
	card_tooltip_element_icon = _add_texture(card_tooltip_element_panel, TRAIT_ICON_PATHS["自然"], Rect2(9, 7, 30, 30))
	card_tooltip_element = _add_label(card_tooltip_element_panel, "", Rect2(42, 4, 66, 36), 14, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	card_tooltip_race_panel = Panel.new()
	card_tooltip_race_panel.position = Vector2(158, 127)
	card_tooltip_race_panel.size = Vector2(116, 44)
	card_tooltip_race_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_tooltip_race_panel.add_theme_stylebox_override("panel", _slot_style(Color("8eafe0"), Color(0.53, 0.64, 0.82), 1))
	card_tooltip.add_child(card_tooltip_race_panel)
	card_tooltip_race_icon = _add_texture(card_tooltip_race_panel, TRAIT_ICON_PATHS["机械"], Rect2(9, 7, 30, 30))
	card_tooltip_race = _add_label(card_tooltip_race_panel, "", Rect2(42, 4, 66, 36), 14, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	card_tooltip_info_panel = Panel.new()
	card_tooltip_info_panel.position = Vector2(16, 199)
	card_tooltip_info_panel.size = Vector2(258, 116)
	card_tooltip_info_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_tooltip_info_panel.add_theme_stylebox_override("panel", _slot_style(Color(0.99, 0.99, 1.0, 1.0), Color(0.68, 0.69, 0.74, 1.0), 3))
	card_tooltip.add_child(card_tooltip_info_panel)
	card_tooltip_cooldown = _add_label(card_tooltip_info_panel, "", Rect2(10, 8, 62, 98), 17, Color("252631"), HORIZONTAL_ALIGNMENT_CENTER)
	card_tooltip_damage = _add_label(card_tooltip_info_panel, "", Rect2(76, 8, 170, 38), 12, Color("ef3f64"))
	card_tooltip_damage.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	card_tooltip_extra = _add_label(card_tooltip_info_panel, "", Rect2(76, 45, 170, 63), 10, Color("5579b9"))
	card_tooltip_extra.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_build_creature_tooltip_layers()
	_build_item_tooltip_layers()


func _build_creature_tooltip_layers() -> void:
	card_tooltip_gradient = TextureRect.new()
	card_tooltip_gradient.position = Vector2(4, 4)
	card_tooltip_gradient.size = Vector2(361, 297)
	card_tooltip_gradient.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	card_tooltip_gradient.stretch_mode = TextureRect.STRETCH_SCALE
	card_tooltip_gradient.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_tooltip_gradient.z_index = -2
	card_tooltip.add_child(card_tooltip_gradient)
	creature_tooltip_nodes.append(card_tooltip_gradient)

	card_tooltip_shadow = Panel.new()
	# A short capsule reads as a flat oval and stays centered below the portrait.
	card_tooltip_shadow.position = Vector2(56.5, 177)
	card_tooltip_shadow.size = Vector2(92, 8)
	card_tooltip_shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shadow_style := _slot_style(Color(0.18, 0.22, 0.32, 0.18), Color.TRANSPARENT, 0)
	shadow_style.corner_radius_top_left = 4
	shadow_style.corner_radius_top_right = 4
	shadow_style.corner_radius_bottom_left = 4
	shadow_style.corner_radius_bottom_right = 4
	card_tooltip_shadow.add_theme_stylebox_override("panel", shadow_style)
	card_tooltip.add_child(card_tooltip_shadow)
	creature_tooltip_nodes.append(card_tooltip_shadow)

	card_tooltip_header_divider = ColorRect.new()
	card_tooltip_header_divider.position = Vector2(4, 46)
	card_tooltip_header_divider.size = Vector2(361, 1)
	card_tooltip_header_divider.color = Color("d9dee7")
	card_tooltip_header_divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_tooltip.add_child(card_tooltip_header_divider)

	card_tooltip_rarity_badge = Panel.new()
	card_tooltip_rarity_badge.position = Vector2(305, 12.5)
	card_tooltip_rarity_badge.size = Vector2(47, 25)
	card_tooltip_rarity_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var rarity_style := _slot_style(Color("eef0f4"), Color.TRANSPARENT, 0)
	rarity_style.corner_radius_top_left = 8
	rarity_style.corner_radius_top_right = 8
	rarity_style.corner_radius_bottom_left = 8
	rarity_style.corner_radius_bottom_right = 8
	card_tooltip_rarity_badge.add_theme_stylebox_override("panel", rarity_style)
	card_tooltip.add_child(card_tooltip_rarity_badge)
	card_tooltip_name_icon = _add_label(card_tooltip, "◆", Rect2(16, 9, 27, 32), 22, Color("ef3f64"), HORIZONTAL_ALIGNMENT_CENTER)

	card_tooltip_bottom_panel = Panel.new()
	card_tooltip_bottom_panel.position = Vector2(16, 202)
	card_tooltip_bottom_panel.size = Vector2(337, 91)
	card_tooltip_bottom_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bottom_style := _slot_style(Color(1, 1, 1, 0.90), Color("d9dee7"), 1)
	bottom_style.corner_radius_top_left = 7
	bottom_style.corner_radius_top_right = 7
	bottom_style.corner_radius_bottom_left = 7
	bottom_style.corner_radius_bottom_right = 7
	card_tooltip_bottom_panel.add_theme_stylebox_override("panel", bottom_style)
	card_tooltip.add_child(card_tooltip_bottom_panel)

	card_tooltip_skill_divider = ColorRect.new()
	card_tooltip_skill_divider.position = Vector2(81, 212)
	card_tooltip_skill_divider.size = Vector2(1, 70)
	card_tooltip_skill_divider.color = Color("d9dee7")
	card_tooltip_skill_divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_tooltip.add_child(card_tooltip_skill_divider)
	card_tooltip_horizontal_divider = _make_dashed_divider(card_tooltip, Vector2(92, 239), 238, 1)

	card_tooltip_star = _add_texture(card_tooltip, STAR_ICON.resource_path, Rect2(158, 3, 22, 22))
	card_tooltip_star.visible = false
	card_tooltip_star_label = _add_label(card_tooltip, "★", Rect2(155, 2, 28, 24), 15, Color("f5b600"), HORIZONTAL_ALIGNMENT_CENTER)
	card_tooltip_price = _add_label(card_tooltip, "", Rect2(305, 15, 47, 25), 12, Color("202530"), HORIZONTAL_ALIGNMENT_CENTER)
	card_tooltip_role_icon = _add_texture(card_tooltip, BATTLE_MELEE_ICON.resource_path, Rect2(92, 247, 18, 18))
	card_tooltip_role = _add_label(card_tooltip, "", Rect2(308, 216.5, 37, 18), 11, Color("252b35"), HORIZONTAL_ALIGNMENT_CENTER)
	card_tooltip_cooldown_caption = _add_label(card_tooltip, "攻击间隔", Rect2(308, 204.5, 37, 12), 7, Color("252b35"), HORIZONTAL_ALIGNMENT_CENTER)
	for cooldown_label in [card_tooltip_role, card_tooltip_cooldown_caption]:
		cooldown_label.set_meta("disable_text_shadow", true)
		cooldown_label.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
		cooldown_label.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		cooldown_label.add_theme_constant_override("outline_size", 0)
		cooldown_label.add_theme_constant_override("shadow_offset_x", 0)
		cooldown_label.add_theme_constant_override("shadow_offset_y", 0)
	card_tooltip_clock_icon = _add_texture(card_tooltip, CHARACTER_INFO_TIME_ICON.resource_path, Rect2(287, 213, 18, 18))
	card_tooltip_skill_backdrop = Panel.new()
	card_tooltip_skill_backdrop.position = Vector2(28, 211)
	card_tooltip_skill_backdrop.size = Vector2(45, 45)
	card_tooltip_skill_backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var skill_backdrop_style := _slot_style(Color("ef3f64"), Color("ffc1cc"), 2)
	skill_backdrop_style.corner_radius_top_left = 23
	skill_backdrop_style.corner_radius_top_right = 23
	skill_backdrop_style.corner_radius_bottom_left = 23
	skill_backdrop_style.corner_radius_bottom_right = 23
	card_tooltip_skill_backdrop.add_theme_stylebox_override("panel", skill_backdrop_style)
	card_tooltip.add_child(card_tooltip_skill_backdrop)
	card_tooltip_skill_icon = _add_texture(card_tooltip, BATTLE_MELEE_ICON.resource_path, Rect2(34, 217, 33, 33))
	card_tooltip_active_label = _add_label(card_tooltip, "主动技能", Rect2(28, 261, 45, 18), 8, Color("e33d5e"), HORIZONTAL_ALIGNMENT_CENTER)
	card_tooltip_active_label.add_theme_stylebox_override("normal", _slot_style(Color("ffe0e6"), Color.TRANSPARENT, 0))
	card_tooltip_skill_name = _add_label(card_tooltip, "", Rect2(92, 209, 82, 26), 14, Color("e43d5d"))
	card_tooltip_skill_damage = _add_label(card_tooltip, "", Rect2(174, 210.5, 80, 18), 9, Color("e43d5d"), HORIZONTAL_ALIGNMENT_CENTER)
	card_tooltip_skill_text = RichTextLabel.new()
	card_tooltip_skill_text.set_meta("disable_text_shadow", true)
	card_tooltip_skill_text.position = Vector2(92, 244)
	card_tooltip_skill_text.size = Vector2(187, 40)
	card_tooltip_skill_text.bbcode_enabled = true
	card_tooltip_skill_text.fit_content = false
	card_tooltip_skill_text.scroll_active = false
	card_tooltip_skill_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	card_tooltip_skill_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_tooltip_skill_text.add_theme_font_override("normal_font", source_han_font)
	card_tooltip_skill_text.add_theme_font_size_override("normal_font_size", 9)
	card_tooltip_skill_text.add_theme_color_override("default_color", Color("303642"))
	card_tooltip_skill_text.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	card_tooltip_skill_text.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
	card_tooltip_skill_text.add_theme_constant_override("outline_size", 0)
	card_tooltip_skill_text.add_theme_constant_override("shadow_offset_x", 0)
	card_tooltip_skill_text.add_theme_constant_override("shadow_offset_y", 0)
	card_tooltip.add_child(card_tooltip_skill_text)

	for node in [card_tooltip_header_divider, card_tooltip_rarity_badge, card_tooltip_name_icon, card_tooltip_bottom_panel, card_tooltip_skill_divider, card_tooltip_horizontal_divider, card_tooltip_star, card_tooltip_star_label, card_tooltip_price, card_tooltip_role_icon, card_tooltip_role, card_tooltip_cooldown_caption, card_tooltip_clock_icon, card_tooltip_skill_backdrop, card_tooltip_skill_icon, card_tooltip_active_label, card_tooltip_skill_name, card_tooltip_skill_damage, card_tooltip_skill_text]:
		creature_tooltip_nodes.append(node)


func _build_item_tooltip_layers() -> void:
	for asset_name in ["frame.png", "header.png", "header_accent.png", "rarity_icon_shadow.png", "rarity_icon_border.png", "rarity_icon_fill.png", "portrait_border.png", "portrait_fill.png", "rarity_badge.png"]:
		var layer := _add_texture(card_tooltip, ITEM_INFO_ROOT + asset_name, Rect2(0, 0, 292, 206), TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
		layer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		layer.z_index = 10
		layer.visible = false
		if asset_name in ["header.png", "header_accent.png", "rarity_icon_border.png", "rarity_icon_fill.png", "rarity_badge.png", "portrait_border.png", "portrait_fill.png"]:
			var material := ShaderMaterial.new()
			material.shader = ITEM_INFO_TINT_SHADER
			layer.material = material
		item_tooltip_layers.append(layer)
	item_tooltip_type = _add_label(card_tooltip, "", Rect2(155, 59, 126, 28), 16, Color("252b35"))
	item_tooltip_type.z_index = 12
	item_tooltip_effect = RichTextLabel.new()
	item_tooltip_effect.position = Vector2(157, 88)
	item_tooltip_effect.size = Vector2(126, 62)
	item_tooltip_effect.bbcode_enabled = true
	item_tooltip_effect.fit_content = false
	item_tooltip_effect.scroll_active = false
	item_tooltip_effect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	item_tooltip_effect.add_theme_font_override("normal_font", source_han_font)
	item_tooltip_effect.add_theme_font_size_override("normal_font_size", 11)
	item_tooltip_effect.add_theme_color_override("default_color", Color("596275"))
	item_tooltip_effect.z_index = 12
	card_tooltip.add_child(item_tooltip_effect)
	item_tooltip_rule = RichTextLabel.new()
	item_tooltip_rule.position = Vector2(157, 151)
	item_tooltip_rule.size = Vector2(126, 34)
	item_tooltip_rule.bbcode_enabled = true
	item_tooltip_rule.fit_content = false
	item_tooltip_rule.scroll_active = false
	item_tooltip_rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	item_tooltip_rule.add_theme_font_override("normal_font", source_han_font)
	item_tooltip_rule.add_theme_font_size_override("normal_font_size", 10)
	item_tooltip_rule.add_theme_color_override("default_color", Color("596275"))
	item_tooltip_rule.z_index = 12
	card_tooltip.add_child(item_tooltip_rule)
	item_tooltip_divider = _make_dashed_divider(card_tooltip, Vector2(157, 146), 126.0, 12)
	item_tooltip_layers.append_array([item_tooltip_type, item_tooltip_effect, item_tooltip_rule, item_tooltip_divider])
	_set_item_tooltip_visible(false)


func _make_dashed_divider(parent: Control, start: Vector2, width: float, z := 0) -> Control:
	var line := Control.new()
	line.position = start
	line.size = Vector2(width, 1)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	line.z_index = z
	var dash_width := 5.0
	var gap_width := 4.0
	var x := 0.0
	while x < width:
		var dash := ColorRect.new()
		dash.position = Vector2(x, 0)
		dash.size = Vector2(minf(dash_width, width - x), 1)
		dash.color = Color("c8cbd2")
		dash.mouse_filter = Control.MOUSE_FILTER_IGNORE
		line.add_child(dash)
		x += dash_width + gap_width
	parent.add_child(line)
	return line


func _set_item_tooltip_visible(visible_value: bool) -> void:
	card_tooltip_legacy_header.visible = not visible_value
	for layer_index in item_tooltip_layers.size():
		var node := item_tooltip_layers[layer_index]
		# Layers 3..5 are the old title-side icon; layer 8 is the blue badge
		# with baked text. The shared transparent tag is drawn by the Label.
		node.visible = visible_value and layer_index not in [3, 4, 5, 8]
	for node in creature_tooltip_nodes:
		node.visible = not visible_value


func _set_creature_tooltip_visible(visible_value: bool) -> void:
	card_tooltip_legacy_header.visible = not visible_value
	card_tooltip_info_panel.visible = false
	for node in [card_tooltip_element_panel, card_tooltip_race_panel, card_tooltip_element_icon, card_tooltip_element, card_tooltip_race_icon, card_tooltip_race]:
		node.visible = visible_value
	for node in creature_tooltip_nodes:
		node.visible = visible_value


func _blue_item_values(text: String) -> String:
	var value_pattern := RegEx.new()
	value_pattern.compile("([+-]?\\d+(?:\\.\\d+)?%?)")
	return value_pattern.sub(text, "[color=#4f83c2]$1[/color]", true)


func _apply_item_tooltip_rarity(rarity_color: Color) -> void:
	var tint_strengths := {1: 0.82, 2: 0.96, 4: 0.92, 5: 0.84, 6: 0.42, 7: 0.12, 8: 0.72}
	var brightnesses := {1: 0.54, 2: 0.88, 4: 0.82, 5: 0.72, 6: 0.62, 7: 1.0, 8: 0.72}
	for layer_index in 9:
		var layer := item_tooltip_layers[layer_index]
		if layer is TextureRect and layer.material is ShaderMaterial:
			var material := layer.material as ShaderMaterial
			material.set_shader_parameter("rarity_color", rarity_color)
			material.set_shader_parameter("tint_strength", float(tint_strengths.get(layer_index, 0.8)))
			material.set_shader_parameter("brightness", float(brightnesses.get(layer_index, 1.0)))


func _show_creature_card_tooltip(index: int) -> void:
	if index < 0 or index >= creature_data.size() or creature_data[index].is_empty():
		_hide_card_tooltip()
		return
	_show_card_tooltip(creature_data[index], creature_levels[index])


func _on_creature_card_gui_input(event: InputEvent, index: int) -> void:
	if not event is InputEventMouseButton or event.button_index != MOUSE_BUTTON_RIGHT:
		return
	CursorManager.set_inspecting(event.pressed)
	if event.pressed:
		_show_creature_card_tooltip(index)
	creature_buttons[index].accept_event()


func _show_shop_card_tooltip(index: int) -> void:
	if index < 0 or index >= shop_data.size() or shop_data[index].is_empty():
		_hide_card_tooltip()
		return
	var entry: Dictionary = shop_data[index]
	if entry["kind"] != "creature":
		_show_item_card_tooltip(entry)
	else:
		_show_card_tooltip(entry["path"], 1)


func _on_shop_card_gui_input(event: InputEvent, index: int) -> void:
	if not event is InputEventMouseButton or event.button_index != MOUSE_BUTTON_RIGHT:
		return
	CursorManager.set_inspecting(event.pressed)
	if event.pressed:
		_show_shop_card_tooltip(index)
	shop_buttons[index].accept_event()


func _show_card_tooltip(texture_path: String, level: int) -> void:
	card_tooltip.size = Vector2(369, 305)
	var outer_style := _slot_style(Color.TRANSPARENT, Color.BLACK, 4)
	outer_style.corner_radius_top_left = 10
	outer_style.corner_radius_top_right = 10
	outer_style.corner_radius_bottom_left = 10
	outer_style.corner_radius_bottom_right = 10
	outer_style.anti_aliasing = false
	card_tooltip.add_theme_stylebox_override("panel", outer_style)
	_set_item_tooltip_visible(false)
	_set_creature_tooltip_visible(true)
	card_tooltip_name.visible = true
	card_tooltip_rarity.visible = true
	card_tooltip_name.set_meta("disable_text_shadow", true)
	card_tooltip_rarity.set_meta("disable_text_shadow", true)
	card_tooltip_sprite.visible = true
	card_tooltip_name.position = Vector2(47, 6)
	card_tooltip_name.size = Vector2(190, 38)
	card_tooltip_name.add_theme_font_size_override("font_size", 22)
	card_tooltip_name.add_theme_color_override("font_color", Color("252b35"))
	card_tooltip_name.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	card_tooltip_name.add_theme_constant_override("shadow_offset_x", 0)
	card_tooltip_name.add_theme_constant_override("shadow_offset_y", 0)
	card_tooltip_portrait_panel.position = Vector2(16, 58)
	card_tooltip_portrait_panel.size = Vector2(173, 132)
	var portrait_style := _slot_style(Color(1, 1, 1, 0.44), Color("d9dee7"), 1)
	portrait_style.corner_radius_top_left = 7
	portrait_style.corner_radius_top_right = 7
	portrait_style.corner_radius_bottom_left = 7
	portrait_style.corner_radius_bottom_right = 7
	card_tooltip_portrait_panel.add_theme_stylebox_override("panel", portrait_style)
	card_tooltip_sprite.position = Vector2(14, 6)
	card_tooltip_sprite.size = Vector2(145, 116)
	card_tooltip_name.z_index = 12
	card_tooltip_rarity.z_index = 12
	card_tooltip_sprite.z_index = 4
	card_tooltip_shadow.z_index = 2
	var elements: PackedStringArray = CATALOG.elements_for_texture(texture_path)
	var races: PackedStringArray = CATALOG.races_for_texture(texture_path)
	var rarity_index := CATALOG.rarity_for_texture(texture_path)
	card_tooltip_element_panel.position = Vector2(205, 64)
	card_tooltip_element_panel.size = Vector2(146, 56)
	card_tooltip_race_panel.position = Vector2(205, 129)
	card_tooltip_race_panel.size = Vector2(146, 56)
	card_tooltip_element_panel.visible = true
	card_tooltip_race_panel.visible = true
	card_tooltip_name.text = CATALOG.name_for_texture(texture_path)
	card_tooltip_rarity.text = SHOP_RARITY_NAMES[rarity_index]
	card_tooltip_rarity.position = Vector2(305, 12.5)
	card_tooltip_rarity.size = Vector2(47, 25)
	card_tooltip_rarity.add_theme_font_size_override("font_size", 13)
	card_tooltip_rarity.add_theme_color_override("font_color", Color.WHITE)
	card_tooltip_rarity.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	card_tooltip_rarity.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
	card_tooltip_rarity.add_theme_constant_override("shadow_offset_x", 0)
	card_tooltip_rarity.add_theme_constant_override("shadow_offset_y", 0)
	card_tooltip_rarity.add_theme_constant_override("outline_size", 0)
	card_tooltip_rarity.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card_tooltip_rarity.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	card_tooltip_rarity.z_index = 14
	var rarity_color: Color = SHOP_RARITY_COLORS[rarity_index]
	card_tooltip_name_icon.add_theme_color_override("font_color", rarity_color)
	card_tooltip_rarity_badge.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	RARITY_TAG.apply(card_tooltip_rarity, rarity_index)
	card_tooltip_sprite.texture = load(texture_path) as Texture2D
	card_tooltip_element_icon.reparent(card_tooltip_element_panel)
	card_tooltip_element_icon.position = Vector2(12, 8)
	card_tooltip_element_icon.size = Vector2(40, 40)
	card_tooltip_element_icon.texture = load(TRAIT_ICON_PATHS[elements[0]]) as Texture2D
	_apply_solid_trait_tint(card_tooltip_element_icon, Color.WHITE)
	card_tooltip_element_icon.visible = true
	card_tooltip_element_icon.z_index = 12
	card_tooltip_element.reparent(card_tooltip_element_panel)
	card_tooltip_element.position = Vector2(58, 8)
	card_tooltip_element.size = Vector2(78, 40)
	card_tooltip_element.add_theme_font_size_override("font_size", 17)
	card_tooltip_element.text = "/".join(elements)
	card_tooltip_element.add_theme_color_override("font_color", Color("252b35"))
	card_tooltip_element.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card_tooltip_element.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	card_tooltip_element.visible = true
	card_tooltip_element.z_index = 12
	card_tooltip_race_icon.reparent(card_tooltip_race_panel)
	card_tooltip_race_icon.position = Vector2(12, 8)
	card_tooltip_race_icon.size = Vector2(40, 40)
	card_tooltip_race_icon.texture = load(TRAIT_ICON_PATHS[races[0]]) as Texture2D
	_apply_solid_trait_tint(card_tooltip_race_icon, Color.WHITE)
	card_tooltip_race_icon.visible = true
	card_tooltip_race_icon.z_index = 12
	card_tooltip_race.reparent(card_tooltip_race_panel)
	card_tooltip_race.position = Vector2(58, 8)
	card_tooltip_race.size = Vector2(78, 40)
	card_tooltip_race.add_theme_font_size_override("font_size", 17)
	card_tooltip_race.text = races[0]
	card_tooltip_race.add_theme_color_override("font_color", Color.WHITE)
	card_tooltip_race.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card_tooltip_race.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	card_tooltip_race.visible = true
	card_tooltip_race.z_index = 12
	var rarity_multiplier := CATALOG.RARITY_STAT_MULTIPLIERS[rarity_index]
	var cooldown := CATALOG.cooldown_for_texture(texture_path) / CATALOG.RARITY_CHARGE_MULTIPLIERS[rarity_index]
	var damage_range := CATALOG.damage_range_for_texture(texture_path)
	var damage := roundi(damage_range.y * maxi(level, 1) * rarity_multiplier)
	var role_icon := BATTLE_RANGED_ICON if CATALOG.attack_range_for_texture(texture_path) == "ranged" else BATTLE_MELEE_ICON
	var element_color: Color = TRAIT_COLORS.get(elements[0], Color("f7cc37"))
	var race_color: Color = TRAIT_COLORS.get(races[0], Color("6f5fd6"))
	var element_style := _slot_style(element_color.lightened(0.12), element_color.lightened(0.28), 1)
	element_style.corner_radius_top_left = 7
	element_style.corner_radius_top_right = 7
	element_style.corner_radius_bottom_left = 7
	element_style.corner_radius_bottom_right = 7
	card_tooltip_element_panel.add_theme_stylebox_override("panel", element_style)
	var race_style := _slot_style(race_color.lightened(0.08), race_color.lightened(0.24), 1)
	race_style.corner_radius_top_left = 7
	race_style.corner_radius_top_right = 7
	race_style.corner_radius_bottom_left = 7
	race_style.corner_radius_bottom_right = 7
	card_tooltip_race_panel.add_theme_stylebox_override("panel", race_style)
	card_tooltip_element.add_theme_color_override("font_color", Color.WHITE)
	card_tooltip_race.add_theme_color_override("font_color", Color.WHITE)
	card_tooltip_role_icon.visible = false
	card_tooltip_skill_icon.texture = role_icon
	card_tooltip_role.text = "%.1f 秒" % cooldown
	card_tooltip_skill_name.text = CATALOG.skill_name_for_texture(texture_path)
	# Reserve the complete cooldown group before sizing the adaptive title row.
	# This preserves the requested fixed gap without allowing long names to run
	# underneath the clock icon or attack interval text.
	var skill_name_width := minf(100.0, ceilf(source_han_font.get_string_size(card_tooltip_skill_name.text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x))
	card_tooltip_skill_name.size.x = skill_name_width
	card_tooltip_skill_damage.position.x = card_tooltip_skill_name.position.x + skill_name_width + CHARACTER_INFO_DAMAGE_GAP
	card_tooltip_skill_damage.size.x = minf(82.0, 280.0 - card_tooltip_skill_damage.position.x)
	card_tooltip_skill_damage.text = "最高 %d 点伤害" % damage
	card_tooltip_skill_damage.add_theme_stylebox_override("normal", _slot_style(Color("ffe1e6"), Color.TRANSPARENT, 0))
	card_tooltip_skill_text.text = "[color=#303642]%s[/color]" % _blue_item_values(CATALOG.skill_text_for_texture(texture_path))
	card_tooltip_price.visible = false
	card_tooltip_star.visible = false
	card_tooltip_star_label.visible = false
	card_tooltip_gradient.texture = _make_creature_detail_background(rarity_index, elements[0])
	card_tooltip_cooldown.visible = false
	card_tooltip_damage.visible = false
	card_tooltip_extra.visible = false
	_position_card_tooltip()


func _apply_solid_trait_tint(icon: TextureRect, tint_color: Color) -> void:
	var material := ShaderMaterial.new()
	material.shader = SOLID_ICON_TINT_SHADER
	material.set_shader_parameter("tint_color", tint_color)
	icon.material = material


func _make_creature_detail_background(rarity_index: int, primary_trait: String) -> GradientTexture2D:
	var rarity_color := SHOP_RARITY_COLORS[clampi(rarity_index, 0, SHOP_RARITY_COLORS.size() - 1)]
	var trait_color: Color = TRAIT_COLORS.get(primary_trait, rarity_color)
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.38, 0.72, 1.0])
	gradient.colors = PackedColorArray([
		Color("fbfcff"),
		rarity_color.lightened(0.82),
		trait_color.lightened(0.76),
		Color("f7f8fb"),
	])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = 64
	texture.height = 64
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.62, 0.28)
	texture.fill_to = Vector2(1.0, 0.86)
	return texture


func _show_item_card_tooltip(entry: Dictionary) -> void:
	card_tooltip.size = Vector2(292, 206)
	card_tooltip.add_theme_stylebox_override("panel", _slot_style(Color(0.97, 0.97, 0.98, 0.99), Color(0.18, 0.2, 0.24, 1.0), 4))
	_set_creature_tooltip_visible(false)
	_set_item_tooltip_visible(true)
	card_tooltip_rarity.visible = true
	card_tooltip_name.text = _shop_entry_name(entry)
	card_tooltip_name.position = Vector2(18, 12)
	card_tooltip_name.size = Vector2(196, 32)
	card_tooltip_name.add_theme_font_size_override("font_size", 19)
	card_tooltip_name.add_theme_color_override("font_color", Color.WHITE)
	card_tooltip_name.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	card_tooltip_name.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
	card_tooltip_name.add_theme_constant_override("shadow_offset_x", 0)
	card_tooltip_name.add_theme_constant_override("shadow_offset_y", 0)
	card_tooltip_name.add_theme_constant_override("outline_size", 0)
	card_tooltip_name.z_index = 12
	var item_rarity_index := clampi(int(entry["rarity"]), 0, ITEM_CATALOG.RARITY_NAMES.size() - 1)
	var display_rarity_index := _item_display_rarity_index(item_rarity_index)
	var rarity_color := SHOP_RARITY_COLORS[display_rarity_index]
	_apply_item_tooltip_rarity(rarity_color)
	RARITY_TAG.apply(card_tooltip_rarity, display_rarity_index)
	# Aseprite badge bounds: x=929..1100, y=65..150 on the 1170x825 canvas.
	# At 292x206 this is a 43x21 box; use its full measured area and equal padding.
	card_tooltip_rarity.position = Vector2(232, 16)
	card_tooltip_rarity.size = Vector2(43, 22)
	card_tooltip_rarity.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card_tooltip_rarity.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	card_tooltip_rarity.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	card_tooltip_rarity.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
	card_tooltip_rarity.add_theme_constant_override("shadow_offset_x", 0)
	card_tooltip_rarity.add_theme_constant_override("shadow_offset_y", 0)
	card_tooltip_rarity.add_theme_constant_override("outline_size", 0)
	card_tooltip_rarity.z_index = 12
	card_tooltip_sprite.texture = load(entry["path"]) as Texture2D
	card_tooltip_portrait_panel.position = Vector2(16, 58)
	card_tooltip_portrait_panel.size = Vector2(128, 128)
	card_tooltip_portrait_panel.visible = true
	card_tooltip_sprite.position = Vector2(1, 4)
	card_tooltip_sprite.size = Vector2(120, 120)
	card_tooltip_sprite.z_index = 12
	item_tooltip_type.text = "◆ %s" % ("饰品" if entry["kind"] == "accessory" else ("道具" if entry["kind"] == "item" else "装备"))
	var rule_text := "每名角色最多装备两件" if entry["kind"] == "equipment" else ("唯一饰品" if not String(entry.get("exclusive_group", "")).is_empty() else "叠加上限 %d" % int(entry.get("stack_limit", 1)))
	item_tooltip_effect.text = _blue_item_values(String(entry["effect"]))
	item_tooltip_rule.text = _blue_item_values(rule_text)
	_position_card_tooltip()


func _rarity_text_color(rarity_index: int) -> Color:
	return Color.WHITE if rarity_index <= 0 else SHOP_RARITY_COLORS[clampi(rarity_index, 0, SHOP_RARITY_COLORS.size() - 1)]


func _item_display_rarity_index(item_rarity_index: int) -> int:
	# Items keep their three gameplay tiers while sharing the five-tier card palette.
	return [0, 2, 3][clampi(item_rarity_index, 0, ITEM_CATALOG.RARITY_NAMES.size() - 1)]


func _shop_display_rarity_index(entry: Dictionary) -> int:
	var rarity_index := int(entry.get("rarity", 0))
	if String(entry.get("kind", "creature")) == "creature":
		return clampi(rarity_index, 0, SHOP_RARITY_COLORS.size() - 1)
	return _item_display_rarity_index(rarity_index)


func _position_card_tooltip() -> void:
	var mouse := get_local_mouse_position()
	var desired := Vector2(mouse.x - card_tooltip.size.x * 0.5, mouse.y + 18.0)
	if desired.y + card_tooltip.size.y > DESIGN_SIZE.y - 8:
		desired.y = mouse.y - card_tooltip.size.y - 18
	card_tooltip.position = Vector2(clampf(desired.x, 8.0, DESIGN_SIZE.x - card_tooltip.size.x - 8.0), clampf(desired.y, 8.0, DESIGN_SIZE.y - card_tooltip.size.y - 8.0))
	card_tooltip.visible = true
	card_tooltip.move_to_front()


func _creature_extra_text(texture_path: String, rarity_index: int) -> String:
	var releases := 1 + rarity_index
	var races: PackedStringArray = CATALOG.races_for_texture(texture_path)
	var race := races[0] if not races.is_empty() else ""
	match race:
		"植物": return "多重释放：%d\n战斗中持续成长" % releases
		"机械": return "多重释放：%d\n获得额外护甲" % releases
		"虫群": return "多重释放：%d\n为同族加速充能" % releases
		"龙族": return "多重释放：%d\n技能伤害与溅射强化" % releases
		"亡灵": return "多重释放：%d\n吸血并具有复生能力" % releases
		_: return "多重释放：%d\n羁绊能力强化" % releases


func _hide_card_tooltip() -> void:
	CursorManager.set_inspecting(false)
	if card_tooltip:
		card_tooltip.visible = false


func _shake_shop_card(card: Button) -> void:
	var key := card.get_instance_id()
	if shop_hover_tweens.has(key):
		var previous: Tween = shop_hover_tweens[key]
		if previous and previous.is_valid():
			previous.kill()
	card.pivot_offset = card.size * 0.5
	card.rotation = 0.0
	var shake := create_tween()
	shop_hover_tweens[key] = shake
	shake.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	shake.tween_property(card, "rotation", deg_to_rad(-1.8), 0.045)
	shake.tween_property(card, "rotation", deg_to_rad(1.8), 0.07)
	shake.tween_property(card, "rotation", deg_to_rad(-1.0), 0.055)
	shake.tween_property(card, "rotation", 0.0, 0.05)


func _on_creature_slot_pressed(index: int) -> void:
	if selected_slot < 0:
		selected_slot = index
		_update_selection()
		_set_notice("已选择角色，再点击另一个位置进行交换")
		return
	if selected_slot == index:
		selected_slot = -1
		_update_selection()
		_set_notice("已取消选择")
		return
	_swap_creature_slots(selected_slot, index)
	selected_slot = -1
	_update_selection()
	_set_notice("角色位置已交换")


func equip_selected_creature(entry: Dictionary) -> bool:
	if selected_slot < 0 or selected_slot >= creature_data.size() or creature_data[selected_slot].is_empty():
		_set_notice("请先选择一个角色")
		return false
	var equipment := EQUIPMENT_CATALOG.normalize(entry)
	if equipment.is_empty():
		return false
	var equipment_id := String(equipment["id"])
	if equipment_id in creature_equipment[selected_slot]:
		_set_notice("同一角色不能装备两件同名装备")
		return false
	if creature_equipment[selected_slot].size() >= 2:
		_set_notice("该角色的两个装备栏都已占用")
		return false
	var inventory_index := -1
	for index in GameState.equipment_inventory.size():
		if String(GameState.equipment_inventory[index].get("id", "")) == equipment_id:
			inventory_index = index
			break
	if inventory_index < 0:
		return false
	GameState.equipment_inventory.remove_at(inventory_index)
	creature_equipment[selected_slot].append(equipment_id)
	GameState.save_run()
	_render_creature_slot(selected_slot)
	_refresh_inventory_count()
	_set_notice("%s已装备%s" % [CATALOG.name_for_texture(creature_data[selected_slot]), String(equipment["name"])])
	return true


func _on_equipment_icon_input(event: InputEvent, creature_index: int, equipment_index: int) -> void:
	if not event is InputEventMouseButton:
		return
	var mouse_event := event as InputEventMouseButton
	if not mouse_event.pressed or mouse_event.button_index not in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT]:
		return
	if creature_index >= creature_equipment.size() or equipment_index >= creature_equipment[creature_index].size():
		return
	var equipment_id := String(creature_equipment[creature_index][equipment_index])
	var equipment := EQUIPMENT_CATALOG.data(equipment_id)
	if mouse_event.button_index == MOUSE_BUTTON_RIGHT:
		_open_inventory()
		if is_instance_valid(inventory_popup) and inventory_popup.has_method("show_entry_info"):
			inventory_popup.call("show_entry_info", equipment, "已装备 · 每名角色最多装备两件")
		get_viewport().set_input_as_handled()
		return
	creature_equipment[creature_index].remove_at(equipment_index)
	GameState.add_equipment(equipment_id)
	_render_creature_slot(creature_index)
	_refresh_inventory_count()
	_set_notice("已卸下%s" % String(equipment.get("name", "装备")))
	get_viewport().set_input_as_handled()


func _get_creature_drag_data(_at_position: Vector2, slot_index: int) -> Variant:
	if slot_index < 0 or slot_index >= creature_data.size() or creature_data[slot_index].is_empty():
		return null
	_hide_card_tooltip()
	drag_source_slot = slot_index
	CursorManager.set_dragging(true)
	_show_drag_exchange_targets(slot_index)
	_show_shop_sell_target(slot_index)
	var preview := Panel.new()
	preview.size = Vector2(92, 92)
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	preview.add_theme_stylebox_override("panel", _slot_style(Color(0.05, 0.08, 0.12, 0.94), Color("ffd45f"), 3))
	var portrait := _add_texture(preview, creature_data[slot_index], Rect2(10, 10, 72, 64))
	portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var preview_stars := _create_star_row(preview, Rect2(8, 68, 76, 18))
	_set_star_level(preview_stars, creature_levels[slot_index])
	creature_buttons[slot_index].set_drag_preview(preview)
	return {"kind": "creature_slot", "source_index": slot_index}


func _can_drop_creature_data(_at_position: Vector2, data: Variant, slot_index: int) -> bool:
	if not data is Dictionary or String(data.get("kind", "")) != "creature_slot":
		return false
	var source_index := int(data.get("source_index", -1))
	return source_index >= 0 and source_index < creature_data.size() and source_index != slot_index


func _drop_creature_data(_at_position: Vector2, data: Variant, slot_index: int) -> void:
	if not _can_drop_creature_data(_at_position, data, slot_index):
		return
	var source_index := int(data.get("source_index", -1))
	_swap_creature_slots(source_index, slot_index)
	_clear_drag_exchange_targets()
	var destination := "队伍" if slot_index >= 4 else "备战席"
	_set_notice("角色已拖动到%s" % destination)


func _get_shop_sell_drag_data(_at_position: Vector2) -> Variant:
	return null


func _can_drop_shop_sell_data(_at_position: Vector2, data: Variant) -> bool:
	if not data is Dictionary or String(data.get("kind", "")) != "creature_slot":
		return false
	var source_index := int(data.get("source_index", -1))
	return source_index >= 0 and source_index < creature_data.size() and not creature_data[source_index].is_empty()


func _drop_shop_sell_data(_at_position: Vector2, data: Variant) -> void:
	if not _can_drop_shop_sell_data(_at_position, data):
		return
	var source_index := int(data.get("source_index", -1))
	var sell_value := _creature_sell_value(source_index)
	var sold_path := creature_data[source_index]
	var sold_level := creature_levels[source_index]
	var sold_name := CATALOG.name_for_texture(sold_path)
	_clear_creature_slot(source_index)
	GameState.return_creature_to_pool(sold_path, GameState.CREATURE_STAR_COPIES[clampi(sold_level, 1, 3) - 1])
	GameState.add_coins(sell_value)
	_sync_coins()
	_update_synergies()
	_clear_drag_exchange_targets()
	_set_notice("已售出%s，获得 %dG" % [sold_name, sell_value])


func _creature_sell_value(slot_index: int) -> int:
	if slot_index < 0 or slot_index >= creature_data.size() or creature_data[slot_index].is_empty():
		return 0
	var rarity := CATALOG.rarity_for_texture(creature_data[slot_index])
	return GameState.creature_sell_value(rarity, creature_levels[slot_index])


func _show_shop_sell_target(slot_index: int) -> void:
	if not shop_sell_overlay or not shop_sell_label:
		return
	var sell_value := _creature_sell_value(slot_index)
	shop_sell_label.text = "售出  +%dG" % sell_value
	shop_sell_overlay.visible = sell_value > 0
	shop_sell_overlay.move_to_front()


func _show_drag_exchange_targets(source_index: int) -> void:
	for index in creature_masks.size():
		creature_masks[index].visible = index != source_index and not creature_data[index].is_empty()
		creature_selection_frames[index].visible = false


func _clear_drag_exchange_targets() -> void:
	drag_source_slot = -1
	CursorManager.set_dragging(false)
	if shop_sell_overlay:
		shop_sell_overlay.visible = false
	for mask in creature_masks:
		mask.visible = false


func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END and drag_source_slot >= 0:
		_clear_drag_exchange_targets()


func _swap_creature_slots(first_index: int, second_index: int) -> void:
	if first_index == second_index:
		return
	var held_path := creature_data[first_index]
	var held_level := creature_levels[first_index]
	var held_equipment: Array = creature_equipment[first_index]
	creature_data[first_index] = creature_data[second_index]
	creature_levels[first_index] = creature_levels[second_index]
	creature_equipment[first_index] = creature_equipment[second_index]
	creature_data[second_index] = held_path
	creature_levels[second_index] = held_level
	creature_equipment[second_index] = held_equipment
	_render_creature_slot(first_index)
	_render_creature_slot(second_index)
	_update_synergies()


func _on_shop_card_pressed(index: int) -> void:
	if shop_data[index].is_empty():
		_set_notice("该商品已售出")
		return
	var entry: Dictionary = shop_data[index]
	var price := int(entry["price"])
	if GameState.coins < price:
		_set_notice("金币不足")
		return
	if entry["kind"] in ["item", "accessory", "equipment"]:
		if entry["kind"] == "equipment":
			if not _spend_shop_coins(price):
				_set_notice("金币不足")
				return
			GameState.add_equipment(entry)
			_refresh_inventory_count()
			shop_data[index] = {}
			_render_shop_card(index)
			_hide_card_tooltip()
			_set_notice("获得装备%s：%s" % [_shop_entry_name(entry), String(entry["effect"])])
			return
		var can_accept := GameState.can_add_accessory(entry) if entry["kind"] == "accessory" else GameState.can_add_item(entry)
		if not can_accept:
			_set_notice("该物品已达到叠加上限或与现有饰品冲突")
			return
		if not _spend_shop_coins(price):
			_set_notice("金币不足")
			return
		if entry["kind"] == "accessory":
			GameState.add_accessory(entry)
		else:
			GameState.add_item(entry)
		_refresh_inventory_count()
		shop_data[index] = {}
		_render_shop_card(index)
		_hide_card_tooltip()
		_set_notice("%s：%s" % [_shop_entry_name(entry), String(entry["effect"])])
		return
	var texture_path := String(entry["path"])
	if not _can_accept_creature_purchase(texture_path):
		_set_notice("备战席已满，请先拖动角色到队伍")
		return
	if not GameState.take_creature_from_pool(texture_path):
		_set_notice("该角色已从共享卡池中售罄")
		return
	var merge_level := _add_purchased_creature(texture_path)
	shop_data[index] = {}
	if not _spend_shop_coins(price):
		_set_notice("金币不足")
		return
	_render_shop_card(index)
	GameState.mark_creature_seen(texture_path)
	var trainer_reward := GameState.record_trainer_creature_purchase(texture_path)
	GameState.unlock_creature_achievement(texture_path, GameState.ACHIEVEMENT_TROPHY)
	if merge_level >= 3:
		GameState.unlock_creature_achievement(texture_path, GameState.ACHIEVEMENT_STAR)
	_update_synergies()
	selected_slot = -1
	_update_selection()
	_hide_card_tooltip()
	var purchase_notice := "已自动合成为 %d 星角色" % merge_level if merge_level > 1 else "角色已加入备战席"
	if trainer_reward > 0:
		purchase_notice += "，生态研究 +%dG" % trainer_reward
	_refresh_trainer_skill_control()
	_set_notice(purchase_notice)


func _can_accept_creature_purchase(texture_path: String) -> bool:
	for slot_index in range(0, mini(4, creature_data.size())):
		if creature_data[slot_index].is_empty():
			return true
	return _matching_creature_slots(texture_path, 1).size() >= 2


func _add_purchased_creature(texture_path: String) -> int:
	var target_slot := -1
	for slot_index in range(0, mini(4, creature_data.size())):
		if creature_data[slot_index].is_empty():
			target_slot = slot_index
			break
	if target_slot >= 0:
		creature_data[target_slot] = texture_path
		creature_levels[target_slot] = 1
		creature_equipment[target_slot] = []
		_render_creature_slot(target_slot)
	else:
		# Two owned 1-star copies plus the purchased copy form the triple.
		var matches := _matching_creature_slots(texture_path, 1)
		var keep_slot := _preferred_merge_slot(matches)
		matches.erase(keep_slot)
		creature_levels[keep_slot] = 2
		_clear_creature_slot(matches[0])
		_render_creature_slot(keep_slot)
	return _resolve_creature_merges(texture_path)


func _resolve_all_creature_merges() -> void:
	var unique_paths: Dictionary = {}
	for texture_path in creature_data:
		if not texture_path.is_empty():
			unique_paths[texture_path] = true
	for texture_path in unique_paths:
		_resolve_creature_merges(String(texture_path))


func _resolve_creature_merges(texture_path: String) -> int:
	var highest_level := 1
	for level in range(1, 3):
		var required_copies := 3 if level == 1 else 2
		while true:
			var matches := _matching_creature_slots(texture_path, level)
			if matches.size() < required_copies:
				break
			var keep_slot := _preferred_merge_slot(matches)
			matches.erase(keep_slot)
			creature_levels[keep_slot] = level + 1
			GameState.mark_creature_owned(texture_path, level + 1)
			for consumed_index in range(required_copies - 1):
				_clear_creature_slot(matches[consumed_index])
			_render_creature_slot(keep_slot)
			highest_level = level + 1
	for index in creature_data.size():
		if creature_data[index] == texture_path:
			highest_level = maxi(highest_level, creature_levels[index])
	return highest_level


func _matching_creature_slots(texture_path: String, level: int) -> Array[int]:
	var result: Array[int] = []
	for index in creature_data.size():
		if creature_data[index] == texture_path and creature_levels[index] == level:
			result.append(index)
	return result


func _preferred_merge_slot(matches: Array[int]) -> int:
	for index in matches:
		if index >= 4:
			return index
	return matches[0]


func _clear_creature_slot(index: int) -> void:
	for equipment_id in creature_equipment[index]:
		GameState.add_equipment(String(equipment_id))
	creature_equipment[index] = []
	creature_data[index] = ""
	creature_levels[index] = 0
	if selected_slot == index:
		selected_slot = -1
	_render_creature_slot(index)


func _on_reroll_pressed() -> void:
	if shop_locked:
		_set_notice("商店已锁定，无法刷新")
		return
	var free_refresh := GameState.consume_scout_free_refresh()
	if not free_refresh:
		if GameState.coins < 1:
			_set_notice("金币不足")
			return
		if not _spend_shop_coins(1):
			_set_notice("金币不足")
			return
	shop_data = _roll_shop_entries(true, free_refresh)
	for entry in shop_data:
		_mark_shop_creature_seen(entry)
	for index in shop_sprites.size():
		_render_shop_card(index)
	_refresh_trainer_skill_control()
	_set_notice("商店已刷新（免费）" if free_refresh else "商店已刷新")


func _roll_shop_rarity() -> int:
	var roll := rng.randf()
	var chances := _shop_rarity_chances()
	var cumulative := 0.0
	for rarity_index in chances.size():
		cumulative += chances[rarity_index]
		if roll < cumulative:
			return rarity_index
	return chances.size() - 1


func _shop_rarity_chances() -> PackedFloat32Array:
	# Floor 1 = 50/30/15/5/0; floor 9 = 25/28/25/15/7.
	var progress := float(clampi(GameState.floor - 1, 0, GameState.MAX_FLOORS - 1)) / float(GameState.MAX_FLOORS - 1)
	return PackedFloat32Array([
		lerpf(0.50, 0.25, progress),
		lerpf(0.30, 0.28, progress),
		lerpf(0.15, 0.25, progress),
		lerpf(0.05, 0.15, progress),
		lerpf(0.00, 0.07, progress),
	])


func _draw_creature_shop_entry(local_draw_counts: Dictionary = {}) -> Dictionary:
	var rarity_index := _roll_shop_rarity()
	var pool: Array[String] = []
	for rarity_distance in SHOP_RARITY_NAMES.size():
		var candidate_rarities := [rarity_index] if rarity_distance == 0 else [rarity_index - rarity_distance, rarity_index + rarity_distance]
		for candidate_rarity in candidate_rarities:
			if candidate_rarity < 0 or candidate_rarity >= SHOP_RARITY_NAMES.size():
				continue
			for texture_path in GameState.available_creatures_for_rarity(candidate_rarity):
				if int(local_draw_counts.get(texture_path, 0)) < int(GameState.creature_shop_pool.get(texture_path, 0)):
					pool.append(texture_path)
			if not pool.is_empty():
				rarity_index = candidate_rarity
				break
		if not pool.is_empty():
			break
	if pool.is_empty():
		return {}
	var texture_path := pool[rng.randi_range(0, pool.size() - 1)]
	local_draw_counts[texture_path] = int(local_draw_counts.get(texture_path, 0)) + 1
	return {
		"kind": "creature",
		"path": texture_path,
		"rarity": rarity_index,
		"price": GameState.shop_price(GameState.CREATURE_BUY_PRICES[rarity_index]),
	}


func _roll_shop_entries(include_non_creature := true, force_non_creature := false) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	var local_draw_counts: Dictionary = {}
	for index in SHOP_CARD_COUNT:
		entries.append(_draw_creature_shop_entry(local_draw_counts))
	if not include_non_creature:
		return entries
	# A refresh may contain at most one non-creature card. Roll both configured
	# chances, then resolve a simultaneous success into either an item or an
	# accessory so both can never occupy the same shop row.
	var roll_item := force_non_creature or rng.randf() < SHOP_ITEM_CHANCE
	var roll_accessory := rng.randf() < SHOP_ACCESSORY_CHANCE
	var roll_equipment := rng.randf() < SHOP_EQUIPMENT_CHANCE
	if roll_item or roll_accessory or roll_equipment:
		var kind := "item"
		var options: Array[String] = []
		if roll_item: options.append("item")
		if roll_accessory: options.append("accessory")
		if roll_equipment: options.append("equipment")
		kind = options[rng.randi_range(0, options.size() - 1)]
		var non_creature_slot := rng.randi_range(0, SHOP_CARD_COUNT - 1)
		var rarity := mini(_roll_shop_rarity(), 2)
		var entry := EQUIPMENT_CATALOG.random_entry(rng, rarity, "shop") if kind == "equipment" else ITEM_CATALOG.random_entry(kind, rng, rarity, "shop")
		entries[non_creature_slot] = _discount_shop_entry(entry)
	return entries


func _discount_shop_entry(entry: Dictionary) -> Dictionary:
	var discounted := entry.duplicate(true)
	discounted["price"] = GameState.shop_price(int(entry.get("price", 1)))
	return discounted


func _mark_shop_creature_seen(entry: Dictionary) -> void:
	if not entry.is_empty() and entry["kind"] == "creature":
		GameState.mark_creature_seen(entry["path"])


func _shop_entry_name(entry: Dictionary) -> String:
	if entry["kind"] == "creature":
		return CATALOG.name_for_texture(String(entry["path"]))
	return String(entry.get("name", "未知物品"))


func _on_lock_pressed() -> void:
	shop_locked = not shop_locked
	lock_label.text = "已锁" if shop_locked else "锁定"
	lock_label.add_theme_color_override("font_color", Color.WHITE)
	_set_lock_button_pressed(false)
	for index in shop_lock_overlays.size():
		var overlay := shop_lock_overlays[index]
		if shop_locked:
			overlay.texture = load(LOCK_ICON) as Texture2D
			overlay.scale = Vector2.ONE
			overlay.visible = true
			overlay.modulate.a = 1.0
		else:
			_animate_shop_unlock(index)
	_set_notice("商店已锁定" if shop_locked else "商店已解锁")


func _animate_shop_unlock(index: int) -> void:
	if index < 0 or index >= shop_lock_overlays.size():
		return
	var overlay := shop_lock_overlays[index]
	overlay.texture = load(LOCK_ICON_PRESSED) as Texture2D
	overlay.visible = true
	overlay.modulate.a = 1.0
	overlay.scale = Vector2.ONE
	var unlock_tween := create_tween().set_parallel(true)
	unlock_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	unlock_tween.tween_property(overlay, "scale", Vector2(1.28, 1.28), 0.16)
	unlock_tween.tween_property(overlay, "modulate:a", 0.0, 0.32)
	unlock_tween.chain().tween_callback(func() -> void:
		overlay.visible = false
		overlay.modulate.a = 1.0
		overlay.scale = Vector2.ONE
		if not shop_locked and index < shop_data.size() and not shop_data[index].is_empty():
			shop_star_rows[index].visible = false
	)


func _set_lock_button_pressed(pressed: bool) -> void:
	if lock_button_texture:
		lock_button_texture.texture = load(LOCK_ICON_PRESSED if pressed or shop_locked else LOCK_ICON) as Texture2D


func _on_settings_pressed() -> void:
	if not is_instance_valid(settings_overlay):
		settings_overlay = SETTINGS_OVERLAY_SCENE.instantiate() as Control
		settings_overlay.set("exit_scene_path", "res://main.tscn")
		add_child(settings_overlay)
	else:
		settings_overlay.move_to_front()


func _open_dex() -> void:
	if not is_instance_valid(dex_overlay):
		dex_overlay = DEX_OVERLAY_SCENE.instantiate() as Control
		add_child(dex_overlay)
	else:
		dex_overlay.visible = true
		dex_overlay.move_to_front()
	if dex_overlay.has_method("refresh_data"):
		dex_overlay.call("refresh_data")


func _open_inventory() -> void:
	_refresh_inventory_count()
	if not is_instance_valid(inventory_popup):
		inventory_popup = INVENTORY_POPUP_SCENE.instantiate() as Control
		add_child(inventory_popup)
	else:
		inventory_popup.move_to_front()
		if inventory_popup.has_method("refresh_items"):
			inventory_popup.call("refresh_items")


func _refresh_inventory_count() -> void:
	if not inventory_count_label:
		return
	var item_count := GameState.item_inventory.size() + GameState.accessory_inventory.size() + GameState.equipment_inventory.size()
	inventory_count_label.text = str(item_count)
	inventory_count_label.visible = item_count > 0


func _play_transition_in() -> void:
	var transition := ColorRect.new()
	transition.z_index = 200
	transition.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	transition.color = Color.BLACK
	transition.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(transition)
	var reveal := create_tween()
	reveal.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	reveal.tween_interval(0.12)
	reveal.tween_property(transition, "color:a", 0.0, 0.65)
	reveal.tween_callback(transition.queue_free)


func _on_battle_pressed() -> void:
	var battle_team: Array[String] = []
	for index in range(4, 10):
		if not creature_data[index].is_empty():
			battle_team.append(creature_data[index])
	if battle_team.is_empty():
		_set_notice("队伍为空，请先购买并放置至少一个角色")
		return
	_save_current_team()
	_set_notice("队伍已准备完毕 · 正在进入战斗")
	await SceneManager.change_scene("res://battle_intro.tscn")


func _leave_shop() -> void:
	_save_current_team()
	GameState.complete_current_map_node()
	SceneManager.change_scene("res://map.tscn")


func _leave_start() -> void:
	var has_team_member := false
	for index in range(4, 10):
		if not creature_data[index].is_empty():
			has_team_member = true
			break
	if not has_team_member:
		_set_notice("请先购买并放置至少一个角色")
		return
	_save_current_team()
	GameState.complete_current_map_node()
	SceneManager.change_scene("res://map.tscn")


func _on_back_pressed() -> void:
	if GameState.map_initialized:
		_save_current_team()
		if GameState.current_map_node_type() == "shop":
			GameState.complete_current_map_node()
		SceneManager.change_scene("res://map.tscn")
	else:
		SceneManager.change_scene("res://main.tscn")


func _save_current_team() -> void:
	var saved_bench: Array[String] = []
	var saved_bench_levels: Array[int] = []
	var saved_bench_equipment: Array = []
	for index in range(0, mini(creature_data.size(), 4)):
		if not creature_data[index].is_empty():
			saved_bench.append(creature_data[index])
			saved_bench_levels.append(creature_levels[index])
			saved_bench_equipment.append(Array(creature_equipment[index]).duplicate())
	var saved_team: Array[String] = []
	var saved_team_levels: Array[int] = []
	var saved_team_equipment: Array = []
	for index in range(4, mini(creature_data.size(), 10)):
		saved_team.append(creature_data[index])
		saved_team_levels.append(creature_levels[index])
		saved_team_equipment.append(Array(creature_equipment[index]).duplicate())
	GameState.set_player_bench(saved_bench, saved_bench_levels, saved_bench_equipment)
	GameState.set_player_team(saved_team, saved_team_levels, saved_team_equipment)


func _sync_coins() -> void:
	coins = GameState.coins
	if coin_label:
		coin_label.text = "%dG" % coins


func _spend_shop_coins(amount: int) -> bool:
	if not GameState.try_spend_coins(amount):
		return false
	_sync_coins()
	return true


func _create_star_row(parent: Control, rect: Rect2) -> Control:
	var row := Control.new()
	row.position = rect.position
	row.size = rect.size
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.set_meta("star_size", minf(15.0, rect.size.y))
	parent.add_child(row)
	for _index in 3:
		var star := TextureRect.new()
		star.texture = STAR_ICON
		star.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		star.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		star.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		star.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(star)
	_set_star_level(row, 1)
	return row


func _set_star_level(row: Control, level: int) -> void:
	level = clampi(level, 1, 3)
	var star_size := float(row.get_meta("star_size", 15.0))
	var gap := 1.0
	var start_x := 0.0
	for index in row.get_child_count():
		var star := row.get_child(index) as TextureRect
		star.visible = level >= 2 and index < level
		star.position = Vector2(start_x + index * (star_size + gap), floorf((row.size.y - star_size) * 0.5))
		star.size = Vector2(star_size, star_size)


func _render_creature_slot(index: int) -> void:
	if index < creature_equipment_icons.size():
		for equipment_index in 2:
			var icon := creature_equipment_icons[index][equipment_index] as TextureRect
			if index < creature_equipment.size() and equipment_index < creature_equipment[index].size():
				var entry := EQUIPMENT_CATALOG.data(String(creature_equipment[index][equipment_index]))
				icon.texture = load(String(entry.get("path", ""))) as Texture2D
				icon.visible = not entry.is_empty()
			else:
				icon.texture = null
				icon.visible = false
	if creature_data[index].is_empty():
		creature_sprites[index].texture = null
		creature_hp_badges[index].visible = false
		creature_special_badges[index].visible = false
		creature_level_labels[index].text = ""
		creature_star_rows[index].visible = false
		creature_hp_labels[index].text = ""
		creature_special_labels[index].text = ""
		creature_element_icons[index].visible = false
		creature_extra_trait_icons[index].visible = false
		creature_race_icons[index].visible = false
		creature_trait_backgrounds[index].visible = false
		creature_element_icon_backgrounds[index].visible = false
		creature_extra_icon_backgrounds[index].visible = false
		creature_race_icon_backgrounds[index].visible = false
		creature_rarity_frames[index].visible = false
		return
	creature_hp_badges[index].visible = false
	creature_special_badges[index].visible = false
	creature_hp_labels[index].visible = false
	creature_special_labels[index].visible = false
	creature_sprites[index].texture = load(creature_data[index]) as Texture2D
	var level := clampi(creature_levels[index], 1, 3)
	creature_star_rows[index].visible = true
	_set_star_level(creature_star_rows[index], level)
	if bool(creature_buttons[index].get_meta("formation_slot", false)):
		creature_rarity_frames[index].visible = false
		creature_trait_backgrounds[index].visible = false
		creature_element_icons[index].visible = false
		creature_extra_trait_icons[index].visible = false
		creature_race_icons[index].visible = false
		creature_element_icon_backgrounds[index].visible = false
		creature_extra_icon_backgrounds[index].visible = false
		creature_race_icon_backgrounds[index].visible = false
		return
	var rarity_multiplier := CATALOG.rarity_stat_multiplier(creature_data[index])
	var hp_value := roundi(CATALOG.base_hp_for_texture(creature_data[index]) * rarity_multiplier) * level
	var special_value := roundi(CATALOG.damage_range_for_texture(creature_data[index]).y * rarity_multiplier) * level
	creature_hp_labels[index].text = "%d" % hp_value
	creature_special_labels[index].text = "%d" % special_value
	var elements: PackedStringArray = CATALOG.elements_for_texture(creature_data[index])
	var races: PackedStringArray = CATALOG.races_for_texture(creature_data[index])
	var rarity_index := CATALOG.rarity_for_texture(creature_data[index])
	creature_rarity_frames[index].add_theme_stylebox_override("panel", _shop_card_outline_style(SHOP_RARITY_COLORS[clampi(rarity_index, 0, SHOP_RARITY_COLORS.size() - 1)]))
	creature_rarity_frames[index].visible = true
	creature_element_icons[index].texture = load(TRAIT_ICON_PATHS[elements[0]]) as Texture2D
	creature_race_icons[index].texture = load(TRAIT_ICON_PATHS[races[0]]) as Texture2D
	creature_element_icon_backgrounds[index].modulate = TRAIT_COLORS.get(elements[0], Color("737983"))
	creature_element_icon_backgrounds[index].visible = true
	creature_race_icon_backgrounds[index].visible = false
	var secondary_trait := elements[1] if elements.size() > 1 else races[0]
	creature_extra_trait_icons[index].texture = load(TRAIT_ICON_PATHS[secondary_trait]) as Texture2D
	creature_extra_trait_icons[index].visible = true
	creature_extra_icon_backgrounds[index].modulate = TRAIT_COLORS.get(secondary_trait, Color("737983"))
	creature_extra_icon_backgrounds[index].visible = true
	creature_element_icons[index].visible = true
	creature_race_icons[index].visible = false
	creature_trait_backgrounds[index].texture = _make_rarity_background(rarity_index)
	creature_trait_backgrounds[index].visible = true


func _render_shop_card(index: int) -> void:
	if shop_data[index].is_empty():
		shop_sprites[index].texture = null
		shop_sprites[index].visible = false
		shop_hp_badges[index].visible = false
		shop_special_badges[index].visible = false
		shop_level_labels[index].visible = false
		shop_star_rows[index].visible = false
		shop_sold_out_overlays[index].visible = true
		shop_sold_out_shades[index].visible = true
		shop_lock_overlays[index].visible = shop_locked
		shop_attribute_layers[index].texture = load(SHOP_CARD_ASSETS[0]) as Texture2D
		shop_attribute_layers[index].visible = true
		shop_creature_overlays[index].visible = false
		shop_outer_layers[index].visible = false
		shop_card_outlines[index].visible = false
		shop_element_icons[index].visible = false
		shop_extra_trait_icons[index].visible = false
		shop_race_icons[index].visible = false
		shop_trait_backgrounds[index].visible = false
		shop_element_icon_backgrounds[index].visible = false
		shop_extra_icon_backgrounds[index].visible = false
		shop_race_icon_backgrounds[index].visible = false
		shop_hp_labels[index].text = ""
		shop_special_labels[index].text = ""
		shop_name_labels[index].text = ""
		shop_price_labels[index].text = ""
		shop_element_labels[index].text = ""
		shop_secondary_trait_labels[index].text = ""
		shop_coin_icons[index].visible = false
		return
	var entry: Dictionary = shop_data[index]
	shop_sold_out_overlays[index].visible = false
	shop_sold_out_shades[index].visible = false
	shop_lock_overlays[index].visible = shop_locked
	var is_creature: bool = String(entry["kind"]) == "creature"
	var texture_path: String = entry["path"]
	var rarity_index := int(entry.get("rarity", CATALOG.rarity_for_texture(texture_path)))
	var display_rarity_index := _shop_display_rarity_index(entry)
	shop_card_outlines[index].visible = false
	shop_trait_backgrounds[index].texture = _make_rarity_background(display_rarity_index)
	shop_trait_backgrounds[index].visible = true
	shop_sprites[index].texture = load(texture_path) as Texture2D
	shop_sprites[index].position = Vector2(24.4, -14.85) if is_creature else Vector2(9, 2)
	shop_sprites[index].size = Vector2(121.2, 108.7) if is_creature else Vector2(115, 76)
	shop_sprites[index].visible = true
	shop_name_labels[index].text = _shop_entry_name(entry)
	shop_price_labels[index].text = "%d" % int(entry["price"])
	shop_coin_icons[index].visible = true
	shop_creature_overlays[index].visible = is_creature
	shop_attribute_layers[index].visible = true
	shop_attribute_layers[index].texture = load(SHOP_CARD_ASSETS[clampi(display_rarity_index, 0, SHOP_CARD_ASSETS.size() - 1)]) as Texture2D
	shop_attribute_layers[index].modulate = Color.WHITE
	shop_outer_layers[index].visible = false
	shop_hp_badges[index].visible = false
	shop_special_badges[index].visible = false
	shop_level_labels[index].visible = false
	shop_star_rows[index].visible = false
	shop_hp_labels[index].visible = false
	shop_special_labels[index].visible = false
	shop_element_icons[index].visible = false
	shop_extra_trait_icons[index].visible = false
	shop_race_icons[index].visible = false
	shop_element_labels[index].visible = is_creature
	shop_secondary_trait_labels[index].visible = is_creature
	if not is_creature:
		shop_attribute_layers[index].modulate = Color.WHITE
		shop_element_icon_backgrounds[index].visible = false
		shop_extra_icon_backgrounds[index].visible = false
		shop_race_icon_backgrounds[index].visible = false
		shop_hp_labels[index].text = ""
		shop_special_labels[index].text = ""
		shop_element_labels[index].text = ""
		shop_secondary_trait_labels[index].text = ""
		return
	var rarity_multiplier := CATALOG.RARITY_STAT_MULTIPLIERS[clampi(rarity_index, 0, CATALOG.RARITY_STAT_MULTIPLIERS.size() - 1)]
	shop_attribute_layers[index].modulate = Color.WHITE
	var hp_value := roundi(CATALOG.base_hp_for_texture(texture_path) * rarity_multiplier)
	var special_value := roundi(CATALOG.damage_range_for_texture(texture_path).y * rarity_multiplier)
	shop_hp_labels[index].text = "%d" % hp_value
	shop_special_labels[index].text = "%d" % special_value
	_set_stat_badge_value(shop_hp_badges[index], hp_value, true)
	_set_stat_badge_value(shop_special_badges[index], special_value, false)
	var elements: PackedStringArray = CATALOG.elements_for_texture(texture_path)
	var races: PackedStringArray = CATALOG.races_for_texture(texture_path)
	shop_element_icons[index].texture = load(TRAIT_ICON_PATHS[elements[0]]) as Texture2D
	shop_race_icons[index].texture = load(TRAIT_ICON_PATHS[races[0]]) as Texture2D
	var secondary_trait := elements[1] if elements.size() > 1 else races[0]
	shop_element_labels[index].text = elements[0]
	shop_secondary_trait_labels[index].text = secondary_trait
	shop_extra_trait_icons[index].visible = true
	shop_extra_trait_icons[index].texture = load(TRAIT_ICON_PATHS[secondary_trait]) as Texture2D
	shop_element_icons[index].visible = true
	shop_race_icons[index].visible = false
	shop_element_icon_backgrounds[index].modulate = TRAIT_COLORS.get(elements[0], Color("737983"))
	shop_element_icon_backgrounds[index].visible = true
	shop_race_icon_backgrounds[index].modulate = TRAIT_COLORS.get(races[0], Color("737983"))
	shop_race_icon_backgrounds[index].visible = false
	shop_extra_icon_backgrounds[index].visible = true
	shop_extra_icon_backgrounds[index].modulate = TRAIT_COLORS.get(secondary_trait, Color("737983"))


func _update_selection() -> void:
	if selection_pulse_tween and selection_pulse_tween.is_valid():
		selection_pulse_tween.kill()
	for index in creature_buttons.size():
		creature_buttons[index].add_theme_stylebox_override("normal", _slot_style(Color(0, 0, 0, 0), Color(0, 0, 0, 0)))
		creature_masks[index].visible = false
		creature_selection_frames[index].visible = false
		creature_selection_frames[index].scale = Vector2.ONE
	if selected_slot >= 0 and selected_slot < creature_selection_frames.size():
		_show_creature_selection_frame(selected_slot)


func _show_creature_selection_frame(index: int) -> void:
	if index < 0 or index >= creature_selection_frames.size():
		return
	if index >= creature_data.size() or creature_data[index].is_empty():
		return
	if selection_pulse_tween and selection_pulse_tween.is_valid():
		selection_pulse_tween.kill()
	for frame in creature_selection_frames:
		frame.visible = false
		frame.scale = Vector2.ONE
	var frame := creature_selection_frames[index]
	frame.visible = true
	frame.scale = Vector2(0.94, 0.94)
	selection_pulse_tween = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	selection_pulse_tween.tween_property(frame, "scale", Vector2(1.035, 1.035), 0.48)
	selection_pulse_tween.tween_property(frame, "scale", Vector2(0.94, 0.94), 0.48)


func _hide_creature_selection_frame(index: int) -> void:
	if index < 0 or index >= creature_selection_frames.size():
		return
	if selected_slot == index:
		return
	if selection_pulse_tween and selection_pulse_tween.is_valid():
		selection_pulse_tween.kill()
	creature_selection_frames[index].visible = false
	creature_selection_frames[index].scale = Vector2.ONE


func _set_notice(_message: String) -> void:
	pass


func _add_texture(parent: Control, path: String, rect: Rect2, stretch := TextureRect.STRETCH_KEEP_ASPECT_CENTERED) -> TextureRect:
	var node := TextureRect.new()
	node.position = rect.position
	node.size = rect.size
	node.texture = load(path) as Texture2D
	node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	node.stretch_mode = stretch
	node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(node)
	return node


func _make_trait_background(traits: PackedStringArray) -> GradientTexture2D:
	var colors := PackedColorArray()
	var offsets := PackedFloat32Array()
	var valid_traits: Array[String] = []
	for trait_name in traits:
		if TRAIT_COLORS.has(trait_name):
			valid_traits.append(trait_name)
	if valid_traits.is_empty():
		valid_traits.append("自然")
	for index in valid_traits.size():
		var color: Color = TRAIT_COLORS[valid_traits[index]]
		var section_start := float(index) / float(valid_traits.size())
		var section_end := float(index + 1) / float(valid_traits.size())
		if index > 0:
			section_start += 0.002
		if index < valid_traits.size() - 1:
			section_end -= 0.002
		offsets.append(section_start)
		colors.append(color)
		offsets.append(section_end)
		colors.append(color)
	var gradient := Gradient.new()
	gradient.offsets = offsets
	gradient.colors = colors
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = 16
	texture.height = 16
	texture.fill = GradientTexture2D.FILL_LINEAR
	texture.fill_from = Vector2(0.0, 0.0)
	texture.fill_to = Vector2(1.0, 1.0)
	return texture


func _make_rarity_background(rarity_index: int) -> GradientTexture2D:
	var base_color := SHOP_RARITY_COLORS[clampi(rarity_index, 0, SHOP_RARITY_COLORS.size() - 1)]
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 1.0])
	gradient.colors = PackedColorArray([
		base_color.darkened(0.28),
		base_color.lightened(0.38),
	])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = 256
	texture.height = 256
	texture.fill = GradientTexture2D.FILL_LINEAR
	texture.fill_from = Vector2(0.0, 0.0)
	texture.fill_to = Vector2(1.0, 1.0)
	return texture


func _add_texture_button(path: String, rect: Rect2, _tooltip: String) -> TextureButton:
	var button := TextureButton.new()
	button.position = rect.position
	button.size = rect.size
	button.texture_normal = load(path) as Texture2D
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_SCALE
	button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(button)
	return button


func _add_icon_button(path: String, rect: Rect2, callback: Callable, tooltip: String) -> TextureButton:
	var button := _add_texture_button(path, rect, tooltip)
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	button.pressed.connect(callback)
	return button


func _add_static_icon_button(path: String, rect: Rect2, callback: Callable, _tooltip: String) -> Button:
	_add_texture(self, path, rect)
	var button := Button.new()
	button.position = rect.position
	button.size = rect.size
	button.flat = true
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(callback)
	add_child(button)
	return button


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
	var is_dark_text := color.get_luminance() < 0.62
	label.add_theme_color_override("font_shadow_color", Color.TRANSPARENT if is_dark_text else Color(0.08, 0.10, 0.14, 0.62))
	label.add_theme_constant_override("outline_size", 0)
	label.add_theme_constant_override("shadow_offset_x", 0 if is_dark_text else 1)
	label.add_theme_constant_override("shadow_offset_y", 0 if is_dark_text else 1)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label


func _slot_style(fill: Color, border: Color, width := 0) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(width)
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_left = 3
	style.corner_radius_bottom_right = 3
	return style


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


func _shop_card_outline_style(border: Color) -> StyleBoxFlat:
	var style := _slot_style(Color.TRANSPARENT, border, 4)
	style.corner_radius_top_left = 0
	style.corner_radius_top_right = 0
	style.corner_radius_bottom_left = 0
	style.corner_radius_bottom_right = 0
	style.anti_aliasing = false
	return style


func _add_stat_badge(parent: Control, rect: Rect2, fill: Color) -> TextureRect:
	var badge := TextureRect.new()
	badge.position = rect.position
	badge.size = rect.size
	badge.texture = load("res://素材/图鉴/image-1785682708652-8ni6x6cdnyo.png") as Texture2D
	badge.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	badge.stretch_mode = TextureRect.STRETCH_SCALE
	badge.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var material := ShaderMaterial.new()
	material.shader = STAT_BADGE_SHADER
	material.set_shader_parameter("badge_color", fill)
	badge.material = material
	parent.add_child(badge)
	return badge


func _set_stat_badge_value(badge: TextureRect, value: int, is_health: bool) -> void:
	if badge == null or not badge.material is ShaderMaterial:
		return
	var base := Color("ef3f67") if is_health else Color("3184a4")
	var intensity := clampf(0.78 + float(value) / (90.0 if is_health else 50.0) * 0.28, 0.78, 1.08)
	var adjusted := Color(base.r * intensity, base.g * intensity, base.b * intensity, 1.0)
	(badge.material as ShaderMaterial).set_shader_parameter("badge_color", adjusted)


func _apply_stat_pixel_font(label: Label) -> void:
	label.add_theme_font_override("font", stat_pixel_font)
	label.add_theme_constant_override("outline_size", 1)
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
