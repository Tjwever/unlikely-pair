extends Node2D

@onready var fight_prompt_ui = $Player/Camera2D/FightPromptUI
@onready var player = $Player

func _on_yes_pressed():
	get_tree().change_scene_to_file("res://Scenes/MainScene.tscn")


func _on_no_pressed():
	fight_prompt_ui.visible = false
	player.can_move = true
	
