extends PanelContainer
class_name FriendCard


const MAX_MOOD := 100
const MAX_CONNECTION := 100
const MAX_SB_GENERATION := 10


@onready var portrait: TextureRect = $HBoxContainer/Identity/Portrait
@onready var name_label: Label = $HBoxContainer/Identity/NameLabel
@onready var mood_bar: ProgressBar = $HBoxContainer/Stats/MoodBar
@onready var connection_bar: ProgressBar = $HBoxContainer/Stats/ConnectionBar
@onready var sb_bar: ProgressBar = $HBoxContainer/Stats/SBBar


var data: FriendData


func setup(friend_data: FriendData) -> void:
	data = friend_data
	portrait.texture = data.sprite
	name_label.text = data.friend_name.get_slice(" ", 0)
	mood_bar.max_value = MAX_MOOD
	connection_bar.max_value = MAX_CONNECTION
	sb_bar.max_value = MAX_SB_GENERATION
	refresh()


func refresh() -> void:
	mood_bar.value = data.mood
	connection_bar.value = data.connection
	sb_bar.value = data.social_battery_generation
