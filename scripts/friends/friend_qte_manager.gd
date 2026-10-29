extends Node
class_name FriendQTEManager


const FRIEND_QTE_SCENE = preload("res://scenes/qte/friend_qte.tscn")


func _on_friend_request_qte(friend_node: FriendNode) -> void:
	print("========== SPAWNING FRIEND QTE ==========")
	print("Friend: ", friend_node.data.friend_name)

	var qte_instance := FRIEND_QTE_SCENE.instantiate() as FriendQTE

	if qte_instance == null:
		push_error("friend_qte.tscn does not contain a FriendQTE!")
		return

	get_tree().paused = true
	get_tree().root.add_child(qte_instance)

	qte_instance.finished.connect(
		_on_qte_finished.bind(friend_node)
	)

	var qte_data := QTEData.new()

	qte_data.title = friend_node.data.friend_name + " NEEDS YOU"
	qte_data.description = "Respond quickly to help them!"
	qte_data.duration = 5.0

	qte_instance.start(qte_data)


func _on_qte_finished(
	result: QTEData.Result,
	friend_node: FriendNode
) -> void:

	get_tree().paused = false

	if result == QTEData.Result.SUCCESS:
		friend_node.data.mood = min(
			friend_node.data.mood + 1,
			100
		)

		friend_node.data.connection = min(
			friend_node.data.connection + 1,
			100
		)

		print(
			friend_node.data.friend_name,
			" QTE SUCCESS!"
		)

	else:
		friend_node.data.connection = max(
			friend_node.data.connection - 1,
			0
		)

		print(
			friend_node.data.friend_name,
			" QTE FAILED!"
		)

	friend_node.resume_monitoring()
