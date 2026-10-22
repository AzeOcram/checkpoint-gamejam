extends Control

signal energy_changed

const ENERGY_FEEDBACK = preload("res://scenes/energy/energy_feedback.tscn")

@onready var energy_label: Label = $EnergyLabel
@onready var feedback_container: Control = $EnergyFeedbackLayer/FeedbackContainer


func _ready() -> void:
	update_energy_ui()


# Energy API
#
# Use these functions for all Energy-related operations.
# The actual Energy value is stored in Player.


# Returns the player's current Energy.
func get_amount() -> int:
	return Player.get_energy()


# Adds Energy to the player.
func add(amount: int) -> void:
	Player.energy += amount
	energy_changed.emit()


# Attempts to spend Energy.
# Returns true if the player had enough Energy.
func spend(amount: int) -> bool:
	if not can_afford(amount):
		return false

	Player.energy -= amount
	update_energy_ui()
	energy_changed.emit()
	return true


# Checks whether the player can afford an amount
# without changing their Energy.
func can_afford(amount: int) -> bool:
	return Player.energy >= amount


func _on_tapped(position: Vector2) -> void:
	add(Player.get_energy_per_tap())
	update_energy_ui()
	spawn_energy_feedback(position)


func update_energy_ui() -> void:
	energy_label.text = "Energy: " + str(get_amount())


func spawn_energy_feedback(position: Vector2) -> void:
	var feedback = ENERGY_FEEDBACK.instantiate()

	feedback.position = position
	feedback_container.add_child(feedback)
