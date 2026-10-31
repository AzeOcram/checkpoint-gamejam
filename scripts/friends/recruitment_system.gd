
extends Node

signal friend_recruited(friend_node: FriendNode)

const FRIEND_RECRUITMENT_QTE_SCENE = preload("res://scenes/qte/friend_recruitment_qte.tscn")
const FRIEND_SCENE = preload("res://scenes/friends/friend.tscn")

var available_friends: Array[FriendData] = []
var friends: Array[FriendNode] = []
var recruitment_in_progress: bool = false

@onready var social_battery_system = get_node("../SocialBatterySystem")
@onready var qte_manager = get_node("../FriendQTEManager")
@onready var qte_queue_manager: QTEQueueManager = get_node("../QTEQueueManager")


func _ready() -> void:
	load_friend_data()
	print("========== RECRUITMENT SYSTEM READY ==========")
	print("QTE Manager: ", qte_manager)

	if qte_manager == null:
		push_error("FriendQTEManager NOT FOUND!")


func load_friend_data() -> void:
	available_friends.clear()

	var directory := DirAccess.open("res://resources/friends")

	if directory == null:
		push_error("Could not open friends resource folder.")
		return

	var files = directory.get_files()

	print("========== FRIEND DATA DIAGNOSTICS ==========")
	print("Total files found: ", files.size())

	for file_name in files:
		if file_name.ends_with(".tres"):
			var path = "res://resources/friends/" + file_name
			var resource = load(path)

			if resource == null:
				print("[FAILED TO LOAD] ", file_name)
			elif resource is FriendData:
				available_friends.append(resource)
				print("[LOADED] ", resource.friend_name)
			else:
				print("[WRONG RESOURCE TYPE] ", file_name, " | ", resource.get_class())

	print("=============================================")
	print("Total .tres loaded: ", available_friends.size())

func can_recruit(friend_data: FriendData) -> bool:
	if friend_data == null:
		return false

	if friend_data.unlocked or recruitment_in_progress:
		return false

	return social_battery_system.can_afford(friend_data.recruitment_cost)


func recruit_friend(friend_data: FriendData) -> FriendNode:
	if friend_data == null:
		return null

	if recruitment_in_progress:
		return null

	if not can_recruit(friend_data):
		return null

	recruitment_in_progress = true

	var qte_data := QTEData.new()
	qte_data.description = friend_data.recruitment_question
	qte_data.duration = friend_data.duration

	qte_queue_manager.enqueue_qte(
		FRIEND_RECRUITMENT_QTE_SCENE,
		qte_data,
		_on_recruitment_qte_finished.bind(friend_data),
		friend_data
	)

	return null


func _on_recruitment_qte_finished(result: QTEData.Result, friend_data: FriendData) -> void:
	recruitment_in_progress = false

	if friend_data == null or friend_data.unlocked:
		return

	if not social_battery_system.spend(friend_data.recruitment_cost):
		print("Not enough Social Battery to recruit ", friend_data.friend_name)
		return

	if result == QTEData.Result.FAILURE:
		friend_data.connection = 0
		friend_data.mood = max(
			friend_data.mood - friend_data.mood_decrease_rate,
			0
		)

	_complete_recruitment(friend_data)


func _complete_recruitment(friend_data: FriendData) -> FriendNode:
	friend_data.unlocked = true

	var friend_instance: FriendNode = FRIEND_SCENE.instantiate()

	if qte_manager:
		friend_instance.request_friend_qte.connect(qte_manager._on_friend_request_qte)

	add_child(friend_instance)
	friend_instance.setup(friend_data)

	friends.append(friend_instance)
	friend_recruited.emit(friend_instance)

	print("RECRUITED: ", friend_data.friend_name, " | Initial connection: ", friend_data.connection)

	return friend_instance


func get_friends_amount() -> int:
	return friends.size()
