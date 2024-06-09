extends Area2D

class_name HealthOrb

var target: CharacterBody2D
var heal_amount: int
var speed: float = 300.0

var pause_position = self.global_position + Vector2(-45, 25)

func _process(delta):
	if target:
		var tween = get_tree().create_tween()
		print('GLOBAL POSITION: ', self.global_position)
		tween.tween_property(self, "position", pause_position, 0.75).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "position", heal_to_ally(), 0.75)
		
		if global_position.distance_to(target.global_position) < 10:
			apply_heal()
			queue_free()

func heal_to_ally():
	var direction = (target.global_position - pause_position)
	global_position += direction * speed

func apply_heal():
	if target.has_method("heal"):
		target.heal(heal_amount)
