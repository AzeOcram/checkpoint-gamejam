extends Node


# Recruitment System
#
# This system is responsible for recruiting and managing friends.
#
# Recruitment does NOT directly modify Social Battery.
# It uses SocialBatterySystem to check and spend Social Battery.


signal friend_recruited(friend_node: FriendNode)


# Friend scene used as the template for every recruited friend.
const FRIEND_RECRUITMENT_QTE_SCENE = preload(
	"res://scenes/qte/friend_recruitment_qte.tscn"
)
const FRIEND_SCENE = preload("res://scenes/friends/friend.tscn")


# Stores all FriendData resources.
# This includes both recruited and unrecruited friends.
var available_friends: Array[FriendData] = []

# Stores all currently recruited FriendNode instances.
var friends: Array[FriendNode] = []
var recruitment_in_progress: bool = false


# Reference to the Social Battery system.
@onready var social_battery_system = get_node("../SocialBatterySystem")

@onready var qte_manager = get_node("../FriendQTEManager")

@onready var qte_queue_manager: QTEQueueManager = get_node("../QTEQueueManager")


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

# Attempts to recruit a specific friend.
#
# The friend is only recruited after the recruitment QTE finishes.

func recruit_friend(friend_data: FriendData) -> FriendNode:
	if friend_data == null:
		return null

	if recruitment_in_progress:
		return null

	if not can_recruit(friend_data):
		return null

	recruitment_in_progress = true

	var qte_data := QTEData.new()
	qte_data.title = friend_data.recruitment_qte_title
	qte_data.description = friend_data.recruitment_qte_description
	qte_data.duration = friend_data.recruitment_qte_duration

	qte_queue_manager.enqueue_qte(
		FRIEND_RECRUITMENT_QTE_SCENE,
		qte_data,
		_on_recruitment_qte_finished.bind(friend_data)
	)

	# The friend is created after the QTE finishes.
	return null


# Handles the result of the one-time recruitment QTE.
func _on_recruitment_qte_finished(
	result: QTEData.Result,
	friend_data: FriendData
) -> void:
	recruitment_in_progress = false

	if friend_data == null or friend_data.unlocked:
		return

	# Spend Social Battery only after the QTE finishes.
	if not social_battery_system.spend(friend_data.recruitment_cost):
		print("Not enough Social Battery to recruit ", friend_data.friend_name)
		return

	# Set initial connection based on the recruitment QTE result.
	if result == QTEData.Result.SUCCESS:
		friend_data.connection = friend_data.connection_gain
	else:
		friend_data.connection = 0

	# Create and register the recruited friend.
	_complete_recruitment(friend_data)


# Creates the FriendNode after recruitment is accepted.
func _complete_recruitment(friend_data: FriendData) -> FriendNode:
	friend_data.unlocked = true

	var friend_instance: FriendNode = FRIEND_SCENE.instantiate()

	# Connect the normal, random Friend QTE signal.
	if qte_manager:
		friend_instance.request_friend_qte.connect(
			qte_manager._on_friend_request_qte
		)

	add_child(friend_instance)

	friend_instance.setup(friend_data)

	friends.append(friend_instance)

	# Tell other systems that a friend was recruited.
	friend_recruited.emit(friend_instance)

	print(
		"RECRUITED: ",
		friend_data.friend_name,
		" | Initial connection: ",
		friend_data.connection
	)

	return friend_instance


# Utils
func get_friends_amount() -> int:
	return friends.size()
