extends Node2D

@onready var end_game_canvas = $EndGameCanvas
@onready var you_won = $"EndGameCanvas/EndGameContainer/YouWon"
@onready var game_over = $EndGameCanvas/EndGameContainer/GameOver

var is_healer_dead: bool = false
var is_fighter_dead: bool = false

func _ready():
	end_game_canvas.visible = false
	you_won.visible = false
	game_over.visible = false
	
func _process(delta):
	if is_fighter_dead and is_healer_dead:
		get_tree().paused = true
		end_game_canvas.visible = true
		game_over.visible = true

func _on_enemy_enemy_defeated():
	get_tree().paused = true
	end_game_canvas.visible = true
	you_won.visible = true
	#game_over.visible = true
