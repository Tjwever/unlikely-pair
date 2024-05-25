extends CharacterBody2D

class_name Skelly

signal update_enemy_health

@onready var healthbar = $"../CanvasLayer/EnemySideUI/GridContainer/MarginContainer/VBoxContainer/HBoxContainer/Healthbar"

var max_health := 10000
var current_health := 10000
var defense := 3

func _ready():
	healthbar.init_health(current_health)

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		take_damage(50)

func take_damage(damage):
	current_health -= damage
	emit_signal("update_enemy_health", current_health)
	
	if current_health < 0:
		current_health = 0

	if current_health == 0:
		print('death')

# Example function to heal
func heal(amount):
	current_health += amount
	if current_health > max_health:
		current_health = max_health

# Function to check if enemy is alive
func is_alive():
	return current_health > 0
