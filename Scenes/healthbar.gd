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
	health_bar.max_value = health
	health_bar.value = health
	health_bar.modulate = Color(0, 0.808, 0.537, 0)


func update_health(_health):
	var prev_health = health
	health = _health
	value = health

	if health < prev_health:
		timer.wait_time = 0.4
		timer.start()
	elif health > prev_health:
		health_bar.value = health
		health_bar.modulate = Color(0, 0.808, 0.537, 1)
		timer.wait_time = 0.2
		health_bar_fade_out()
	else:
		damage_bar.value = health


func health_bar_fade_out():
	await get_tree().create_timer(0.3).timeout
	var fade_time = 0.3
	var fade_steps = 10
	var fade_step_time = fade_time / fade_steps
	for i in range(fade_steps):
		var alpha = 1 - float(i + 1) / fade_steps
		health_bar.modulate.a = alpha
		await get_tree().create_timer(fade_step_time).timeout
	health_bar.modulate.a = 0


func _on_timer_timeout():
	damage_bar.value = health


func _on_enemy_update_enemy_health(_health):
	update_health(_health)


func _on_healer_update_healer_health(_health):
	update_health(_health)


func _on_fighter_update_fighter_health(_health):
	update_health(_health)
