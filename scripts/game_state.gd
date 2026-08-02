extends Node

var day := 1
var progress := 1
var player_team: Array[String] = []


func reset_run() -> void:
	day = 1
	progress = 1
	player_team.clear()


func set_player_team(team: Array[String]) -> void:
	player_team = team.duplicate()
