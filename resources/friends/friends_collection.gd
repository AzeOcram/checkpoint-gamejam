@tool
extends Resource
class_name FriendCollection

@export var friends: Array[FriendData] = []


func update_collection() -> void:
	friends.clear()

	var dir := DirAccess.open("res://resources/friends")

	if dir == null:
		push_error("Could not open friends resource folder.")
		return

	dir.list_dir_begin()

	var file_name := dir.get_next()

	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var path := "res://resources/friends/" + file_name
			var friend_data := load(path) as FriendData

			if friend_data != null:
				friends.append(friend_data)

		file_name = dir.get_next()

	dir.list_dir_end()

	emit_changed()

	print("Friend collection updated! Found ", friends.size(), " friends.")

func reset_friends() -> void:
	for friend_data in friends:
		friend_data.unlocked = false
		friend_data.mood = 100
		friend_data.connection = 0
		friend_data.luck_bonus_claimed = false

	emit_changed()
