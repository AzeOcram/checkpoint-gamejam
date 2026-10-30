extends PanelContainer
class_name FriendCard


const MAX_MOOD := 100
const MAX_CONNECTION := 100


@onready var portrait: TextureRect = $HBoxContainer/Identity/Portrait
@onready var name_label: Label = $HBoxContainer/Identity/NameLabel
@onready var mood_bar: ProgressBar = $HBoxContainer/Stats/MoodBar
@onready var connection_bar: ProgressBar = $HBoxContainer/Stats/ConnectionBar
@onready var sb_label: Label = $HBoxContainer/Stats/SBLabel
@onready var sb_bar: ProgressBar = $HBoxContainer/Stats/SBBar


var data: FriendData


func setup(friend_data: FriendData) -> void:
	data = friend_data
	portrait.texture = data.sprite
	name_label.text = data.friend_name.get_slice(" ", 0)
	mood_bar.max_value = MAX_MOOD
	connection_bar.max_value = MAX_CONNECTION
	sb_label.text = "SB Generation +" + str(data.social_battery_generation)
	refresh()


# generation_progress is 0-100, the fill of the shared Social Battery cycle.
func refresh(generation_progress: float = 0.0) -> void:
	mood_bar.value = data.mood
	connection_bar.value = data.connection
	sb_label.text = "SB Generation +" + str(data.social_battery_generation)
	sb_bar.value = generation_progress
