extends CharacterBody2D

class_name Skelly

signal update_enemy_health

@onready var healthbar = $"../CanvasLayer/EnemySideUI/GridContainer/MarginContainer/VBoxContainer/HBoxContainer/Healthbar"
@onready var fighter = $"../Fighter"
@onready var healer = $"../Healer"
@onready var timer = $Timer

const BASE_WAIT_TIME = 2.0

var allies := [fighter, healer]
var max_health := 10000
var current_health := 10000
var defense := 3
var attack_damge := 45
var speed := 8.0

func _ready():
	healthbar.init_health(current_health)
	set_attack_timer()
	timer.start()

func set_attack_timer():
	timer.wait_time = BASE_WAIT_TIME / (speed / 10.0)
	#print("Enemy attack wait time set to: ", timer.wait_time)

func calculate_damage(atk_damage, fighter_defense):
	return max(0, atk_damage - fighter_defense)

func attack():
	if fighter:
		var damage_dealt = calculate_damage(attack_damge, fighter.defense)
		#print('Enemy deals ', damage_dealt)
		fighter.take_damage(damage_dealt)

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

func _on_timer_timeout():
	attack()
