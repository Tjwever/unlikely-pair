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
var attack_damge := 250
var speed := 9.0
var critical_hit_rate: int = 3
var double_attack_rate: int = 60
var is_critical_hit: bool = false
var is_double_attack: bool = false
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
	is_critical_hit = (randi() % 100) < critical_hit_rate
	var final_damage = atk_damage
	if is_critical_hit:
		final_damage *= 2

	return max(0, final_damage - enemy_defense)

func attack():
	if enemy.current_health != 0:
		var damage_dealt = calculate_damage(attack_damge, enemy.defense)
		var double_attack_damage = randi_range(0, damage_dealt / 2)
		
		is_double_attack = (randi() % 100) < double_attack_rate
		
		animation_player.play("quick_attack")
		await get_tree().create_timer(0.32).timeout
		#print('Fighter deals ', damage_dealt)
		if is_double_attack:
			animation_player.play("double_attack")
			await get_tree().create_timer(0.1).timeout
			enemy.take_damage(damage_dealt - double_attack_damage, is_critical_hit)
			enemy.take_damage(damage_dealt - double_attack_damage, is_critical_hit)
			is_double_attack = false
		else:
			enemy.take_damage(damage_dealt, is_critical_hit)
		is_critical_hit = false
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
