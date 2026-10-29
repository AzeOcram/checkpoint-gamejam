extends Control


@onready var back_button: Button = $VBoxContainer/BackButton
@onready var quit_button: Button = $VBoxContainer/QuitButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	
	back_button.set_meta(&"sfx_press", &"")
	back_button.pressed.connect(_on_back_pressed)
	quit_button.pressed.connect(_on_quit_pressed)


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE and event.pressed:
			toggle_pause()


func toggle_pause() -> void:
	visible = not visible
	
	if visible:
		get_tree().paused = true
		back_button.grab_focus()
		SFX.play(&"menu_open")
	else:
		get_tree().paused = false
		SFX.play(&"menu_close")


func _on_back_pressed() -> void:
	visible = false
	get_tree().paused = false
	SFX.play(&"menu_close")


func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
