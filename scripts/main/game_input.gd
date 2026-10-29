extends Node

signal tapped(position: Vector2)

@onready var qte_queue_manager: QTEQueueManager = get_node("../QTEQueueManager")

# Code for game inputs
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if is_instance_valid(qte_queue_manager.active_qte):
			return

	if event.is_action_pressed("tap"):
		var tap_position := Vector2.ZERO

		if event is InputEventMouseButton:
			tap_position = event.position

		tapped.emit(tap_position)
