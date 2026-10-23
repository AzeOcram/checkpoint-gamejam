extends Node
class_name FriendQTEManager

@export var base_qte_scene: PackedScene

func _on_friend_request_qte(friend_node: Node) -> void:
	var qte_instance = base_qte_scene.instantiate() as BaseQTE
	add_child(qte_instance)
	
	qte_instance.finished.connect(_on_qte_finished.bind(friend_node))
	
	var qte_data := QTEData.new()
	# Changed friend_data to data here:
	qte_data.title = friend_node.data.friend_name + " NEEDS YOU"
	qte_data.description = "Respond quickly to help them!"
	qte_data.duration = 5.0 
	
	qte_instance.start(qte_data)


func _on_qte_finished(result: QTEData.Result, friend_node: Node) -> void:
	if result == QTEData.Result.SUCCESS:
		friend_node.data.mood += 1
		friend_node.data.connection += 1
		print(friend_node.data.friend_name + " QTE SUCCESS! New Mood: ", friend_node.data.mood, " | New Connection: ", friend_node.data.connection)
		
	elif result == QTEData.Result.FAILURE:
		friend_node.data.connection -= 1
		print(friend_node.data.friend_name + " QTE FAILED! New Mood: ", friend_node.data.mood, " | New Connection: ", friend_node.data.connection)
	
	friend_node.resume_monitoring()
