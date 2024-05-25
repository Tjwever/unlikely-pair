extends CharacterBody2D

class_name Fighter

signal update_fighter_health

@onready var healthbar = $"../CanvasLayer/PlayerSideUI/GridContainer/MarginContainer/VBoxContainer/HBoxContainer/Healthbar"
@onready var enemy = $"../Enemy"
@onready var timer = $Timer

const BASE_WAIT_TIME = 1.0

var max_health := 400
var current_health := 400
var defense := 3
var attack_damge := 50
var speed := 10.0

func _ready():
	healthbar.init_health(current_health)
	set_attack_timer()
	timer.start()

func set_attack_timer():
	timer.wait_time = BASE_WAIT_TIME / (speed / 10.0)
	#print("Fighter attack wait time set to: ", timer.wait_time)

func calculate_damage(atk_damage, enemy_defense):
	return max(0, atk_damage - enemy_defense)

func attack():
	if enemy:
		var damage_dealt = calculate_damage(attack_damge, enemy.defense)
		#print('Fighter deals ', damage_dealt)
		enemy.take_damage(damage_dealt)

func take_damage(damage):
	current_health -= damage
	emit_signal("update_fighter_health", current_health)
	
	if current_health < 0:
		current_health = 0

	if current_health == 0:
		print('death')
		timer.stop()

# Example function to heal
func heal(amount):
	current_health += amount
	emit_signal("update_fighter_health", current_health)
	
	if current_health > max_health:
		current_health = max_health

# Function to check if enemy is alive
func is_alive():
	return current_health > 0

func _on_timer_timeout():
	attack()
