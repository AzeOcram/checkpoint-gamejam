extends Control


const ENERGY_FEEDBACK = preload("res://scenes/energy/energy_feedback.tscn")

@onready var energy_label: Label = $EnergyLabel
@onready var feedback_container: Control = $EnergyFeedbackLayer/FeedbackContainer


func _ready() -> void:
	update_energy_ui()


func _on_tapped(position: Vector2) -> void:
	Player.add_energy(Player.get_energy_per_tap())
	update_energy_ui()
	spawn_energy_feedback(position)


func update_energy_ui() -> void:
	energy_label.text = "Energy: " + str(Player.get_energy())


func spawn_energy_feedback(position: Vector2) -> void:
	var feedback = ENERGY_FEEDBACK.instantiate()

	feedback.position = position
	feedback_container.add_child(feedback)
