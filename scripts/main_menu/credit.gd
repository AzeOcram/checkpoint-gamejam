extends Control

# Target scene path (adjust to match your actual main menu scene path)
const MAIN_MENU_PATH: String = "res://scenes/main_menu/main_menu.tscn"

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_PATH)
