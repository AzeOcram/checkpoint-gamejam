extends Control

@onready var retry_button: Button = $RetryButton

func _ready() -> void:
	retry_button.pressed.connect(_on_retry_pressed)

func _on_retry_pressed() -> void:
	# Reset player stats before restarting
	Player.restart()
	
	# Reload your main game scene
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
