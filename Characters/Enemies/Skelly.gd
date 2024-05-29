extends CharacterBody2D

class_name Skelly

signal update_enemy_health
signal enemy_defeated

@onready var healthbar = $"../GameUI/EnemySideUI/GridContainer/MarginContainer/VBoxContainer/HBoxContainer/Healthbar"
@onready var fighter = $"../Fighter"
@onready var healer = $"../Healer"
@onready var regular_attack_timer = $RegularAttackTimer
@onready var big_attack_timer = $BigAttackTimer
@onready var animation_player = $AnimationPlayer
@onready var damage_numbers_origin = $DamageNumbersOrigin

const BASE_WAIT_TIME = 2.0

var allies := [fighter, healer]
var max_health := 10000
var current_health := 10000
var defense := 3
var attack_damge := 45
var speed := 8.0
var big_attack_cooldown : int = 10
var is_big_attack : bool = false

func _ready():
	healthbar.init_health(current_health)
	set_attack_timer()
	regular_attack_timer.start()
	big_attack_timer.wait_time = big_attack_cooldown
	big_attack_timer.start()

func set_attack_timer():
	regular_attack_timer.wait_time = BASE_WAIT_TIME / (speed / 10.0)

func calculate_damage(atk_damage, fighter_defense):
	return max(0, atk_damage - fighter_defense)

func choose_target():
	var rand = randi() % 100
	if rand < 70:
		if fighter.isDead:
			return healer
		return fighter
	else:
		if healer.isDead:
			return fighter
		return healer

func attack():
	var target = choose_target()
	if fighter.isDead and healer.isDead:
		regular_attack_timer.stop()

	if target:
		var damage_dealt = calculate_damage(attack_damge, target.defense)
		
		if is_big_attack:
			animation_player.play("big_attack")
			await get_tree().create_timer(0.75).timeout
			if fighter.isDead or healer.isDead:
				target.take_damage(damage_dealt)
			else:
				fighter.take_damage(damage_dealt + 25) # 25 is arbitrary number for now
				healer.take_damage(damage_dealt + 25)
			is_big_attack = false
		else:
			animation_player.play("quick_attack")
			await get_tree().create_timer(0.1).timeout
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
		regular_attack_timer.stop()
		animation_player.queue("death")
		await get_tree().create_timer(1).timeout
		emit_signal("enemy_defeated")
		queue_free()

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

func _on_big_attack_timer_timeout():
	is_big_attack = true
	big_attack_timer.start()
