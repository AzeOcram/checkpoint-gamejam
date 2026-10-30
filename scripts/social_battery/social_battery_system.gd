
extends Node

signal social_battery_changed

const SOCIAL_BATTERY_FEEDBACK = preload("res://scenes/social_battery/social_battery_feedback.tscn")

@onready var social_battery_label: Label = $SocialBatteryLabel
@onready var social_battery_timer: Timer = $SocialBatteryTimer
@onready var feedback_container: Control = $SocialBatteryFeedbackLayer/FeedbackContainer
@onready var generation_progress_bar: TextureProgressBar = $GenerationProgressBar
@onready var recruitment_system = get_node("../RecruitmentSystem")


# NOTE: This is the API you will need to call for all
# Social Battery related shitt.
#
# The actual Social Battery value is stored in Player.
# This system is responsible for Social Battery mechanics.


func _ready() -> void:
	update_social_battery_ui()

	# Start the generation progress bar empty.
	generation_progress_bar.value = 0.0


# Returns the player's current Social Battery.
func get_amount() -> int:
	return Player.social_battery


# Adds Social Battery to the player.
func add(amount: int) -> void:
	Player.social_battery += amount

	update_social_battery_ui()
	social_battery_changed.emit()


# Attempts to spend Social Battery.
# Returns true if the player had enough.
func spend(amount: int) -> bool:
	if not can_afford(amount):
		return false

	Player.social_battery -= amount

	update_social_battery_ui()
	social_battery_changed.emit()
	return true


# Checks whether the player can afford an amount
# without changing their Social Battery.
func can_afford(amount: int) -> bool:
	return Player.social_battery >= amount


# Updates the Social Battery UI.
func update_social_battery_ui() -> void:
	social_battery_label.text = (
		"Social Battery: "
		+ NumberFormatter.format_number(get_amount())
	)


# Generates Social Battery.
func generate() -> void:
	var generation := get_total_generation()
	add(generation)
	spawn_social_battery_feedback(generation)
	generation_progress_bar.value = 0.0


# Gets the player's total Social Battery generation.
func get_total_generation() -> int:
	var total_generation := Player.social_battery_per_second

	for friend in recruitment_system.friends:
		if friend.data != null:
			total_generation += friend.data.social_battery_generation

	return total_generation


# Spawns the +SB feedback at the right side of the progress bar.
func spawn_social_battery_feedback(amount: int) -> void:
	var feedback = SOCIAL_BATTERY_FEEDBACK.instantiate()

	feedback.position = Vector2(
		generation_progress_bar.position.x + generation_progress_bar.size.x,
		generation_progress_bar.position.y
	)

	feedback_container.add_child(feedback)
	feedback.set_amount(amount)


# Updates the generation progress bar.
func _process(_delta: float) -> void:
	if social_battery_timer.wait_time > 0:
		generation_progress_bar.value = (
			1.0 - social_battery_timer.time_left / social_battery_timer.wait_time
		) * 100.0


func _on_social_battery_timer_timeout() -> void:
	generate()
