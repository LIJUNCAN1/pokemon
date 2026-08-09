extends Node

const MAP_SCENE: PackedScene = preload("res://map.tscn")


func _ready() -> void:
	GameState.reset_run()
	var map_scene := MAP_SCENE.instantiate()
	add_child(map_scene)
	await get_tree().create_timer(3.0).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(ProjectSettings.globalize_path("res://map_drag_before.png"))
	var before_x: float = map_scene.map_content.position.x
	map_scene._pan_map(-600.0)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(ProjectSettings.globalize_path("res://map_drag_after.png"))
	if not map_scene.map_content.position.x < before_x:
		push_error("MAP_DRAG_TEST: horizontal pan did not move map content")
		get_tree().quit(1)
		return
	if map_scene.map_content.position.x < map_scene._map_content_min_x() or map_scene.map_content.position.x > map_scene._map_content_max_x():
		push_error("MAP_DRAG_TEST: horizontal pan exceeded its bounds")
		get_tree().quit(1)
		return
	print("MAP_DRAG_TEST: PASS")
	get_tree().quit()
