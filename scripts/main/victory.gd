
extends Control

const GAME_SCENE := "res://scenes/main/main.tscn"

@export var image_duration: float = 2.0
@export var fade_duration: float = 0.5

@onready var ending_image: TextureRect = $EndingImage
@onready var ending_title: Label = $EndingTitle
@onready var ending_description: Label = $EndingDescription
@onready var play_again_button: Button = $PlayAgainButton

var cutscene_finished := false


func _ready() -> void:
	ending_image.modulate.a = 0.0

	ending_title.hide()
	ending_description.hide()
	play_again_button.hide()

	play_again_button.pressed.connect(_on_play_again_pressed)

	play_cutscene()


func get_ending_images() -> Array[Texture2D]:
	var ending := Player.ending_title.to_snake_case()
	var gender := "male" if Player.gender == Player.Gender.MALE else "female"

	var folder_path := "res://assets/art/ending/%s_%s/" % [ending, gender]

	var images: Array[Texture2D] = []

	for i in range(1, 4):
		var image_path := folder_path + str(i) + ".PNG"
		var texture := load(image_path) as Texture2D

		if texture == null:
			push_error("Could not load ending image: " + image_path)
			return []

		images.append(texture)

	return images


func play_cutscene() -> void:
	var images := get_ending_images()

	if images.is_empty():
		return

	for texture in images:
		if cutscene_finished:
			return

		ending_image.texture = texture

		var fade_in := create_tween()
		fade_in.tween_property(
			ending_image,
			"modulate:a",
			1.0,
			fade_duration
		)
		await fade_in.finished

		if cutscene_finished:
			return

		await get_tree().create_timer(image_duration).timeout

		if cutscene_finished:
			return

		var fade_out := create_tween()
		fade_out.tween_property(
			ending_image,
			"modulate:a",
			0.0,
			fade_duration
		)
		await fade_out.finished

		if cutscene_finished:
			return

	_show_final_ending()


func _show_final_ending() -> void:
	cutscene_finished = true

	ending_image.hide()

	ending_title.text = Player.ending_title + " Ending"

	match Player.ending_title:
		"Delinquent":
			ending_description.text = "You've joined and blindly followed bullies"
		"No Friends":
			ending_description.text = "You ended your journey without making any friends."
		"Few Friends":
			ending_description.text = "You made a few friends along the way."
		"Social Butterfly":
			ending_description.text = "You've built a wide circle of meaningful friendships."

	var bad_endings := ["Delinquent", "No Friends"]

	var ending_color := Color.RED if Player.ending_title in bad_endings else Color.GREEN

	ending_title.add_theme_color_override("font_color", ending_color)
	ending_description.add_theme_color_override("font_color", ending_color)

	ending_title.show()
	ending_description.show()
	play_again_button.show()

func _on_play_again_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)
