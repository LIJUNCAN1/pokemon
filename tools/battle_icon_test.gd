extends Node

const BATTLE_SCENE: PackedScene = preload("res://battle.tscn")
const RARITY_TAG = preload("res://scripts/rarity_tag_style.gd")
const TEST_CREATURE := "res://素材/图鉴/角色/1 (3).png"


func _ready() -> void:
	GameState.has_started_new_game = true
	GameState.reset_run()
	GameState.set_player_team([TEST_CREATURE], [1])
	var battle = BATTLE_SCENE.instantiate()
	add_child(battle)
	await get_tree().process_frame
	battle.set_process(false)
	var fighter = battle.fighters[0]
	battle.call("_show_fighter_info", fighter)
	_assert(battle.fighter_info_role_icon.texture != null, "角色详情缺少近战/远程图标")
	var rarity: int = battle.CATALOG.rarity_for_texture(fighter.texture_path)
	_assert(battle.fighter_info_rarity.visible and battle.fighter_info_rarity.text == RARITY_TAG.display_name(rarity), "战斗角色详情必须使用共用品质标签")
	_assert((battle.fighter_info_rarity.get_theme_stylebox("normal") as StyleBoxTexture).texture == RARITY_TAG.texture(rarity), "战斗角色详情品质标签纹理不一致")
	if DisplayServer.get_name() != "headless":
		await get_tree().process_frame
		await get_tree().process_frame
		var capture_error := get_viewport().get_texture().get_image().save_png(ProjectSettings.globalize_path("res://battle_character_detail.png"))
		_assert(capture_error == OK, "战斗角色详情截图失败")
	_assert(battle.fighter_info_role_icon.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "角色类型图标必须使用最近邻过滤")
	fighter.shield = 12
	battle.call("_update_status_icons", fighter)
	_assert(fighter.status_row is VBoxContainer and fighter.status_row.position.x > fighter.sprite.position.x + fighter.sprite.size.x, "buff icons must stack vertically to the right of the portrait")
	var shield_root: Control = fighter.status_row.get_child(0)
	var shield_icon: TextureRect = shield_root.get_child(0)
	_assert(shield_icon.texture == battle.BATTLE_SHIELD_ICON, "护盾状态没有使用新图标")
	battle.call("_show_status_info", "护盾 12")
	var status_style := battle.status_info_panel.get_theme_stylebox("panel") as StyleBoxTexture
	_assert(status_style != null and status_style.texture == battle.PRESET_INFO_FRAME, "status details must use the supplied preset information frame")
	if DisplayServer.get_name() != "headless":
		await get_tree().process_frame
		var status_capture := get_viewport().get_texture().get_image().save_png(ProjectSettings.globalize_path("res://battle_status_info.png"))
		_assert(status_capture == OK, "战斗状态信息框截图失败")
	battle.call("_hide_status_info")
	var children_before := battle.get_child_count()
	battle.call("_play_critical_icon", fighter)
	_assert(battle.get_child_count() == children_before + 1, "暴击命中没有创建暴击图标动画")
	print("BATTLE_ICON_TEST: PASS")
	get_tree().quit()


func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	push_error("BATTLE_ICON_TEST: %s" % message)
	get_tree().quit(1)
