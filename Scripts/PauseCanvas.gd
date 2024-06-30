extends CanvasLayer


func _on_continue_pressed():
	self.visible = false
	get_tree().paused = false


func _on_quit_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/start_menu.tscn")
