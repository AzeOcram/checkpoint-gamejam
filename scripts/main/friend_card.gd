extends PanelContainer
class_name FriendCard


const MAX_MOOD := 100
const MAX_CONNECTION := 100
# Ordered from lowest mood up, the first threshold the mood is under picks the icon.
const MOOD_ICONS := [
	[25, preload("res://assets/art/moods/Angry.PNG")],
	[50, preload("res://assets/art/moods/Sad.PNG")],
	[75, preload("res://assets/art/moods/Neutral.PNG")],
]
const MOOD_ICON_MAX := preload("res://assets/art/moods/Happy.PNG")
const NAME_FONT_SIZE := 7
const MIN_NAME_FONT_SIZE := 4


@onready var identity: VBoxContainer = $HBoxContainer/Identity
@onready var portrait: TextureRect = $HBoxContainer/Identity/PortraitBox/Portrait
@onready var mood_icon: TextureRect = $HBoxContainer/Identity/PortraitBox/MoodIcon
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
	fit_name_font()
	mood_bar.max_value = MAX_MOOD
	connection_bar.max_value = MAX_CONNECTION
	sb_label.text = "SB Generation +" + str(data.social_battery_generation)
	refresh()


# generation_progress is 0-100, the fill of the shared Social Battery cycle.
func refresh(generation_progress: float = 0.0) -> void:
	mood_bar.value = data.mood
	mood_icon.texture = mood_texture(data.mood)
	connection_bar.value = data.connection
	sb_label.text = "SB Generation +" + str(data.social_battery_generation)
	sb_bar.value = generation_progress


# Shrinks long names so every card's Identity column stays the same width.
func fit_name_font() -> void:
	var font := name_label.get_theme_font(&"font")
	var size := NAME_FONT_SIZE

	while size > MIN_NAME_FONT_SIZE:
		var width := font.get_string_size(name_label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x

		if width <= identity.custom_minimum_size.x:
			break

		size -= 1

	name_label.add_theme_font_size_override(&"font_size", size)


static func mood_texture(mood: int) -> Texture2D:
	for entry in MOOD_ICONS:
		if mood < entry[0]:
			return entry[1]

	return MOOD_ICON_MAX
