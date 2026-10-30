extends Node

signal tapped(position: Vector2)

@onready var qte_queue_manager: QTEQueueManager = get_node("../QTEQueueManager")


# Code for game inputs
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("tap") and _tap_allowed(event):
		var tap_position := Vector2.ZERO

		if event is InputEventMouseButton:
			tap_position = event.position

		tapped.emit(tap_position)


# Taps give no energy during a QTE, while a "blocks_tap" popup is visible,
# or when the click lands on a button.
func _tap_allowed(event: InputEvent) -> bool:
	if is_instance_valid(qte_queue_manager.active_qte):
		return false

	for popup in get_tree().get_nodes_in_group(&"blocks_tap"):
		if popup.is_visible_in_tree():
			return false

	if event is InputEventMouseButton:
		return not get_viewport().gui_get_hovered_control() is BaseButton

	return true
