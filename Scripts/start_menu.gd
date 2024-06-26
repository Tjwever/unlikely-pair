extends Control

@onready var check_box = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/CheckBox
@onready var music = $AudioStreamPlayer2D


func _process(_delta):
	if Input.is_action_just_pressed("action"):
		get_tree().change_scene_to_file("res://Scenes/Tavern.tscn")


func _on_play_pressed():
	if check_box.button_pressed:
		get_tree().change_scene_to_file("res://Scenes/Tutorial.tscn")
	else:
		get_tree().change_scene_to_file("res://Scenes/Tavern.tscn")


func _on_quit_pressed():
	get_tree().quit()
