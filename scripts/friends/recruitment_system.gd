extends Node


# Recruitment System
#
# This system is responsible for recruiting and managing friends.
#
# Recruitment does NOT directly modify Social Battery.
# It uses SocialBatterySystem to check and spend Social Battery.

# Friend scene used as the template for every recruited friend.
const FRIEND_SCENE = preload("res://scenes/friends/friend.tscn")

# Stores all FriendData resources in the FriendCollection.
var available_friends: Array[FriendData] = []

# Stores all currently recruited FriendNode instances.
var friends: Array[FriendNode] = []

# Stores the buy buttons for each friend.
var recruit_buttons: Dictionary = {}


# Reference to the Friend Collection.
@export var friend_collection: FriendCollection

# Reference to the Social Battery system.
@onready var social_battery_system = get_node("../SocialBatterySystem")

@onready var qte_manager = get_node("../FriendQTEManager")

# Reference to the recruitment list.
@onready var recruitment_list: VBoxContainer = $"../../UI/FriendsPanel/VBoxContainer/RecruitmentList"


func _ready() -> void:
	load_friend_data()
	social_battery_system.social_battery_changed.connect(update_recruit_buttons)
	create_recruitment_list()
	update_recruit_buttons()


# Loads all FriendData resources from the FriendCollection.
func load_friend_data() -> void:
	available_friends.clear()

	if friend_collection == null:
		push_error("FriendCollection is not assigned!")
		return

	for friend_data in friend_collection.friends:
		available_friends.append(friend_data)


# Creates a recruitment entry for every friend.
func create_recruitment_list() -> void:
	for friend_data in available_friends:
		var container := HBoxContainer.new()
		var name_label := Label.new()
		var buy_button := Button.new()

		name_label.text = friend_data.friend_name

		# A friend who has already been bought is marked as OWNED.
		if friend_data.unlocked:
			buy_button.text = "OWNED"
			buy_button.disabled = true
		else:
			buy_button.text = "Buy (" + str(friend_data.recruitment_cost) + " SB)"

		container.add_child(name_label)
		container.add_child(buy_button)

		recruitment_list.add_child(container)

		# Only connect the button if the friend has not been bought.
		if not friend_data.unlocked:
			buy_button.pressed.connect(
				_on_buy_friend_pressed.bind(friend_data)
			)

		recruit_buttons[friend_data] = buy_button


# Called when a specific friend's Buy button is pressed.
func _on_buy_friend_pressed(friend_data: FriendData) -> void:
	var friend_instance := recruit_friend(friend_data)

	if friend_instance == null:
		return

	# Mark the friend as bought.
	friend_data.unlocked = true

	# Change the button from BUY to OWNED.
	if recruit_buttons.has(friend_data):
		var button: Button = recruit_buttons[friend_data]
		button.text = "OWNED"
		button.disabled = true

	update_recruit_buttons()


# Checks whether the player can currently recruit a specific friend.
func can_recruit(friend_data: FriendData) -> bool:
	if friend_data == null:
		return false

	# Already bought friends cannot be bought again.
	if friend_data.unlocked:
		return false

	return social_battery_system.can_afford(
		friend_data.recruitment_cost
	)


# Attempts to recruit a specific friend.
#
# Returns the newly created FriendNode if successful.
# Returns null if the player cannot afford the recruitment
# or the friend has already been bought.
func recruit_friend(friend_data: FriendData) -> FriendNode:
	if friend_data == null:
		return null

	# Prevent buying the same friend twice.
	if friend_data.unlocked:
		return null

	# Attempt to spend the recruitment cost.
	if not social_battery_system.spend(friend_data.recruitment_cost):
		return null

	# Create the FriendNode.
	var friend_instance: FriendNode = FRIEND_SCENE.instantiate()

	friend_instance.setup(friend_data)

	# Connect this friend's QTE signal to the manager.
	if qte_manager:
		friend_instance.request_friend_qte.connect(
			qte_manager._on_friend_request_qte
		)

	# Store the recruited friend.
	friends.append(friend_instance)

	return friend_instance


# Updates whether each friend's Buy button can currently be pressed.
func update_recruit_buttons() -> void:
	for friend_data in recruit_buttons:
		var button: Button = recruit_buttons[friend_data]

		if friend_data.unlocked:
			button.text = "OWNED"
			button.disabled = true
		else:
			button.text = "Buy (" + str(friend_data.recruitment_cost) + " SB)"
			button.disabled = not can_recruit(friend_data)


# Utils
func get_friends_amount() -> int:
	return friends.size()
