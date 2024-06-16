extends CharacterBody2D

class_name Healer

signal update_healer_health
signal update_min_ap
signal healer_defeated

@onready
var healthbar = $"../GameUI/PlayerSideUI/GridContainer/MarginContainer/VBoxContainer/HBoxContainer2/Healthbar"
@onready
var min_ability_points = $"../GameUI/PlayerSideUI/GridContainer/MarginContainer/VBoxContainer/HBoxContainer2/HSpacer/HBoxContainer/min_ability_points"
@onready
var max_ability_points = $"../GameUI/PlayerSideUI/GridContainer/MarginContainer/VBoxContainer/HBoxContainer2/HSpacer/HBoxContainer/max_ability_points"

@onready var enemy = $"../Enemy"
@onready var fighter = $"../Fighter"
@onready var display_numbers_origin = $DisplayNumbersOrigin

@onready var light_heal_delay_timer = $light_heal_delay_timer
@onready var medium_heal_delay_timer = $medium_heal_delay_timer
@onready var heavy_heal_delay_timer = $heavy_heal_delay_timer
@onready var recharge_ap_timer = $recharge_ap_timer
@onready var combo_window_timer = $combo_window_timer

@onready var fighter_selected = $"../Fighter/Focus"
@onready var healer_selected = $"./Focus"

@onready var animation_player = $AnimationPlayer
@export var health_orb_scene: PackedScene

var max_health := 200
var current_health := 200
var defense := 3
var min_ap := 4
var max_ap := 4
var attack_delay := false
var combo_array = []
var allies = []
var selected_ally_index := 0

var light_heal_amount := 5
var medium_heal_amount := 10
var heavy_heal_amount := 15

var is_dead: bool = false


func _ready():
	healthbar.init_health(current_health)
	min_ability_points.text = str(min_ap)
	max_ability_points.text = str(max_ap)

	await get_tree().create_timer(0.5).timeout
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(1370, 461), 0.4)
	await get_tree().create_timer(1).timeout
	tween.kill()

	if fighter and self:
		allies = [fighter, self]
		hide_all_focus()
		update_focus_ui()


func _process(_delta):
	if not is_instance_valid(enemy) or enemy.is_dead:
		return

	if Input.is_action_just_pressed("light"):
		input_action(light_heal_amount, 1, light_heal_delay_timer)

	if Input.is_action_just_pressed("medium"):
		input_action(medium_heal_amount, 2, medium_heal_delay_timer)

	if Input.is_action_just_pressed("heavy"):
		input_action(heavy_heal_amount, 3, heavy_heal_delay_timer)

	if Input.is_action_just_pressed("select_up"):
		selected_ally(-1)

	if Input.is_action_just_pressed("select_down"):
		selected_ally(1)


func input_action(healing_amount, ability_point_deduction, timer):
	if !attack_delay and !is_dead and min_ap >= ability_point_deduction:
		if ability_point_deduction == 1:
			animation_player.play("light_heal")
			combo_array.append('l')
			combo_window_timer.start()
		elif ability_point_deduction == 2:
			animation_player.play("medium_heal")
		else:
			animation_player.play("heavy_heal")
			pass
		min_ap -= ability_point_deduction
		recharging_ap()
		emit_signal("update_min_ap", min_ap)
		attack_delay = true
		timer.start()
		launch_health_orb(healing_amount)
		cast_special_ability()


func cast_special_ability():
	print('combo array: ', combo_array)
	if combo_array == ['l', 'l', 'l', 'l']:
		print('works')
		regen()
		combo_array = []
	else:
		print('nothing')


func regen():
	if selected_ally_index == 0:
		for n in 8:
			fighter.heal(8)
			await get_tree().create_timer(0.8).timeout
	else:
		for n in 8:
			self.heal(8)
			await get_tree().create_timer(0.8).timeout


func take_damage(damage):
	current_health -= damage
	DisplayNumbers.display_number(damage, display_numbers_origin.global_position, false, false)
	emit_signal("update_healer_health", current_health)

	if current_health < 0:
		current_health = 0

	if current_health == 0:
		animation_player.play("death")
		is_dead = true
		emit_signal("healer_defeated")
		print("healer death")


func heal(amount):
	current_health += amount
	DisplayNumbers.display_number(amount, self.global_position + Vector2(10, -35), false, true)
	emit_signal("update_healer_health", current_health)

	if current_health > max_health:
		current_health = max_health


func healing_animation(health_orb: HealthOrb, character: CharacterBody2D, amount: int):
	var tween = get_tree().create_tween()

	health_orb.target = character
	health_orb.global_position = global_position
	health_orb.heal_amount = amount
	get_tree().current_scene.add_child(health_orb)

	(
		tween
		. tween_property(health_orb, "position", self.global_position + Vector2(-12, 15), 0)
		. set_ease(Tween.EASE_OUT)
	)
	tween.tween_property(health_orb, "scale", Vector2(0, 0), 0)
	tween.tween_property(health_orb, "scale", Vector2(1, 1), 0.3)
	(
		tween
		. tween_property(health_orb, "position", self.global_position + Vector2(-35, 10), 0.3)
		. set_ease(Tween.EASE_OUT)
	)
	tween.tween_property(health_orb, "position", character.global_position, 0.3)


func launch_health_orb(amount):
	var orb = health_orb_scene.instantiate()

	if selected_ally_index == 0:
		healing_animation(orb, fighter, amount)
	else:
		healing_animation(orb, self, amount)


func hide_all_focus():
	fighter_selected.hide()
	healer_selected.hide()


func update_focus_ui():
	hide_all_focus()
	if selected_ally_index == 0:
		fighter_selected.show()
	elif selected_ally_index == 1:
		healer_selected.show()


func selected_ally(direction):
	selected_ally_index += direction
	if selected_ally_index < 0:
		selected_ally_index = allies.size() - 1
	elif selected_ally_index >= allies.size():
		selected_ally_index = 0

	update_focus_ui()


func recharging_ap():
	if min_ap < max_ap:
		recharge_ap_timer.start()


func _on_timer_timeout():
	attack_delay = false


func _on_medium_heal_delay_timeout():
	attack_delay = false


func _on_heavy_heal_delay_timeout():
	attack_delay = false


func _on_recharge_ap_timer_timeout():
	if min_ap >= max_ap:
		min_ap = max_ap
	else:
		min_ap += 1
	emit_signal("update_min_ap", min_ap)


func _on_combo_window_timer_timeout():
	combo_array = []
