extends CharacterBody2D

class_name Fighter

signal update_fighter_health
signal fighter_defeated

@onready var healthbar = $"../GameUI/PlayerSideUI/GridContainer/MarginContainer/VBoxContainer/HBoxContainer/Healthbar"
@onready var enemy = $"../Enemy"
@onready var timer = $Timer
@onready var animation_player = $AnimationPlayer
@onready var damage_numbers_origin = $DamageNumbersOrigin

const BASE_WAIT_TIME = 1

var max_health := 400
var current_health := 400
var defense := 3
var attack_damge := 1550
var speed := 9.0
var isDead: bool = false

var speed_calculation: float = float(BASE_WAIT_TIME / float(speed / 10.0))

func _ready():
	healthbar.init_health(current_health)
	set_attack_timer()
	timer.start()

func set_attack_timer():
	timer.wait_time = speed_calculation
	print('timer wait time: ', float(speed_calculation))
	#print("Fighter attack wait time set to: ", timer.wait_time)

func calculate_damage(atk_damage, enemy_defense):
	return max(0, atk_damage - enemy_defense)

func attack():
	if enemy.current_health != 0:
		animation_player.play("quick_attack")
		await get_tree().create_timer(0.32).timeout
		var damage_dealt = calculate_damage(attack_damge, enemy.defense)
		print('Fighter deals ', damage_dealt)
		enemy.take_damage(damage_dealt)
	else:
		timer.stop()

func take_damage(damage):
	current_health -= damage
	DamageNumbers.display_number(damage, damage_numbers_origin.global_position, false)
	emit_signal("update_fighter_health", current_health)
	
	if current_health < 0:
		current_health = 0

	if current_health == 0:
		timer.stop()
		animation_player.queue("death")
		await get_tree().create_timer(0.32).timeout
		isDead = true
		emit_signal("fighter_defeated")
		print('death')

# Example function to heal
func heal(amount):
	current_health += amount
	emit_signal("update_fighter_health", current_health)
	
	if current_health > max_health:
		current_health = max_health

func is_alive():
	return current_health <= 0

func _on_timer_timeout():
	attack()
