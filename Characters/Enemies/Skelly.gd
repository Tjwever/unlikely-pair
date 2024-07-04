extends CharacterBody2D

class_name Skelly

signal update_enemy_health
signal enemy_defeated

@onready
var healthbar = $"../GameUI/EnemySideUI/GridContainer/MarginContainer/VBoxContainer/HBoxContainer/Healthbar"
@onready var special_move_notifier_ui = $"../SpecialMoveNotifierUI"
@onready
var special_move_notifier_label = $"../SpecialMoveNotifierUI/VBoxContainer/PanelContainer/SpecialMoveNotifierLabel"
@onready var panel_container = $"../SpecialMoveNotifierUI/VBoxContainer/PanelContainer"

@onready var camera = $"../Camera2D"
@onready var fighter = $"../Fighter"
@onready var healer = $"../Healer"
@onready var regular_attack_timer = $RegularAttackTimer
@onready var big_attack_timer = $BigAttackTimer
@onready var animation_player = $AnimationPlayer
@onready var display_numbers_origin = $DisplayNumbersOrigin
@onready var notification_timer = $NotificationTimer

const BASE_WAIT_TIME = 2.0

var allies := [fighter, healer]
# for testing purposes, health at 1000
#var max_health := 1000
#var current_health := 1000
var max_health := 10000
var current_health := 10000
var defense := 3
var attack_damge := 45
var speed := 8.0
var exp_given := 250
var kill_count
var is_dead := false
var big_attack_cooldown: int = 10
var is_big_attack: bool = false


func _ready():
	kill_count = CharacterState.get_kill_count("skelly")

	healthbar.init_health(current_health)

	await get_tree().create_timer(0.5).timeout
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(500, 248), 0.2)
	await get_tree().create_timer(1).timeout
	tween.kill()

	if fighter.is_dead and healer.is_dead:
		big_attack_timer.stop()
		regular_attack_timer.stop()

	set_attack_timer()

	regular_attack_timer.start()
	big_attack_timer.wait_time = big_attack_cooldown
	big_attack_timer.start()


func _process(_delta):
	if fighter.is_dead and healer.is_dead:
		big_attack_timer.stop()
		regular_attack_timer.stop()


func set_attack_timer():
	regular_attack_timer.wait_time = BASE_WAIT_TIME / (speed / 10.0)


func calculate_damage(atk_damage, fighter_defense):
	return max(0, atk_damage - fighter_defense)


func choose_target():
	var rand = randi() % 100
	if rand < 70:
		if fighter.is_dead:
			return healer
		return fighter
	else:
		if healer.is_dead:
			return fighter
		return healer


func attack():
	var target = choose_target()
	if fighter.is_dead and healer.is_dead:
		regular_attack_timer.stop()

	if target:
		var damage_dealt = calculate_damage(attack_damge, target.defense)

		if is_big_attack:
			panel_container.theme_type_variation = "EnemyTheme"
			special_move_notifier_ui.visible = true
			special_move_notifier_label.text = "Big Daddy Damage"
			notification_timer.start()
			animation_player.play("big_attack")
			await get_tree().create_timer(0.75).timeout
			if fighter.is_dead or healer.is_dead:
				target.take_damage(damage_dealt)
			else:
				fighter.take_damage(damage_dealt + 25)  # 25 is arbitrary number for now
				healer.take_damage(damage_dealt + 25)
				camera.shake(15, 0.5)
			is_big_attack = false
		else:
			animation_player.play("quick_attack")
			await get_tree().create_timer(0.1).timeout
			camera.shake(8, 0.3)
			
			target.take_damage(damage_dealt)


func take_damage(damage, is_critical_hit):
	current_health -= damage

	DisplayNumbers.display_number(
		damage, display_numbers_origin.global_position, is_critical_hit, false
	)
	emit_signal("update_enemy_health", current_health)

	if current_health < 0:
		current_health = 0

	if current_health == 0:
		is_dead = true
		CharacterState.set_kill_count("skelly")
		CharacterState.gain_experience("healer", exp_given)
		CharacterState.gain_experience("fighter", exp_given)
		regular_attack_timer.stop()
		animation_player.queue("death")
		await get_tree().create_timer(1).timeout
		emit_signal("enemy_defeated")
		queue_free()


func heal(amount):
	current_health += amount
	if current_health > max_health:
		current_health = max_health


func _on_timer_timeout():
	attack()


func _on_big_attack_timer_timeout():
	if fighter.is_dead or healer.is_dead:
		big_attack_timer.stop()
	is_big_attack = true
	big_attack_timer.start()


func _on_notification_timer_timeout():
	special_move_notifier_ui.visible = false
