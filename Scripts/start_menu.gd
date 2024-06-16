extends Control

@onready var check_box = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/CheckBox
@onready var music = $AudioStreamPlayer2D


func _on_play_pressed():
	if check_box.button_pressed:
		get_tree().change_scene_to_file("res://Scenes/Tutorial.tscn")
		music.finished
	else:
		get_tree().change_scene_to_file("res://Scenes/MainScene.tscn")
		music.finished


func _on_quit_pressed():
	get_tree().quit()
