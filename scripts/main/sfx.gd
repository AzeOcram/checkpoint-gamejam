extends Node


# SFX autoload.
#
# Every BaseButton that enters the tree gets hover + press sounds automatically.
# Per-button overrides via node metadata:
#   sfx_press = "menu_close"  -> play that sound on press instead of "press"
#   sfx_press = ""            -> no automatic press sound (the script plays it)
#   sfx_blocked = "cant_afford" -> play that sound when a disabled button is clicked

const DIR := "res://assets/audio/SFX/UI/style_1/"
const SOUNDS := [
	&"hover", &"press", &"menu_open", &"menu_close", &"purchase", &"cant_afford",
]

var _players: Dictionary[StringName, AudioStreamPlayer] = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for sound in SOUNDS:
		var player := AudioStreamPlayer.new()
		player.stream = load(DIR + sound + ".wav")
		add_child(player)
		_players[sound] = player
	get_tree().node_added.connect(_on_node_added)


func play(sound: StringName) -> void:
	_players[sound].play()


func _on_node_added(node: Node) -> void:
	if not node is BaseButton:
		return
	var button := node as BaseButton
	button.mouse_entered.connect(_on_hover.bind(button))
	button.pressed.connect(_on_press.bind(button))
	button.gui_input.connect(_on_gui_input.bind(button))


func _on_hover(button: BaseButton) -> void:
	if not button.disabled:
		play(&"hover")


func _on_press(button: BaseButton) -> void:
	var sound := StringName(button.get_meta(&"sfx_press", &"press"))
	if sound != &"":
		play(sound)


func _on_gui_input(event: InputEvent, button: BaseButton) -> void:
	if (
		button.disabled
		and button.has_meta(&"sfx_blocked")
		and event is InputEventMouseButton
		and event.pressed
		and event.button_index == MOUSE_BUTTON_LEFT
	):
		play(StringName(button.get_meta(&"sfx_blocked")))
