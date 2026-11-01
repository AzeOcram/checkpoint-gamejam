extends Control

const GAME_SCENE := "res://scenes/main/main.tscn"

@export var image_duration: float = 3.0
@export var fade_duration: float = 0.5
@export var text_duration: float = 3.0

@onready var ending_image: TextureRect = $EndingImage
@onready var ending_title: Label = $EndingTitle
@onready var ending_description: Label = $EndingDescription
@onready var play_again_button: Button = $PlayAgainButton

var bad_endings := ["Delinquent", "No Friends"]

var cutscene_finished := false


func _ready() -> void:
	$AudioStreamPlayer2D.pitch_scale = 0.44 if Player.ending_title in bad_endings else 1.44
	$AudioStreamPlayer2D.play()

	ending_image.modulate.a = 0.0
	ending_description.modulate.a = 0.0

	ending_title.hide()
	ending_description.hide()
	play_again_button.hide()

	play_again_button.pressed.connect(_on_play_again_pressed)

	play_cutscene()


func get_ending_images() -> Array[Texture2D]:
	var gender := "male" if Player.gender == Player.Gender.MALE else "female"
	var images: Array[Texture2D] = []

	match Player.ending_title:
		"Delinquent":
			if gender == "male":
				images = [
					preload("res://assets/art/ending/delinquent_male/1.PNG"),
					preload("res://assets/art/ending/delinquent_male/2.PNG"),
					preload("res://assets/art/ending/delinquent_male/3.PNG")
				]
			else:
				images = [
					preload("res://assets/art/ending/delinquent_female/1.PNG"),
					preload("res://assets/art/ending/delinquent_female/2.PNG"),
					preload("res://assets/art/ending/delinquent_female/3.PNG")
				]

		"No Friends":
			if gender == "male":
				images = [
					preload("res://assets/art/ending/no_friends_male/1.PNG")
				]
			else:
				images = [
					preload("res://assets/art/ending/no_friends_female/1.PNG")
				]

		"Few Friends":
			if gender == "male":
				images = [
					preload("res://assets/art/ending/few_friends_male/1.PNG")
				]
			else:
				images = [
					preload("res://assets/art/ending/few_friends_female/1.PNG")
				]

		"Social Butterfly":
			if gender == "male":
				images = [
					preload("res://assets/art/ending/social_butterfly_male/1.PNG")
				]
			else:
				images = [
					preload("res://assets/art/ending/social_butterfly_female/1.PNG")
				]

	return images


func play_cutscene() -> void:
	var images := get_ending_images()

	if images.is_empty():
		push_warning("No ending images found. Showing ending screen without cutscene.")
		_show_final_ending()
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

	var ending_paragraphs: Array[String] = []

	match Player.ending_title:
		"Delinquent":
			ending_title.text = "Delinquent Ending"
			ending_paragraphs = [
				"You've made it! You finally have some friends, very questionable ones...",
				"You learned various things such as smoking, stealing money from other students, and even getting into fights.",
				"But it should be fine, right? As long as you have friends, then it should be okay."
			]

		"No Friends":
			ending_title.text = "No Friends Ending"
			ending_paragraphs = [
				"You weren't able to connect with anyone, but that's not the end.",
				"Maybe you can try again next time.",
				"Just don't lose hope."
			]

		"Few Friends":
			ending_title.text = "Few Friends Ending"
			ending_paragraphs = [
				"You made some friends!",
				"It's a small and humble circle of people you love and cherish.",
				"You care for them just as much as they care for you."
			]

		"Social Butterfly":
			ending_title.text = "Social Butterfly Ending"
			ending_paragraphs = [
				"You did it! You befriended almost everyone in class!",
				"From the wallflowers to the hooligans, you managed to find common ground with every single person.",
				"It was overwhelming, but nonetheless, you're proud of the friends you made."
			]

	var ending_color := Color.RED if Player.ending_title in bad_endings else Color.GREEN

	ending_title.add_theme_color_override("font_color", ending_color)
	ending_description.add_theme_color_override("font_color", ending_color)

	ending_title.show()
	ending_description.show()

	for paragraph in ending_paragraphs:
		ending_description.text = paragraph
		ending_description.modulate.a = 0.0

		var fade_in := create_tween()
		fade_in.tween_property(
			ending_description,
			"modulate:a",
			1.0,
			fade_duration
		)
		await fade_in.finished

		await get_tree().create_timer(text_duration).timeout

		var fade_out := create_tween()
		fade_out.tween_property(
			ending_description,
			"modulate:a",
			0.0,
			fade_duration
		)
		await fade_out.finished

	play_again_button.show()


func _on_play_again_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)
