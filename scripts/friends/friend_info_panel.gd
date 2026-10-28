extends Control
class_name FriendInfoPanel


signal buy_requested(friend_data: FriendData)


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
	hide()
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
	luck_label.text = "Luck: " + str(data.luck)

	cost_label.text = str(data.recruitment_cost) + " SB"

	if data.unlocked:
		buy_button.disabled = true
	else:
		buy_button.disabled = false


func set_buyable(can_buy: bool) -> void:
	if data == null:
		return

	# Already recruited.
	if data.unlocked:
		buy_button.disabled = true
		return

	# Not recruited yet.
	buy_button.disabled = not can_buy


func _on_buy_pressed() -> void:
	if data == null:
		return

	if data.unlocked:
		return

	buy_requested.emit(data)


func _on_close_pressed() -> void:
	hide()
