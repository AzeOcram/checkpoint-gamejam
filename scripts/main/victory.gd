extends Control

@onready var play_again_button: Button = $PlayAgainButton
@onready var ending_label: Label = $Label


func _ready() -> void:
	play_again_button.pressed.connect(_on_play_again_pressed)
	ending_label.text = Player.ending_title


func _on_play_again_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")
