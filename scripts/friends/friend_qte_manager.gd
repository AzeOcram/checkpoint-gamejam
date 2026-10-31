
extends Node
class_name FriendQTEManager


const FRIEND_QTE_SCENE = preload("res://scenes/qte/friend_qte.tscn")
signal qte_finished


@onready var qte_queue_manager: QTEQueueManager = get_node("../QTEQueueManager")
@onready var recruitment_system = $"../RecruitmentSystem"


func _on_friend_request_qte(friend_node: FriendNode) -> void:
	if not is_instance_valid(friend_node):
		return

	# Friends with maximum connection no longer trigger QTEs.
	if friend_node.data.connection >= 100:
		friend_node.pause_monitoring()
		return

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


# Permanently reduces other friends' QTE timers.
func apply_friend_crisis(crisis_friend: FriendData) -> void:
	for friend_node in recruitment_system.friends:
		if not is_instance_valid(friend_node):
			continue

		var friend_data: FriendData = friend_node.data

		# Exclude the friend who triggered the crisis.
		if friend_data == crisis_friend:
			continue

		friend_data.friend_qte_timer_min = maxf(
			0.0,
			friend_data.friend_qte_timer_min - 5.0
		)

		friend_data.friend_qte_timer_max = maxf(
			0.0,
			friend_data.friend_qte_timer_max - 5.0
		)

	print("FRIEND CRISIS! Other friends' timers permanently reduced by 5 seconds.")


# Gives the player the friend's luck bonus upon reaching 100 connection.
func check_luck_reward(friend_data: FriendData) -> void:
	if friend_data.connection < 100: return
	if friend_data.luck_bonus_claimed: return

	Player.luck = minf(Player.luck + friend_data.luck, 0.9)
	friend_data.luck_bonus_claimed = true

	Player.luck_changed.emit()

	print(friend_data.friend_name, " reached 100 connection! Player luck: ", Player.luck * 100, "%")

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

		# Check whether the friend has reached maximum connection.
		check_luck_reward(friend_node.data)

	else:
		# Remember the mood before applying the penalty.
		var previous_mood: int = friend_node.data.mood

		friend_node.data.mood = max(
			friend_node.data.mood - friend_node.data.mood_decrease_rate,
			0
		)

		friend_node.data.connection = max(
			friend_node.data.connection - friend_node.data.connection_gain,
			0
		)

		print(friend_node.data.friend_name, " QTE FAILED!")

		# Trigger a crisis whenever mood newly reaches zero.
		if previous_mood > 0 and friend_node.data.mood == 0:
			print(friend_node.data.friend_name, " triggered a FRIEND CRISIS!")
			apply_friend_crisis(friend_node.data)

	# Stop monitoring if the friend has reached maximum connection.
	if friend_node.data.connection >= 100:
		friend_node.pause_monitoring()
	else:
		friend_node.resume_monitoring()

	qte_finished.emit()
