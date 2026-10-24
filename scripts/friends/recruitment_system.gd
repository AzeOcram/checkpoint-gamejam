extends Node


# Recruitment System
#
# This system is responsible for recruiting and managing friends.
#
# Recruitment does NOT directly modify Social Battery.
# It uses SocialBatterySystem to check and spend Social Battery.


signal friend_recruited(friend_node: FriendNode)


# Friend scene used as the template for every recruited friend.
const FRIEND_SCENE = preload("res://scenes/friends/friend.tscn")


# Stores all FriendData resources.
# This includes both recruited and unrecruited friends.
var available_friends: Array[FriendData] = []

# Stores all currently recruited FriendNode instances.
var friends: Array[FriendNode] = []


# Reference to the Social Battery system.
@onready var social_battery_system = get_node("../SocialBatterySystem")

@onready var qte_manager = get_node("../FriendQTEManager")


func _ready() -> void:
	load_friend_data()

	print("========== RECRUITMENT SYSTEM READY ==========")
	print("QTE Manager: ", qte_manager)

	if qte_manager == null:
		push_error("FriendQTEManager NOT FOUND!")


# Loads all FriendData resources from the friends folder.
#
# This means new friends can be added by simply creating
# another .tres file in the folder without changing this script.
func load_friend_data() -> void:
	available_friends.clear()

	var directory := DirAccess.open("res://resources/friends")

	if directory == null:
		push_error("Could not open friends resource folder.")
		return

	for file_name in directory.get_files():
		if file_name.ends_with(".tres"):
			var friend_data = load(
				"res://resources/friends/" + file_name
			) as FriendData

			if friend_data != null:
				available_friends.append(friend_data)


# Checks whether the player can currently recruit a specific friend.
func can_recruit(friend_data: FriendData) -> bool:
	if friend_data == null:
		return false

	if friend_data.unlocked:
		return false

	return social_battery_system.can_afford(
		friend_data.recruitment_cost
	)


# Attempts to recruit a specific friend.
#
# Returns the newly created FriendNode if successful.
# Returns null if the player cannot afford the friend
# or the friend has already been recruited.
func recruit_friend(friend_data: FriendData) -> FriendNode:
	if friend_data == null:
		return null

	# Already recruited.
	if friend_data.unlocked:
		return null

	# Check whether the player can afford this specific friend.
	if not social_battery_system.spend(friend_data.recruitment_cost):
		return null

	# Mark the friend as recruited.
	friend_data.unlocked = true

	var friend_instance: FriendNode = FRIEND_SCENE.instantiate()

# Connect the QTE signal before adding the friend.
	if qte_manager:
		friend_instance.request_friend_qte.connect(
			qte_manager._on_friend_request_qte
		)

	# Add the friend to the scene tree.
	add_child(friend_instance)

	# Now setup() will see that the node is ready.
	friend_instance.setup(friend_data)

	friends.append(friend_instance)

	# Tell other systems that a friend was recruited.
	friend_recruited.emit(friend_instance)

	return friend_instance


# Utils
func get_friends_amount() -> int:
	return friends.size()
