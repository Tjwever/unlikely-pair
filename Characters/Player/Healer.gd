extends CharacterBody2D

class_name Healer

signal update_healer_health
signal update_min_ap
signal healer_defeated

# UI
@onready
var healthbar = $"../GameUI/PlayerSideUI/GridContainer/MarginContainer/VBoxContainer/HBoxContainer2/Healthbar"
@onready var special_move_notifier_ui = $"../SpecialMoveNotifierUI"
@onready
var special_move_notifier_label = $"../SpecialMoveNotifierUI/VBoxContainer/PanelContainer/SpecialMoveNotifierLabel"
@onready var panel_container = $"../SpecialMoveNotifierUI/VBoxContainer/PanelContainer"

@onready
var min_ability_points = $"../GameUI/PlayerSideUI/GridContainer/MarginContainer/VBoxContainer/HBoxContainer2/HSpacer/HBoxContainer/min_ability_points"
@onready
var max_ability_points = $"../GameUI/PlayerSideUI/GridContainer/MarginContainer/VBoxContainer/HBoxContainer2/HSpacer/HBoxContainer/max_ability_points"

# Character related
@onready var enemy = $"../Enemy"
@onready var fighter = $"../Fighter"
@onready var display_numbers_origin = $DisplayNumbersOrigin
@onready var fighter_selected = $"../Fighter/Focus"
@onready var healer_selected = $"./Focus"

# Timers
@onready var recharge_ap_timer = $recharge_ap_timer
@onready var combo_window_timer = $combo_window_timer
@onready var notification_timer = $notification_timer

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

const LIGHT := "light"
const MEDIUM := "medium"
const HEAVY := "heavy"


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
		input_action(1)
		combo_window_timer.start()

	if Input.is_action_just_pressed("medium"):
		input_action(2)
		combo_window_timer.start()

	if Input.is_action_just_pressed("heavy"):
		input_action(3)
		combo_window_timer.start()

	if Input.is_action_just_pressed("select_up"):
		selected_ally(-1)

	if Input.is_action_just_pressed("select_down"):
		selected_ally(1)
	#print('time left: ', combo_window_timer.time_left)


func input_action(ability_point_deduction):
#TODO CHECK FOR EXTRA COMBO ARRAY INPUTS - have to think of If combo array length is > than the max ap, you can't fire orb
	if !attack_delay and !is_dead and min_ap >= ability_point_deduction:
		if ability_point_deduction == 1:
			combo_array.append(LIGHT)
		elif ability_point_deduction == 2:
			combo_array.append(MEDIUM)
		else:
			combo_array.append(HEAVY)

		animation_player.play("heal_button_press")
		min_ap -= ability_point_deduction
		recharging_ap()
		emit_signal("update_min_ap", min_ap)


func release_combo():
	var local_array = combo_array.duplicate()
	#combo_array.clear()

	for _heal in local_array:
		if _heal == LIGHT:
			launch_health_orb(light_heal_amount)
		elif _heal == MEDIUM:
			launch_health_orb(medium_heal_amount)
		else:
			launch_health_orb(heavy_heal_amount)
		await get_tree().create_timer(0.3).timeout
		combo_array.remove_at(0)
	cast_special_ability(local_array)


func cast_special_ability(_combo_array: Array):
	print("combo array: ", _combo_array)
	print("time left:", combo_window_timer.time_left)
	if _combo_array == [LIGHT, LIGHT, LIGHT, LIGHT]:
		regen()
	elif _combo_array == [MEDIUM, MEDIUM]:
		aoe_heal()


func regen():
	if selected_ally_index == 0:
		show_special_ability_notification("Regen!")
		if fighter.isDead:
			fighter.heal(0)
		else:
			for n in 8:
				fighter.heal(8)
				await get_tree().create_timer(0.8).timeout
	else:
		show_special_ability_notification("Regen!")
		if self.is_dead:
			self.heal(0)
		for n in 8:
			self.heal(8)
			await get_tree().create_timer(0.8).timeout


func aoe_heal():
	show_special_ability_notification("Heal all!")

	if fighter.isDead:
		fighter.heal(0)
	elif self.is_dead:
		self.heal(0)
	else:
		fighter.heal(24)
		self.heal(24)


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
	if is_dead:
		current_health = 0
	else:
		current_health += amount
		DisplayNumbers.display_number(amount, self.global_position + Vector2(10, -35), false, true)
		emit_signal("update_healer_health", current_health)

	if current_health > max_health:
		current_health = max_health


func healing_animation(health_orb: HealthOrb, character: CharacterBody2D, amount: int):
	var tween = get_tree().create_tween()

	health_orb.heal_amount = amount
	health_orb.target = character
	health_orb.global_position = global_position
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
	print("launch orb")
	if selected_ally_index == 0:
		if fighter.isDead:
			healing_animation(orb, fighter, 0)
		healing_animation(orb, fighter, amount)
	else:
		if self.is_dead:
			healing_animation(orb, self, 0)
		healing_animation(orb, self, amount)


func show_special_ability_notification(_label):
	panel_container.theme_type_variation = "HealerTheme"
	special_move_notifier_ui.visible = true
	special_move_notifier_label.text = _label
	notification_timer.start()


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


func _on_recharge_ap_timer_timeout():
	if min_ap >= max_ap:
		min_ap = max_ap
	else:
		min_ap += 1
	emit_signal("update_min_ap", min_ap)


func _on_combo_window_timer_timeout():
	release_combo()
	#combo_array = []


func _on_notification_timer_timeout():
	special_move_notifier_ui.visible = false
