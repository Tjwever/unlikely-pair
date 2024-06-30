extends CharacterBody2D

@export var speed := 600.0

@onready var fight_prompt_ui = $Camera2D/FightPromptUI
@onready var animation_player = $AnimationPlayer

var can_move := true
var character_next_to_door := false


func _process(_delta):
	if can_move:
		var direction := Vector2.ZERO

		if Input.is_action_pressed("move_up"):
			direction.y -= 1
		if Input.is_action_pressed("move_down"):
			direction.y += 1
		if Input.is_action_pressed("move_left"):
			direction.x -= 1
		if Input.is_action_pressed("move_right"):
			direction.x += 1

		direction = direction.normalized()  # Normalize to ensure consistent speed
		velocity = direction * speed
		move_and_slide()

	if Input.is_action_pressed("interact"):
		if character_next_to_door:
			can_move = false
			fight_prompt_ui.visible = true



func _on_area_2d_body_entered(body):
	if body == self:
		character_next_to_door = true


func _on_area_2d_body_exited(body):
	if body == self:
		character_next_to_door = false
