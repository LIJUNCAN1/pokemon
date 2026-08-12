@tool
extends EditorPlugin

var _registered_autoload := false

func _enter_tree():
	if not ProjectSettings.has_setting("autoload/SceneManager"):
		add_autoload_singleton("SceneManager", "res://addons/scene_manager/SceneManager.tscn")
		_registered_autoload = true


func _exit_tree():
	if _registered_autoload and ProjectSettings.has_setting("autoload/SceneManager"):
		remove_autoload_singleton("SceneManager")
