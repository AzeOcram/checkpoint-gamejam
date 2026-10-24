extends Control


@onready var friends_panel: PanelContainer = $FriendsPanel
@onready var character_panel: PanelContainer = $CharacterPanel


func _ready() -> void:
	friends_panel.hide()
	character_panel.hide()


func _on_social_circle_button_pressed() -> void:
	if friends_panel.visible:
		friends_panel.hide()
	else:
		character_panel.hide()
		friends_panel.show()


func _on_character_button_pressed() -> void:
	if character_panel.visible:
		character_panel.hide()
	else:
		friends_panel.hide()
		character_panel.show()
