extends Node

var characters = {
	"healer":
	{
		"type": "healer",
		"max_health": 200,
		"current_health": 200,
		"defense": 3,
		"min_ap": 8,
		"max_ap": 8,
		"light_heal_amount": 5,
		"medium_heal_amount": 10,
		"heavy_heal_amount": 15,
		"experience": 0,
		"level": 1,
	},
	"fighter":
	{
		"type": "fighter",
		"max_health": 400,
		"current_health": 400,
		"defense": 4,
		"attack_damage": 250,
		"speed": 9.0,
		"critical_hit_rate": 3,
		"double_attack_rate": 30,
		"experience": 0,
		"level": 1,
	},
}

var enemies = {
	"skelly":
	{
		"kill_count": 0,
	}
}


# eventually, this should be something like 'load_enemy_data'
func get_kill_count(enemy):
	if enemies.has(enemy):
		return enemies[enemy]["kill_count"]


func set_kill_count(enemy):
	if enemies.has(enemy):
		enemies[enemy]["kill_count"] += 1


func load_character_data(character_name):
	if characters.has(character_name):
		return characters[character_name]
	else:
		print("Character not found...")
		return null


func save_character_data(character_name, data):
	if characters.has(character_name):
		characters[character_name] = data
	else:
		print("Character not found!")


func gain_experience(character_name, amount):
	if characters.has(character_name):
		characters[character_name]["experience"] += amount
		check_level_up(character_name)


func check_level_up(character_name):
	if characters.has(character_name):
		var character = characters[character_name]
		var level_up_experience = character["level"] * 100
		if character["experience"] >= level_up_experience:
			character["level"] += 1
			character["experience"] -= level_up_experience
			character["defense"] += 1

			match character["type"]:
				"healer":
					character["max_health"] += round(character["max_health"] * 0.12)
					character["current_health"] += round(character["max_health"] * 0.12)

					if character["level"] % 3 == 0:
						character["light_heal_amount"] += 2
						character["medium_heal_amount"] += 4
						character["heavy_heal_amount"] += 6
					if character["level"] % 5 == 0:
						character["min_ap"] += 1
						character["max_ap"] += 1
				"fighter":
					character["max_health"] += round(character["max_health"] * 0.18)
					character["current_health"] += round(character["max_health"] * 0.18)
					character["attack_damage"] += 5
					character["speed"] += 0.2
					character["critical_hit_rate"] += 1
					character["double_attack_rate"] += 5

	else:
		print("Character not found!")
