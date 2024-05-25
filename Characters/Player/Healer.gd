extends CharacterBody2D

class_name Healer

signal update_healer_health

@onready var healthbar = $"../CanvasLayer/PlayerSideUI/GridContainer/MarginContainer/VBoxContainer/HBoxContainer2/Healthbar"

var max_health := 200
var current_health := 200
var defense := 3

func _ready():
	healthbar.init_health(current_health)

func take_damage(damage):
	current_health -= damage
	emit_signal("update_healer_health", current_health)
	
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
