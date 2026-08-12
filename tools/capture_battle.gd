extends SceneTree


func _initialize() -> void:
	var output_args := OS.get_cmdline_user_args()
	var output_path := output_args[0] if not output_args.is_empty() else "res://tools/battle-runtime-preview.png"
	var biome := output_args[1] if output_args.size() > 1 else "grass"
	if biome in ["snow", "cave", "boss"]:
		await process_frame
		var game_state := root.get_node("/root/GameState")
		game_state.map_initialized = true
		game_state.region = 2 if biome == "snow" else 3
		game_state.floor = 6 if biome == "snow" else 9
		game_state.map_nodes = [{"id": 0, "column": 6, "type": "boss" if biome == "boss" else "battle"}]
		game_state.current_map_node = 0
		game_state.battle_victories = 2
	change_scene_to_file("res://battle.tscn")
	await process_frame
	await create_timer(1.2).timeout
	var image := root.get_texture().get_image()
	var error := image.save_png(output_path)
	if error != OK:
		push_error("Unable to save battle preview: %s" % error_string(error))
		quit(1)
		return
	quit()
