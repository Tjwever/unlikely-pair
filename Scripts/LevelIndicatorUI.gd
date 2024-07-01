extends Control

@export var character: String
@onready var label = $Label

func _ready():
	
	var character_data = CharacterState.load_character_data(character)
	print("character: ", character)
	label.text = "Lv." + str(character_data["level"])
