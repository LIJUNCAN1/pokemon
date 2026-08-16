extends Node

const PROBE_SCRIPT: Script = preload("res://tools/scene_transition_test.gd")


func _ready() -> void:
	var probe := Node.new()
	probe.name = "PersistentTransitionProbe"
	probe.set_script(PROBE_SCRIPT)
	get_tree().root.add_child.call_deferred(probe)
