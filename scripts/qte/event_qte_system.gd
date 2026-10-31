
extends Node
class_name EventQTESystem


# These are set in the Main scene.
@export var recruitment_system: Node
@export var qte_queue_manager: QTEQueueManager


@onready var timer: Timer = $Timer
@onready var stats_system: Node = get_node("../StatsSystem")


var qte_list = QTEList.new().qte_list
var event_qte_pending: bool = false


# Utils
func friends_amount() -> int:
	return recruitment_system.get_friends_amount()


func play_time() -> float:
	return Player.get_play_time()


func calculate_interval() -> float:

	var progress = Player.progress_score

	if progress < 0.2:
		return randf_range(25.0, 28.0)
	elif progress < 0.4:
		return randf_range(18.0, 22.0)
	elif progress < 0.6:
		return randf_range(13.0, 16.0)
	elif progress < 0.8:
		return randf_range(9.0, 12.0)
	else:
		return randf_range(5.0, 8.0)


# Start the cycle
func _ready() -> void:
	print("========== EVENT QTE SYSTEM READY ==========")

	if recruitment_system == null:
		recruitment_system = get_node("../RecruitmentSystem")

	if qte_queue_manager == null:
		push_error("QTEQueueManager is not assigned in EventQTESystem!")
		return

	set_next_qte_cycle()


# Update player progress score and start timer with new interval.
func set_next_qte_cycle() -> void:
	print("set_next_qte_cycle() called")

	if event_qte_pending:
		print("Event QTE cycle blocked: an event is pending.")
		return

	update_progress()

	var interval := calculate_interval()
	print("Calculated QTE interval: ", interval)

	timer.start(interval)


func _on_timer_timeout() -> void:
	print("========== EVENT QTE TIMER FIRED ==========")
	spawn_random_qte()


# Currently directly updating player's fields.
func update_progress() -> void:
	print("update_progress() called")

	if not is_instance_valid(recruitment_system):
		print("Progress update aborted: RecruitmentSystem is missing!")
		return

	var play_time_factor = min(play_time() / 20.0, 1.0) * 0.6
	var friends_factor = min(float(friends_amount()) / 10.0, 1.0) * 0.4

	Player.progress_score = clamp(
		play_time_factor + friends_factor,
		0.0,
		1.0
	)

	print("Updated progress score: ", Player.progress_score)


# Queue a random event QTE.
func spawn_random_qte() -> void:
	print("spawn_random_qte() called")

	if event_qte_pending:
		print("Event QTE request blocked: one is already pending.")
		return

	if qte_queue_manager == null:
		push_error("Cannot queue event QTE: QTEQueueManager is missing!")
		set_next_qte_cycle()
		return

	if qte_list.is_empty():
		print("No QTEs available!")
		set_next_qte_cycle()
		return

	var qte_entry = qte_list.pick_random()

	var qte_scene: PackedScene = qte_entry["scene"]
	var qte_data: QTEData = qte_entry["data"]

	print("Selected QTE: ", qte_data.title)

	# Luck skips random event QTEs only.
	var lucky: bool = stats_system.roll_luck_skip()

	event_qte_pending = true

	if lucky:
		print("Luck activated! Event QTE skipped.")
		skip_qte(qte_data)
		return

	qte_queue_manager.enqueue_qte(
		qte_scene,
		qte_data,
		on_qte_finish,
		null,
		true
	)


# Shows the Lucky screen, then treats the skip as a success without running the QTE.
func skip_qte(qte_data: QTEData) -> void:
	var intro := QTEStartingScreen.new_screen()
	get_tree().root.add_child(intro)
	await intro.play(qte_data, true)
	on_qte_finish(QTEData.Result.SUCCESS)


# Called when the event QTE finishes.
func on_qte_finish(result: QTEData.Result) -> void:
	print("========== EVENT QTE FINISHED ==========")
	print("QTE result: ", result)

	if result == QTEData.Result.SUCCESS:
		var energy_reward = lerp(20.0, 50.0, Player.progress_score)
		Player.energy += energy_reward

		print("QTE SUCCESS - Energy gained: ", energy_reward)
	else:
		Player.take_damage(1)

		print("QTE FAILURE - HP lost. Current HP: ", Player.hp)

	event_qte_pending = false
	print("Event QTE cleared")

	set_next_qte_cycle()
