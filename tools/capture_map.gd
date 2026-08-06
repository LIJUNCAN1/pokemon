extends SceneTree


func _initialize() -> void:
	change_scene_to_file("res://map.tscn")
	await process_frame
	await process_frame
	await process_frame
	var image := root.get_texture().get_image()
	image.save_png("res://tools/map-runtime-preview.png")
	quit()
