extends Marker2D

@export var damage_node: PackedScene


func _ready():
	randomize()


func popup():
	var damage = damage_node.instantiate()
	damage.position = global_position

	var tween = get_tree().create_tween()
	tween.tween_property(damage, "position", global_position + _get_direction(), 0.75)

	get_tree().current_scene.add_child(damage)


func _get_direction():
	return Vector2(randf_range(-1, 1), -randf()) * 46


func _input(event):
	if event.is_action_pressed("test"):
		popup()
