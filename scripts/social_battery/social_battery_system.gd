extends Node

signal social_battery_changed

const SOCIAL_BATTERY_FEEDBACK = preload("res://scenes/social_battery/social_battery_feedback.tscn")

@onready var social_battery_label: Label = $SocialBatteryLabel
@onready var social_battery_timer: Timer = $SocialBatteryTimer
@onready var feedback_container: Control = $SocialBatteryFeedbackLayer/FeedbackContainer
@onready var generation_progress_bar: TextureProgressBar = $GenerationProgressBar


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


# Returns the player's maximum Social Battery.
func get_max() -> int:
	return Player.max_social_battery


# Adds Social Battery to the player.
func add(amount: int) -> void:
	Player.social_battery = min(
		Player.social_battery + amount,
		Player.max_social_battery
	)

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
	social_battery_label.text = "Social Battery: " + str(get_amount()) + "/" + str(get_max())


# Generates Social Battery.
func generate() -> void:
	add(Player.social_battery_per_second)
	spawn_social_battery_feedback()
	generation_progress_bar.value = 0.0


# Spawns the +SB feedback at the right side of the progress bar.
func spawn_social_battery_feedback() -> void:
	var feedback = SOCIAL_BATTERY_FEEDBACK.instantiate()

	feedback.text = "+" + str(Player.social_battery_per_second) + " SB"

	# Position the feedback at the right tip of the progress bar.
	feedback.position = Vector2(
		generation_progress_bar.position.x + generation_progress_bar.size.x,
		generation_progress_bar.position.y
	)

	feedback_container.add_child(feedback)


# Updates the generation progress bar.
func _process(_delta: float) -> void:
	if social_battery_timer.wait_time > 0:
		generation_progress_bar.value = (
			1.0 - social_battery_timer.time_left / social_battery_timer.wait_time
		) * 100.0


func _on_social_battery_timer_timeout() -> void:
	generate()
