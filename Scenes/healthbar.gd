extends ProgressBar

@onready var timer = $Timer
@onready var damage_bar = $DamageBar
@onready var health_bar = $HealingBar

var health = 0

func init_health(_health):
	health = _health
	max_value = health
	value = health
	damage_bar.max_value = health
	damage_bar.value = health

func update_health(_health):
	var prev_health = health
	health = _health
	value = health
	health_bar.value = health

	if health < prev_health:
		timer.start()
	else:
		damage_bar.value = health

func _on_timer_timeout():
	damage_bar.value = health

func _on_enemy_update_enemy_health(_health):
	update_health(_health)

func _on_healer_update_healer_health(_health):
	update_health(_health)

func _on_fighter_update_fighter_health(_health):
	update_health(_health)
