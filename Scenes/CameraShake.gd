extends Camera2D


func shake(intensity):
	var original_position = self.position

	var tween = get_tree().create_tween()

	tween.tween_property(self, "position", original_position + Vector2(0, intensity), 0.1)
	tween.tween_property(self, "position", original_position - Vector2(0, intensity), 0.1)
	tween.tween_property(self, "position", original_position + Vector2(0, round(intensity / 2)), 0.1)
	tween.tween_property(self, "position", original_position - Vector2(0, round(intensity / 2)), 0.1)
	tween.tween_property(self, "position", original_position, 0.1)
