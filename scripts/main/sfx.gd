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

const OTHER := {
	&"health_up": "res://assets/audio/SFX/health_up.wav",
	&"luck_up": "res://assets/audio/SFX/luck_up.wav",
	&"energy_up_1": "res://assets/audio/SFX/energy_per_tap_up_1.wav",
	&"energy_up_2": "res://assets/audio/SFX/energy_per_tap_up_2.wav",
	&"energy_up_3": "res://assets/audio/SFX/energy_per_tap_up_3.wav",
	&"qte_success": "res://assets/audio/SFX/QTE/qte_success.wav",
	&"qte_fail": "res://assets/audio/SFX/QTE/qte_fail.wav",
	&"swish": "res://assets/audio/SFX/QTE/basketball_swish.wav",
	&"chalk": "res://assets/audio/SFX/QTE/chalk_write.wav",
	&"paper_rip": "res://assets/audio/SFX/QTE/paper_rip.wav",
	&"bunot": "res://assets/audio/SFX/QTE/bunot.wav",
	&"paper_pickup_1": "res://assets/audio/SFX/QTE/paper_pickup_1.wav",
	&"paper_pickup_2": "res://assets/audio/SFX/QTE/paper_pickup_2.wav",
	&"paper_pickup_3": "res://assets/audio/SFX/QTE/paper_pickup_3.wav",
	&"paper_pickup_4": "res://assets/audio/SFX/QTE/paper_pickup_4.wav",
}

var _players: Dictionary[StringName, AudioStreamPlayer] = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for sound in SOUNDS:
		var player := AudioStreamPlayer.new()
		player.stream = load(DIR + sound + ".wav")
		add_child(player)
		_players[sound] = player
	for sound in OTHER:
		var player := AudioStreamPlayer.new()
		player.stream = load(OTHER[sound])
		add_child(player)
		_players[sound] = player
	get_tree().node_added.connect(_on_node_added)


func play(sound: StringName) -> void:
	_players[sound].play()


func play_random(sounds: Array) -> void:
	play(sounds.pick_random())


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
