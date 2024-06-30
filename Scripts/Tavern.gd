extends Node2D

@onready var fight_prompt_ui = $Player/Camera2D/FightPromptUI
@onready var player = $Player
@onready var pause_canvas = $PauseCanvas


func _input(event):
	if event.is_action_pressed("pause"):
		print("pressed")
		toggle_pause_menu()


func toggle_pause_menu():
	if pause_canvas.visible:
		pause_canvas.visible = false
		get_tree().paused = false
	else:
		pause_canvas.visible = true
		get_tree().paused = true


func _on_yes_pressed():
	get_tree().change_scene_to_file("res://Scenes/MainScene.tscn")


func _on_no_pressed():
	fight_prompt_ui.visible = false
	player.can_move = true
