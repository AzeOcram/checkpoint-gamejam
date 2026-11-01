
extends Control

const MALE_IMAGE: Texture2D = preload("res://assets/art/ending/game_over/male.PNG")
const FEMALE_IMAGE: Texture2D = preload("res://assets/art/ending/game_over/female.PNG")

@export var fade_duration: float = 0.8

@onready var image: TextureRect = $Image
@onready var retry_button: Button = $RetryButton


func _ready() -> void:
	retry_button.pressed.connect(_on_retry_pressed)

	if Player.gender == Player.Gender.MALE:
		image.texture = MALE_IMAGE
	else:
		image.texture = FEMALE_IMAGE

	image.modulate.a = 0.0

	var fade_in := create_tween()
	fade_in.tween_property(image, "modulate:a", 1.0, fade_duration)


func _on_retry_pressed() -> void:
	# Reset player stats before restarting
	Player.restart()

	# Reload your main game scene
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
