extends Node


func display_number(
	value: int, position: Vector2, is_critical: bool = false, is_healing: bool = false
):
	var number = Label.new()
	number.global_position = position
	number.text = str(value)
	number.z_index = 5
	number.label_settings = LabelSettings.new()

	var color = "#FFF"
	if is_critical:
		color = "#CCB023"
	if is_healing:
		color = "#00ce89"
	if value == 0:
		color = "#FFF8"

	number.label_settings.font_color = color
	number.label_settings.font_size = 48
	number.label_settings.outline_color = "#000"
	number.label_settings.outline_size = 15

	call_deferred("add_child", number)

	await number.resized
	number.pivot_offset = Vector2(number.size / 2)

	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(number, "position", number.global_position + _get_direction(), 0.75)
	(
		tween
		. tween_property(number, "position:y", number.position.y - 24, 0.25)
		. set_ease(Tween.EASE_OUT)
		. set_delay(0.25)
	)
	(
		tween
		. tween_property(number, "position:y", number.position.y, 0.5)
		. set_ease(Tween.EASE_IN)
		. set_delay(0.25)
	)
	tween.tween_property(number, "scale", Vector2.ZERO, 0.25).set_ease(Tween.EASE_IN).set_delay(0.5)

	await tween.finished
	number.queue_free()


func _get_direction():
	return Vector2(randf_range(-1, 1), -randf()) * 48
