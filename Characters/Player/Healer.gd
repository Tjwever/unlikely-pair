extends CharacterBody2D

class_name Healer

signal update_healer_health
signal healer_defeated

@onready var timer = $Timer
@onready var healthbar = $"../GameUI/PlayerSideUI/GridContainer/MarginContainer/VBoxContainer/HBoxContainer2/Healthbar"
@onready var fighter = $"../Fighter"
@onready var healer = $"."

@onready var fighter_selected = $"../Fighter/Focus"
@onready var healer_selected = $"./Focus"

@onready var animation_player = $AnimationPlayer

var max_health := 200
var current_health := 200
var defense := 3
var quick_heal := 10
var attack_delay := false
var allies = []
var selected_ally_index := 0

var isDead: bool = false

func _ready():
	healthbar.init_health(current_health)
	
	if fighter and healer:
		allies = [fighter, healer]
		hide_all_focus()
		update_focus_ui()

func take_damage(damage):
	current_health -= damage
	emit_signal("update_healer_health", current_health)
	
	if current_health < 0:
		current_health = 0

	if current_health == 0:
		animation_player.play("death")
		isDead = true
		emit_signal("healer_defeated")
		print('healer death')

func _process(_delta):
	if Input.is_action_just_pressed("heal"):
		if !attack_delay and isDead == false:
			animation_player.play("quick_heal")
			heal(quick_heal)
			attack_delay = true
			timer.start()

	if Input.is_action_just_pressed("select_up"):
		selected_ally(-1)
	
	if Input.is_action_just_pressed("select_down"):
		selected_ally(1)

func heal(amount):
	if selected_ally_index == 0:
		fighter.heal(amount)
	else:
		current_health += amount
		emit_signal("update_healer_health", current_health)

		if current_health > max_health:
			current_health = max_health

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
	print("Selected ally: ", allies[selected_ally_index].name)

func is_alive():
	return current_health <= 0

func _on_timer_timeout():
	attack_delay = false
