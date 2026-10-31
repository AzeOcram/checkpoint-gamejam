extends SceneTree

# Headless check: friend QTE countdown comes from FriendData.duration, frequency from friend_qte_timer_min/max. Run:
#   /Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script tests/test_friend_qte_timing.gd

var failures := 0


func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		printerr("FAIL: " + message)


func _initialize() -> void:
	var main = load("res://scenes/main/main.tscn").instantiate()
	root.add_child(main)
	await process_frame

	var recruitment = main.get_node("Systems/RecruitmentSystem")
	var manager = main.get_node("Systems/FriendQTEManager")
	var queue = main.get_node("Systems/QTEQueueManager")

	var a: FriendData = recruitment.available_friends[0]
	var b: FriendData = recruitment.available_friends[1]
	a.duration = 7.0
	a.friend_qte_timer_min = 100.0
	a.friend_qte_timer_max = 140.0
	b.duration = 3.0
	b.friend_qte_timer_min = 20.0
	b.friend_qte_timer_max = 40.0
	var node_a = recruitment._complete_recruitment(a)
	var node_b = recruitment._complete_recruitment(b)

	for node in [node_a, node_b]:
		node.request_friend_qte.emit(node)
	manager.start_qte(a)
	check(queue.active_qte != null and is_equal_approx(queue.active_qte.time_remaining, 7.0), "friend QTE counts down from the friend's duration, not the 100-140 frequency range")
	queue.active_qte.finished.emit(0)
	await process_frame

	manager.start_qte(b)
	check(queue.active_qte != null and is_equal_approx(queue.active_qte.time_remaining, 3.0), "a different duration is used for a different friend")
	queue.active_qte.finished.emit(0)

	var within := true
	for i in 200:
		node_b.start_mood_timer()
		within = within and node_b.check_timer.wait_time >= 20.0 and node_b.check_timer.wait_time <= 40.0
	check(within, "QTE frequency is rolled between friend_qte_timer_min and friend_qte_timer_max")

	manager.apply_friend_crisis(a)
	check(is_equal_approx(b.friend_qte_timer_min, 15.0) and is_equal_approx(b.friend_qte_timer_max, 35.0), "a friend crisis shifts the frequency range down by 5s")

	quit(1 if failures > 0 else 0)
