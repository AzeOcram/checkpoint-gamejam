extends Node
class_name DaySystem


signal day_changed(day: int, day_name: String)


const MINUTES_PER_DAY: float = 3.0

var current_day: int = 1

@onready var day_label: Label = $Label


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
