extends Control
class_name FriendNode


# Nodes
@onready var friend_sprite: Sprite2D = $VBoxContainer/FriendSprite
@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var mood_label: Label = $VBoxContainer/MoodLabel
@onready var connection_label: Label = $VBoxContainer/ConnectionLabel
@onready var generation_label: Label = $VBoxContainer/GenerationLabel


# Friend Data
var data: FriendData


func _ready() -> void:
	update_display()


# Sets the data for this friend.
func setup(friend_data: FriendData) -> void:
	data = friend_data


func update_display() -> void:
	if data == null:
		return

	name_label.text = "Name: " + data.friend_name
	mood_label.text = "Mood: " + str(data.mood)
	connection_label.text = "Connection: " + str(data.connection)
	generation_label.text = "Generation: +" + str(data.social_battery_generation) + " SB/sec"
