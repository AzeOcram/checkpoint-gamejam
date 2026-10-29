
extends Node
class_name FriendQTEManager


const FRIEND_QTE_SCENE = preload("res://scenes/qte/friend_qte.tscn")
signal qte_finished


@onready var qte_queue_manager: QTEQueueManager = get_node("../QTEQueueManager")


func _on_friend_request_qte(friend_node: FriendNode) -> void:
	print("========== QUEUING FRIEND QTE ==========")
	print("Friend: ", friend_node.data.friend_name)

	# Prevent another request from this friend while waiting.
	friend_node.pause_monitoring()

	var qte_data := QTEData.new()

	qte_data.title = friend_node.data.friend_name + " NEEDS YOU"
	qte_data.description = "Respond quickly to help them!"
	qte_data.duration = 5.0

	qte_queue_manager.enqueue_qte(
		FRIEND_QTE_SCENE,
		qte_data,
		_on_qte_finished.bind(friend_node),
		friend_node.data
	)


func _on_qte_finished(
	result: QTEData.Result,
	friend_node: FriendNode
) -> void:
	if not is_instance_valid(friend_node):
		return

	if result == QTEData.Result.SUCCESS:
		friend_node.data.mood = min(
			friend_node.data.mood + friend_node.data.mood_decrease_rate,
			100
		)

		friend_node.data.connection = min(
			friend_node.data.connection + friend_node.data.connection_gain,
			100
		)

		print(friend_node.data.friend_name, " QTE SUCCESS!")

	else:
		friend_node.data.mood = max(
			friend_node.data.mood - friend_node.data.mood_decrease_rate,
			0
		)

		friend_node.data.connection = max(
			friend_node.data.connection - friend_node.data.connection_gain,
			0
		)

		print(friend_node.data.friend_name, " QTE FAILED!")

	friend_node.resume_monitoring()
	qte_finished.emit()