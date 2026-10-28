extends Control

@onready var play_again_button: Button = $PlayAgainButton

func _ready() -> void:
	play_again_button.pressed.connect(_on_play_again_pressed)

func _on_play_again_pressed() -> void:
	# Reset Player metrics before starting a fresh run
	Player.hp = Player.max_hp
	Player.play_time = 0.0
	Player.progress_score = 0.0
	Player.energy = 0
	
	# Reload main game loop
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")
