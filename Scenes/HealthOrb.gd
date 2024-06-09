extends Area2D

class_name HealthOrb

var target: CharacterBody2D
var heal_amount: int
var speed: float = 300.0

#var pause_position = self.global_position + Vector2(-45, 25)
#
#func _process(delta):
	#if target:
		#var tween = get_tree().create_tween()
		#print('GLOBAL POSITION: ', self.global_position)
		#tween.tween_property(self, "position", pause_position, 0.75).set_ease(Tween.EASE_OUT)
		#tween.tween_property(self, "position", heal_to_ally(), 0.75)
		#
		#if global_position.distance_to(target.global_position) < 10:
			#apply_heal()
			#queue_free()
#
#func heal_to_ally():
	#var direction = (target.global_position - pause_position)
	#global_position += direction * speed
#
#func apply_heal():
	#if target.has_method("heal"):
		#target.heal(heal_amount)


@onready var tween = get_tree().create_tween()

func _ready():
	if target:
		shoot_out_and_pause()

func shoot_out_and_pause():
	var start_position = global_position
	var pause_position = start_position + Vector2(-45, 25)  # Adjust this vector as needed
	
	tween.tween_property(self, "global_position", pause_position, 0.75).set_ease(Tween.EASE_OUT)
	tween.tween_callback(move_to_target())

func move_to_target():
	if target:
		tween.tween_property(self, "global_position", target.global_position, 0.75).set_ease(Tween.EASE_IN)
		tween.tween_callback(apply_heal())

func apply_heal():
	if target and target.has_method("heal"):
		target.heal(heal_amount)
	queue_free()
