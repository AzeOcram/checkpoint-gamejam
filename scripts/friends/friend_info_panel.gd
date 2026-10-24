extends PanelContainer
class_name FriendInfoPanel


signal buy_requested(friend_data: FriendData)


@onready var name_label: Label = $MarginContainer/VBoxContainer/NameLabel
@onready var description_label: Label = $MarginContainer/VBoxContainer/DescriptionLabel
@onready var mood_label: Label = $MarginContainer/VBoxContainer/MoodLabel
@onready var connection_label: Label = $MarginContainer/VBoxContainer/ConnectionLabel
@onready var generation_label: Label = $MarginContainer/VBoxContainer/GenerationLabel
@onready var cost_label: Label = $MarginContainer/VBoxContainer/CostLabel
@onready var buy_button: Button = $MarginContainer/VBoxContainer/BuyButton


var data: FriendData


func _ready() -> void:
	buy_button.pressed.connect(_on_buy_pressed)


func setup(friend_data: FriendData) -> void:
	data = friend_data

	if data == null:
		return

	name_label.text = data.friend_name
	description_label.text = data.desc
	mood_label.text = "Mood: " + str(data.mood)
	connection_label.text = "Connection: " + str(data.connection)
	generation_label.text = "Generation: +" + str(data.social_battery_generation) + " SB/sec"
	cost_label.text = "Cost: " + str(data.recruitment_cost) + " SB"

	# Only handle whether the friend has already been recruited.
	if data.unlocked:
		buy_button.text = "RECRUITED"
		buy_button.disabled = true
	else:
		buy_button.text = "BUY"
		buy_button.disabled = false


func set_buyable(can_buy: bool) -> void:
	if data == null:
		return

	# Already recruited.
	if data.unlocked:
		buy_button.text = "RECRUITED"
		buy_button.disabled = true
		return

	# Not recruited yet.
	buy_button.text = "BUY"
	buy_button.disabled = not can_buy


func _on_buy_pressed() -> void:
	if data == null:
		return

	if data.unlocked:
		return

	buy_requested.emit(data)
