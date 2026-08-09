extends Node

const BATTLE_SCENE: PackedScene = preload("res://battle.tscn")
const PROJECTILE_CHARACTER := "1 (7).png"
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

	var attacker = null
	var target = null
	for fighter in battle.fighters:
		if fighter.player_side and fighter.texture_path.get_file() == PROJECTILE_CHARACTER:
			attacker = fighter
		elif not fighter.player_side and target == null:
			target = fighter
	if attacker == null or target == null:
		push_error("Projectile visual test could not find its attacker or target.")
		get_tree().quit(1)
		return

	await get_tree().create_timer(1.0).timeout
	battle._play_p7_projectile(attacker, target)
	await _capture_after(0.08, OUTPUT_NAMES[0])
	await _capture_after(0.62, OUTPUT_NAMES[1])
	await _capture_after(0.72, OUTPUT_NAMES[2])
	get_tree().quit()


func _capture_after(delay: float, output_name: String) -> void:
	await get_tree().create_timer(delay).timeout
	await RenderingServer.frame_post_draw
	var output_path := ProjectSettings.globalize_path("res://") + output_name
	var error := get_viewport().get_texture().get_image().save_png(output_path)
	if error != OK:
		push_error("Could not save projectile visual test frame: %s" % output_path)
