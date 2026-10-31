extends Node
class_name DaySystem

signal day_changed(day: int, day_name: String)
signal game_won # Optional signal for modular listeners


const MINUTES_PER_DAY: float = 1.5

var current_day: int = 1

@onready var day_label: Label = $Label

@onready var recruitment_system: Node = get_node("../RecruitmentSystem")


func _ready() -> void:
	current_day = get_day()
	update_day_label()


func _process(_delta: float) -> void:
	var new_day := get_day()

	if new_day != current_day:
		current_day = new_day
		
		update_day_label()
		
		print("DAY CHANGED!")
		print("Day ", current_day, " - ", get_day_name())
		
		day_changed.emit(current_day, get_day_name())
		
		# Win Condition Check
		if current_day >= 2:
			_handle_victory()


func _handle_victory() -> void:
	print("VICTORY! Player survived until Day 10!")

	var ending := determine_ending()
	print("PLAYER ENDING: ", ending)

	Player.ending_title = ending

	game_won.emit()
	get_tree().change_scene_to_file("res://scenes/main/victory.tscn")


func get_day() -> int:
	return int(Player.play_time / MINUTES_PER_DAY) + 1


func get_day_name() -> String:
	var days := [
		"Monday",
		"Tuesday",
		"Wednesday",
		"Thursday",
		"Friday"
	]

	var index := (current_day - 1) % days.size()

	return days[index]


func update_day_label() -> void:
	day_label.text = "Day " + str(current_day) + " - " + get_day_name()

func determine_ending() -> String:
	var friends: Array[FriendNode] = recruitment_system.friends
	var friend_count := friends.size()

	# Delinquent: Recruited at least one bully with positive connection.
	for friend in friends:
		if friend.data.desc in ["Bully Guy", "Bully Girl"]:
			if friend.data.connection > 0:
				return "Delinquent"

	# No Friends
	if friend_count == 0:
		return "No Friends"

	# Social Butterfly
	if friend_count > 25:
		return "Social Butterfly"

	# Few Friends (includes exactly 25)
	return "Few Friends"
