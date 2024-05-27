extends CharacterBody2D

class_name Skelly

signal update_enemy_health
signal enemy_defeated

@onready var healthbar = $"../GameUI/EnemySideUI/GridContainer/MarginContainer/VBoxContainer/HBoxContainer/Healthbar"
@onready var fighter = $"../Fighter"
@onready var healer = $"../Healer"
@onready var timer = $Timer
@onready var animation_player = $AnimationPlayer
@onready var damage_numbers_origin = $DamageNumbersOrigin

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

func choose_target():
	print('is fighter alive: ', fighter.isDead)
	print('is healer alive: ', healer.isDead)
	var rand = randi() % 100
	if rand < 70:
		if fighter.isDead:
			print('fighter is dead, picking healer')
			return healer
		return fighter
	else:
		if healer.isDead:
			print('healer is dead, picking fighter')
			return fighter
		return healer

func attack():
	var target = choose_target()
	
	if fighter.isDead and healer.isDead:
		timer.stop()

	if target:
		animation_player.play("quick_attack")
		await get_tree().create_timer(0.1).timeout
		var damage_dealt = calculate_damage(attack_damge, target.defense)
		#print('Enemy deals ', damage_dealt)
		target.take_damage(damage_dealt)

func take_damage(damage, is_critical_hit):
	current_health -= damage
	#maybe add if it's critical in here somewhere, replace 'false' if is_critical value
	DamageNumbers.display_number(damage, damage_numbers_origin.global_position, is_critical_hit)
	emit_signal("update_enemy_health", current_health)
	
	if current_health < 0:
		current_health = 0

	if current_health == 0:
		animation_player.play("death")
		print('**gasp**')
		await get_tree().create_timer(1).timeout
		timer.stop()
		print('Im dead....')
		queue_free()
		emit_signal("enemy_defeated")
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
