extends Control
class_name FriendNode

@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var mood_label: Label = $VBoxContainer/MoodLabel
@onready var connection_label: Label = $VBoxContainer/ConnectionLabel
@onready var generation_label: Label = $VBoxContainer/GenerationLabel

var friend_name: String = "Friend"
var mood: int = 100
var connection: int = 100
var social_battery_generation: int = 1

func setup(p_name: String) -> void:
	friend_name = p_name

func _ready() -> void:
	update_display()

func update_display() -> void:
	name_label.text = "Name: " + friend_name
	mood_label.text = "Mood: " + str(mood)
	connection_label.text = "Connection: " + str(connection)
	generation_label.text = "Generation: +" + str(social_battery_generation) + " SB/sec"
