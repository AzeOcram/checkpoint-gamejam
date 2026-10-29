
extends Node
class_name QTEQueueManager


var qte_queue: Array[Dictionary] = []
var active_qte: BaseQTE = null


# Adds a QTE request to the queue.
func enqueue_qte(
	qte_scene: PackedScene,
	qte_data: QTEData,
	on_finished: Callable = Callable(),
	friend_data: FriendData = null,
	show_intro: bool = false
) -> void:
	if qte_scene == null or qte_data == null:
		push_error("Cannot queue a QTE without a scene and QTEData.")
		return

	qte_queue.append({
		"scene": qte_scene,
		"data": qte_data,
		"callback": on_finished,
		"friend_data": friend_data,
		"show_intro": show_intro
	})

	print("QTE queued. Waiting: ", qte_queue.size())

	_start_next_qte()


# Starts the next QTE only if none is currently active.
func _start_next_qte() -> void:
	if is_instance_valid(active_qte):
		return

	if qte_queue.is_empty():
		return

	var request: Dictionary = qte_queue.pop_front()

	var qte_instance := request["scene"].instantiate() as BaseQTE

	if qte_instance == null:
		push_error("Queued scene does not contain a BaseQTE!")
		call_deferred("_start_next_qte")
		return

	# Reserve the active slot before showing the intro.
	active_qte = qte_instance

	if qte_instance is FriendQTE:
		qte_instance.friend_data = request["friend_data"]

	# Only event QTEs request the intro screen.
	if request["show_intro"]:
		var intro := QTEStartingScreen.new_screen()
		get_tree().root.add_child(intro)
		await intro.play(request["data"])

	# The QTE remains the active one while the intro plays.
	if not is_instance_valid(qte_instance):
		active_qte = null
		call_deferred("_start_next_qte")
		return

	qte_instance.finished.connect(
		_on_active_qte_finished.bind(request["callback"])
	)

	get_tree().root.add_child(qte_instance)
	qte_instance.start(request["data"])

	print("QTE started: ", request["data"].title)


# Called when the active QTE finishes.
func _on_active_qte_finished(
	result: QTEData.Result,
	callback: Callable
) -> void:
	var finished_qte := active_qte
	active_qte = null

	if callback.is_valid():
		callback.call(result)

	if is_instance_valid(finished_qte):
		finished_qte.queue_free()

	call_deferred("_start_next_qte")
