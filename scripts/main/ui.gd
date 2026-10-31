extends Control


@onready var friends_panel: PanelContainer = $FriendsPanel
@onready var character_panel: Control = $StatsShop


func _ready() -> void:
	# The toggle handlers play menu_open/menu_close themselves.
	for button in [$SocialCircleButton, $CharacterButton]:
		button.set_meta(&"sfx_press", &"")
	friends_panel.hide()
	character_panel.hide()


func _on_social_circle_button_pressed() -> void:
	if friends_panel.visible:
		friends_panel.hide()
		SFX.play(&"menu_close")
	else:
		character_panel.hide()
		friends_panel.show()
		SFX.play(&"menu_open")


func _on_character_button_pressed() -> void:
	if character_panel.visible:
		character_panel.hide()
		SFX.play(&"menu_close")
	else:
		friends_panel.hide()
		character_panel.show()
		SFX.play(&"menu_open")
