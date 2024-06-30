extends Node2D

@onready var pause_canvas = $PauseCanvas
@onready var end_game_canvas = $EndGameCanvas
@onready var you_won = $EndGameCanvas/EndGameContainer/VBoxContainer/YouWon
@onready var game_over = $EndGameCanvas/EndGameContainer/VBoxContainer/GameOver
@onready var fight_ui = $FightUI

var is_healer_dead: bool = false
var is_fighter_dead: bool = false


func _ready():
	fight_ui.visible = false
	await get_tree().create_timer(0.2).timeout
	var tween = get_tree().create_tween()
	tween.tween_property(fight_ui, "position", Vector2(930, 363), 0.2).set_ease(Tween.EASE_OUT)

	fight_ui.visible = true
	end_game_canvas.visible = false
	you_won.visible = false
	game_over.visible = false

	await get_tree().create_timer(2).timeout

	fight_ui.visible = false


func _process(_delta):
	if is_fighter_dead and is_healer_dead:
		await get_tree().create_timer(1.3).timeout
		end_game_canvas.visible = true
		game_over.visible = true


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


func _on_enemy_enemy_defeated():
	#get_tree().paused = true
	end_game_canvas.visible = true
	you_won.visible = true


func _on_healer_healer_defeated():
	is_healer_dead = true


func _on_fighter_fighter_defeated():
	is_fighter_dead = true


func _on_return_pressed():
	get_tree().paused = false
	print("pressed")
	get_tree().change_scene_to_file("res://Scenes/start_menu.tscn")


func _on_continue_pressed():
	pause_canvas.visible = false
	get_tree().paused = false


func _on_again_pressed():
	get_tree().reload_current_scene()


func _on_to_tavern_pressed():
	get_tree().change_scene_to_file("res://Scenes/Tavern.tscn")
