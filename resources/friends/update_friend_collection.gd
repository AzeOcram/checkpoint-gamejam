@tool
extends EditorScript


func _run() -> void:
	var collection := load("res://resources/friends/collection.tres") as FriendCollection
	
	if collection == null:
		print("Could not load FriendCollection.")
		return
	
	collection.update_collection()
	
	var error := ResourceSaver.save(
		collection,
		"res://resources/friends/collection.tres"
	)
	
	if error == OK:
		print("================================")
		print("Friend collection updated!")
		print("Friends found: ", collection.friends.size())
		print("================================")
	else:
		print("Failed to save FriendCollection. Error: ", error)
