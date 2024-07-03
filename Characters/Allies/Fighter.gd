extends CharacterBody2D

class_name Fighter

signal update_fighter_health
signal fighter_defeated

@onready
var healthbar = $"../GameUI/PlayerSideUI/GridContainer/MarginContainer/VBoxContainer/HBoxContainer/Healthbar"
@onready var special_move_notifier_ui = $"./SpecialMoveNotifierUI"
@onready
var special_move_notifier_label = $"./SpecialMoveNotifierUI/VBoxContainer/PanelContainer/SpecialMoveNotifierLabel"
@onready var panel_container = $"./SpecialMoveNotifierUI/VBoxContainer/PanelContainer"

@onready var enemy = $"../Enemy"
@onready var timer = $Timer
@onready var notification_timer = $NotificationTimer
@onready var animation_player = $AnimationPlayer
@onready var display_numbers_origin = $DisplayNumbersOrigin

const BASE_WAIT_TIME = 1

var max_health
var current_health
var defense
var attack_damage
var speed
var critical_hit_rate
var double_attack_rate
var level
var is_critical_hit: bool = false
var is_double_attack: bool = false
var isDead: bool = false


func _ready():
	var fighter_data = CharacterState.load_character_data("fighter")

	if fighter_data:
		max_health = fighter_data["max_health"]
		current_health = fighter_data["current_health"]
		defense = fighter_data["defense"]
		attack_damage = fighter_data["attack_damage"]
		speed = fighter_data["speed"]
		critical_hit_rate = fighter_data["critical_hit_rate"]
		double_attack_rate = fighter_data["double_attack_rate"]
		level = fighter_data["level"]

	healthbar.init_health(current_health)

	await get_tree().create_timer(0.5).timeout
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(1227, 351), 0.3)
	await get_tree().create_timer(1).timeout
	tween.kill()

	set_attack_timer()
	timer.start()


func set_attack_timer():
	var speed_calculation: float = float(BASE_WAIT_TIME / float(speed / 10.0))

	timer.wait_time = speed_calculation


func calculate_damage(atk_damage, enemy_defense):
	is_critical_hit = (randi() % 100) < critical_hit_rate
	var final_damage = atk_damage
	if is_critical_hit:
		final_damage *= 2

	return max(0, final_damage - enemy_defense)


func attack():
	if enemy.current_health != 0:
		var damage_dealt = calculate_damage(attack_damage, enemy.defense)
		var double_attack_damage = randi_range(0, damage_dealt / 2)

		is_double_attack = (randi() % 100) < double_attack_rate

		animation_player.play("quick_attack")
		await get_tree().create_timer(0.32).timeout

		if is_double_attack:
			panel_container.theme_type_variation = "FighterTheme"
			special_move_notifier_ui.visible = true
			special_move_notifier_label.text = "Double Strike!"
			notification_timer.start()

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
	DisplayNumbers.display_number(damage, display_numbers_origin.global_position, false, false)
	emit_signal("update_fighter_health", current_health)

	if current_health < 0:
		current_health = 0

	if current_health == 0:
		timer.stop()
		animation_player.queue("death")
		await get_tree().create_timer(0.32).timeout
		isDead = true
		emit_signal("fighter_defeated")


func heal(amount):
	if isDead:
		current_health = 0
	else:
		current_health += amount
		DisplayNumbers.display_number(amount, self.global_position, false, true)
		emit_signal("update_fighter_health", current_health)

	if current_health > max_health:
		current_health = max_health


func _on_timer_timeout():
	attack()


func _on_notification_timer_timeout():
	special_move_notifier_ui.visible = false
