extends Label

@onready var min_ability_points = $"."

var ability_points := 0


func init_ability_points(_ap):
	ability_points = _ap
	text = str(ability_points)


func update_ability_points(_ap):
	#var prev_ability_points = ability_points
	ability_points = _ap
	text = str(ability_points)

func _on_healer_update_min_ap(_ability_points):
	update_ability_points(_ability_points)
