extends Camera2D

class_name CameraShake2D

var _intensity = 1
var _duration = 1
var _start_time = 0
var _rng = RandomNumberGenerator.new()


func _ready():
	randomize()
	set_process(false)


func _process(_delta):
	var decreaser = (_duration - round(Time.get_ticks_msec() - _start_time)) / _duration

	var rand_x = _rng.randf_range(-1, 1) * _intensity * decreaser
	var rand_y = _rng.randf_range(-1, 1) * _intensity * decreaser

	offset = Vector2(rand_x, rand_y)

	if decreaser < 0:
		offset = Vector2.ZERO
		set_process(false)


func shake(intensity = 1.0, duration = 1.0):
	_intensity = float(intensity)
	_duration = float(duration * 1000)
	_start_time = Time.get_ticks_msec()

	set_process(true)

#func shake(intensity):
#var original_position = self.position
#
#var tween = get_tree().create_tween()
#
#tween.tween_property(self, "position", original_position + Vector2(0, intensity), 0.1)
#tween.tween_property(self, "position", original_position - Vector2(0, intensity), 0.1)
#tween.tween_property(self, "position", original_position + Vector2(0, round(intensity / 2)), 0.1)
#tween.tween_property(self, "position", original_position - Vector2(0, round(intensity / 2)), 0.1)
#tween.tween_property(self, "position", original_position, 0.1)
