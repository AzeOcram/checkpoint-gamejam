extends Control


@onready var friends_panel: PanelContainer = $FriendsPanel
@onready var character_panel: PanelContainer = $CharacterPanel


func _ready() -> void:
	friends_panel.hide()
	character_panel.hide()


func _on_social_circle_button_pressed() -> void:
	character_panel.hide()
	friends_panel.show()


func _on_character_button_pressed() -> void:
	friends_panel.hide()
	character_panel.show()
