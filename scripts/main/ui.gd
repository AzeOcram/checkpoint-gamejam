extends Control


@onready var friends_panel: PanelContainer = $FriendsPanel
@onready var character_panel: Control = $StatsShop
@onready var qte_queue_manager: QTEQueueManager = $"../Systems/QTEQueueManager"
@onready var intro: DayIntroCutscene = $"../DayIntroCutscene"


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


func _unhandled_input(event: InputEvent) -> void:
	if is_instance_valid(qte_queue_manager.active_qte) or intro.is_playing():
		return

	if event.is_action_pressed(&"pause") and has_panel_open():
		friends_panel.hide()
		character_panel.hide()
		SFX.play(&"menu_close")
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"open_shop"):
		_on_character_button_pressed()
	elif event.is_action_pressed(&"open_friends"):
		_on_social_circle_button_pressed()


func has_panel_open() -> bool:
	return friends_panel.visible or character_panel.visible
