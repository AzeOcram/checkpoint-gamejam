extends Control
class_name FriendNode


signal request_friend_qte(friend_node: Node)


@onready var check_timer: Timer = $MoodCheckTimer


var data: FriendData


func _ready() -> void:
	check_timer.timeout.connect(_on_mood_check_timer_timeout)

	if data != null:
		start_mood_timer()


func setup(friend_data: FriendData) -> void:
	data = friend_data

	if is_node_ready():
		start_mood_timer()


func start_mood_timer() -> void:
	check_timer.wait_time = randf_range(
		data.friend_qte_timer_min,
		data.friend_qte_timer_max
	)

	print(
		data.friend_name,
		" mood timer started: ",
		check_timer.wait_time,
		" sec | decrease rate: ",
		data.mood_decrease_rate
	)

	check_timer.start()


func _on_mood_check_timer_timeout() -> void:
	if data == null:
		return

	print(
		data.friend_name,
		" mood timer fired! Random check..."
	)

	var roll := randf()

	print(
		"Roll: ",
		roll,
		" <= ",
		data.mood_decrease_rate,
		" ?"
	)

	if roll <= data.mood_decrease_rate:
		trigger_mood_decrease()
	else:
		print("No QTE this cycle.")
		start_mood_timer()


func trigger_mood_decrease() -> void:
	print("========== FRIEND QTE TRIGGERED ==========")
	print("Friend: ", data.friend_name)

	check_timer.stop()

	print("Emitting request_friend_qte...")
	request_friend_qte.emit(self)


func resume_monitoring() -> void:
	start_mood_timer()
