extends Node

const BATTLE_SCENE: PackedScene = preload("res://battle.tscn")
const OUTPUT_NAMES := [
	"projectile_launch.png",
	"projectile_flight.png",
	"projectile_impact.png",
]


func _ready() -> void:
	GameState.player_team.clear()
	var battle := BATTLE_SCENE.instantiate()
	add_child(battle)
	await get_tree().process_frame
	await get_tree().process_frame

	var attackers: Array = []
	var target = null
	for fighter in battle.fighters:
		if fighter.player_side and attackers.size() < 3:
			attackers.append(fighter)
		elif not fighter.player_side and target == null:
			target = fighter
	if attackers.size() < 3 or target == null:
		push_error("Projectile visual test could not find enough attackers or a target.")
		get_tree().quit(1)
		return
	_assert(battle._fighter_attack_origin(attackers[0]).x > battle._fighter_visual_center(attackers[0]).x, "Player attack effect must start from the character's right side")
	_assert(battle._fighter_attack_origin(target).x < battle._fighter_visual_center(target).x, "Enemy attack effect must start from its mirrored front side")

	await get_tree().create_timer(1.0).timeout
	for attacker in attackers:
		battle._play_p7_projectile(attacker, target)
	if battle.p7_projectile_frames == null:
		push_error("Every attacker must use the shared attack animation frames")
		get_tree().quit(1)
		return
	await _capture_after(0.08, OUTPUT_NAMES[0])
	await _capture_after(0.62, OUTPUT_NAMES[1])
	await _capture_after(0.72, OUTPUT_NAMES[2])
	var item_count_before := GameState.item_inventory.size()
	var coins_before := GameState.coins
	var reward_text: String = battle._grant_first_battle_chest()
	_assert(GameState.item_inventory.size() == item_count_before + 2, "Starting chest must grant two items")
	_assert(GameState.coins == coins_before + GameState.FIRST_BATTLE_CHEST_GOLD, "Starting chest granted the wrong amount of gold")
	var first_reward: Dictionary = GameState.item_inventory[item_count_before]
	var second_reward: Dictionary = GameState.item_inventory[item_count_before + 1]
	_assert(int(first_reward["id"]) != int(second_reward["id"]), "Starting chest items should be different")
	_assert(not reward_text.is_empty(), "Starting chest result text is empty")
	get_tree().quit()


func _capture_after(delay: float, output_name: String) -> void:
	await get_tree().create_timer(delay).timeout
	await RenderingServer.frame_post_draw
	var output_path := ProjectSettings.globalize_path("res://") + output_name
	var error := get_viewport().get_texture().get_image().save_png(output_path)
	if error != OK:
		push_error("Could not save projectile visual test frame: %s" % output_path)


func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	push_error("PROJECTILE_VISUAL_TEST: %s" % message)
	get_tree().quit(1)
