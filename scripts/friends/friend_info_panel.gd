extends Control
class_name FriendInfoPanel


signal buy_requested(friend_data: FriendData)

var default_disabled_texture: Texture2D
@onready var portrait: Sprite2D = $Portrait

@onready var name_label: Label = $InfoContainer/NameLabel
@onready var description_label: Label = $InfoContainer/DescriptionLabel
@onready var generation_label: Label = $InfoContainer/GenerationLabel
@onready var luck_label: Label = $InfoContainer/LuckLabel

@onready var buy_button: TextureButton = $BuyButton
@onready var cost_label: Label = $CostLabel
@onready var close_button: TextureButton = $CloseButton


var data: FriendData


func _ready() -> void:
	print("PANEL RECT: ", get_global_rect())
	print("PANEL SIZE: ", size)
	print("BUY RECT: ", buy_button.get_global_rect())
	print("BUY POSITION: ", buy_button.position)
	print("BUY SIZE: ", buy_button.size)
	add_to_group(&"blocks_tap")
	hide()
	mouse_filter = Control.MOUSE_FILTER_STOP
	buy_button.mouse_filter = Control.MOUSE_FILTER_STOP
	close_button.mouse_filter = Control.MOUSE_FILTER_STOP

	default_disabled_texture = buy_button.texture_disabled

	# The buy handler (friend_map.gd) plays purchase; disabled clicks play cant_afford.
	buy_button.set_meta(&"sfx_press", &"")
	buy_button.set_meta(&"sfx_blocked", &"cant_afford")
	close_button.set_meta(&"sfx_press", &"menu_close")
	buy_button.pressed.connect(_on_buy_pressed)
	close_button.pressed.connect(_on_close_pressed)

func setup(friend_data: FriendData) -> void:
	data = friend_data

	if data == null:
		return

	portrait.texture = data.sprite

	name_label.text = data.friend_name
	description_label.text = data.desc

	generation_label.text = "Generation: +" + str(data.social_battery_generation) + " SB/sec"
	luck_label.text = "Luck: " + str(data.luck * 100) + "%"

	cost_label.text = NumberFormatter.format_number(data.recruitment_cost) + " SB"

	if data.unlocked:
		buy_button.button_pressed = true
	else:
		buy_button.button_pressed = false


func set_buyable(can_buy: bool) -> void:
	if data == null:
		return

	if data.unlocked:
		buy_button.button_pressed = true
		buy_button.disabled = true
		buy_button.texture_disabled = buy_button.texture_pressed
		return

	buy_button.button_pressed = false
	buy_button.texture_disabled = default_disabled_texture
	buy_button.disabled = not can_buy

func _on_buy_pressed() -> void:
	print("========== BEFRIEND BUTTON CLICKED ==========")

	if data == null:
		return

	if data.unlocked:
		return

	buy_requested.emit(data)


func _on_close_pressed() -> void:
	hide()
