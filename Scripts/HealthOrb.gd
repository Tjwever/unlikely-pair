extends Area2D

class_name HealthOrb

var target: CharacterBody2D
var heal_amount: int
var speed: float = 300.0

var pause_position = self.global_position


func _process(_delta):
	if target:
		if global_position.distance_to(target.global_position) < 10:
			apply_heal()
			queue_free()


func apply_heal():
	if target.has_method("heal"):
		target.heal(heal_amount)
