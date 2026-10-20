extends Node


# Recruitment System
#
# This system is responsible for recruiting and managing friends.
#
# Recruitment does NOT directly modify Social Battery.
# It uses SocialBatterySystem to check and spend Social Battery.

# Friend scene used as the template for every recruited friend.
const FRIEND_SCENE = preload("res://scenes/friends/friend.tscn")

# Stores all FriendData resources that are available for recruitment.
var available_friends: Array[FriendData] = []

# Stores all currently recruited FriendNode instances.
var friends: Array[FriendNode] = []


# Reference to the Social Battery system.
@onready var social_battery_system = get_node("../SocialBatterySystem")

# Reference to the Buy Friend button.
@onready var buy_friend_button: Button = $"../../UI/FriendsPanel/VBoxContainer/BuyFriendButton"


func _ready() -> void:
	load_friend_data()
	social_battery_system.social_battery_changed.connect(update_recruit_button)
	update_recruit_button()


# Loads all FriendData resources from the friends folder.
#
# This means new friends can be added by simply creating
# another .tres file in the folder without changing this script.
func load_friend_data() -> void:
	var directory := DirAccess.open("res://resources/friends")

	if directory == null:
		return

	for file_name in directory.get_files():
		if file_name.ends_with(".tres"):
			var friend_data = load(
				"res://resources/friends/" + file_name
			) as FriendData

			if friend_data != null:
				available_friends.append(friend_data)


# Checks whether the player can currently recruit a friend.
func can_recruit() -> bool:
	if available_friends.is_empty():
		return false

	var friend_data: FriendData = available_friends[0]

	return social_battery_system.can_afford(friend_data.recruitment_cost)


# Attempts to recruit a friend.
#
# Returns the newly created FriendNode if successful.
# Returns null if the player cannot afford the recruitment
# or there are no friends left to recruit.
func recruit_friend() -> FriendNode:
	if available_friends.is_empty():
		return null

	var friend_data: FriendData = available_friends[0]

	if not social_battery_system.spend(friend_data.recruitment_cost):
		return null

	available_friends.pop_front()

	var friend_instance: FriendNode = FRIEND_SCENE.instantiate()

	friend_instance.setup(friend_data)

	friends.append(friend_instance)

	return friend_instance


# Updates whether the player can currently recruit a friend.
func update_recruit_button() -> void:
	buy_friend_button.disabled = not can_recruit()
