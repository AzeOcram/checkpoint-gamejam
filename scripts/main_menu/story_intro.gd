
extends Control

const GAME_SCENE := "res://scenes/main/main.tscn"

const MALE_IMAGES: Array[Texture2D] = [
	preload("res://assets/cutscenes/INTRO/1.png"),
	preload("res://assets/cutscenes/INTRO/2.png"),
	preload("res://assets/cutscenes/INTRO/3.png"),
	preload("res://assets/cutscenes/INTRO/4.png"),
	preload("res://assets/cutscenes/INTRO/5_male.png"),
	preload("res://assets/cutscenes/INTRO/6_male.png")
]

const FEMALE_IMAGES: Array[Texture2D] = [
	preload("res://assets/cutscenes/INTRO/1.png"),
	preload("res://assets/cutscenes/INTRO/2.png"),
	preload("res://assets/cutscenes/INTRO/3.png"),
	preload("res://assets/cutscenes/INTRO/4.png"),
	preload("res://assets/cutscenes/INTRO/5_female.png"),
	preload("res://assets/cutscenes/INTRO/6_female.png")
]

@export var image_duration: float = 2.0
@export var fade_duration: float = 0.5

@onready var image: TextureRect = $Image
@onready var skip_button: Button = $SkipButton

var cutscene_finished := false


func _ready() -> void:
	image.modulate.a = 0.0
	skip_button.pressed.connect(_on_skip_pressed)
	play_cutscene()


func play_cutscene() -> void:
	var images: Array[Texture2D]

	if Player.gender == Player.Gender.MALE:
		images = MALE_IMAGES
	else:
		images = FEMALE_IMAGES

	for texture in images:
		if cutscene_finished:
			return

		image.texture = texture

		var fade_in := create_tween()
		fade_in.tween_property(image, "modulate:a", 1.0, fade_duration)
		await fade_in.finished

		if cutscene_finished:
			return

		await get_tree().create_timer(image_duration).timeout

		if cutscene_finished:
			return

		var fade_out := create_tween()
		fade_out.tween_property(image, "modulate:a", 0.0, fade_duration)
		await fade_out.finished

		if cutscene_finished:
			return

	cutscene_finished = true
	get_tree().change_scene_to_file(GAME_SCENE)


func _on_skip_pressed() -> void:
	if cutscene_finished:
		return

	cutscene_finished = true
	get_tree().change_scene_to_file(GAME_SCENE)
