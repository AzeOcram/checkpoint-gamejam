extends Node

# NOTE: This is the API you will need to call for all
# Social Battery related shitt.
#
# The actual Social Battery value is stored in Player.
# This system is responsible for Social Battery mechanics.
@onready var social_battery_label: Label = $SocialBatteryLabel
@onready var social_battery_timer: Timer = $SocialBatteryTimer

func _ready() -> void:
	update_social_battery_ui()

# Returns the player's current Social Battery.
func get_amount() -> int:
	return Player.get_social_battery()
	
func get_max() -> int:
	return Player.get_max_social_battery()


# Adds Social Battery to the player.
func add(amount: int) -> void:
	Player.add_social_battery(amount)
	update_social_battery_ui()


# Attempts to spend Social Battery.
# Returns true if the player had enough.
func spend(amount: int) -> bool:
	if not can_afford(amount):
		return false

	Player.social_battery -= amount
	update_social_battery_ui()
	return true


# Checks whether the player can afford an amount
# without changing their Social Battery.
func can_afford(amount: int) -> bool:
	return Player.get_social_battery() >= amount

# Updates the Social Battery UI. #NOTE: Update this function as well
func update_social_battery_ui() -> void:
	social_battery_label.text = "Social Battery: " + str(get_amount()) + "/" + str(get_max())

# TODO:
# Implement Social Battery generation here.
#
# The generation system should eventually calculate
# how much Social Battery is generated and call:
#
# add(amount)
#
# Do not directly modify Player.social_battery
# from the generation implementation.
func generate() -> void:
	if (get_amount() <= get_max()):
		add(Player.get_social_battery_per_second())


func _on_social_battery_timer_timeout() -> void:
	generate()
