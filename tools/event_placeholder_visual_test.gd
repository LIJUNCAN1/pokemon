extends Node

const MAP_SCENE: PackedScene = preload("res://map.tscn")


func _ready() -> void:
	GameState.reset_run()
	var map := MAP_SCENE.instantiate()
	add_child(map)
	await get_tree().process_frame
	await get_tree().process_frame
	map.chest_event = false
	map._prepare_event_rewards()
	map.event_story_id = 1
	map._show_event_popup()
	await get_tree().process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(ProjectSettings.globalize_path("res://event_placeholder_preview.png"))
	print("EVENT_PLACEHOLDER_VISUAL_TEST: PASS")
	get_tree().quit()
