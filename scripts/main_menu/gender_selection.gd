extends Control

@onready var male_button: TextureButton = $CenterContainer/VBoxContainer/HBoxContainer/Male/MaleButton
@onready var female_button: TextureButton = $CenterContainer/VBoxContainer/HBoxContainer/Female/FemaleButton
@onready var back_button: TextureButton = $BackButton


func _ready() -> void:
	if male_button:
		male_button.pressed.connect(_on_male_selected)
	if female_button:
		female_button.pressed.connect(_on_female_selected)
	if back_button:
		back_button.pressed.connect(_on_back_pressed)


func _on_male_selected() -> void:
	Player.gender = Player.Gender.MALE
	SFX.play(&"press")
	_start_game()


func _on_female_selected() -> void:
	Player.gender = Player.Gender.FEMALE
	SFX.play(&"press")
	_start_game()


func _start_game() -> void:
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")


func _on_back_pressed() -> void:
	SFX.play(&"menu_close")
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
