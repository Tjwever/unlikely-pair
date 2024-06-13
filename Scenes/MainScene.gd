extends Node2D

@onready var end_game_canvas = $EndGameCanvas
@onready var you_won = $EndGameCanvas/EndGameContainer/VBoxContainer/YouWon
@onready var game_over = $EndGameCanvas/EndGameContainer/VBoxContainer/GameOver

var is_healer_dead: bool = false
var is_fighter_dead: bool = false

func _ready():
	end_game_canvas.visible = false
	you_won.visible = false
	game_over.visible = false

func _process(_delta):
	if is_fighter_dead and is_healer_dead:
		await get_tree().create_timer(1.3).timeout
		end_game_canvas.visible = true
		game_over.visible = true
		#get_tree().paused = true

func _on_enemy_enemy_defeated():
	#get_tree().paused = true
	end_game_canvas.visible = true
	you_won.visible = true

func _on_healer_healer_defeated():
	is_healer_dead = true

func _on_fighter_fighter_defeated():
	is_fighter_dead = true


func _on_return_pressed():
	#get_tree().paused = false
	print('pressed')
	get_tree().change_scene_to_file("res://Scenes/start_menu.tscn")
