extends SceneTree

# Headless check: Luck skips friend QTEs only (with the Lucky screen) and never event QTEs. Run:
#   /Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script tests/test_luck_skip.gd

var failures := 0


func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		printerr("FAIL: " + message)


func lucky_screens() -> Array:
	return root.get_children().filter(func(n): return n is QTEStartingScreen)


func clear_screens() -> void:
	for screen in lucky_screens():
		screen.free()


func _initialize() -> void:
	var main = load("res://scenes/main/main.tscn").instantiate()
	root.add_child(main)
	await process_frame

	var stats = main.get_node("Systems/StatsSystem")
	var events = main.get_node("Systems/EventQTESystem")
	var manager = main.get_node("Systems/FriendQTEManager")
	var queue = main.get_node("Systems/QTEQueueManager")
	var recruitment = main.get_node("Systems/RecruitmentSystem")
	var player = root.get_node("Player")

	# Stacked luck (shop + friends) is capped.
	player.luck = 0.9
	var skips := 0
	for i in 2000:
		if stats.roll_luck_skip():
			skips += 1
	check(skips > 800 and skips < 1200, "luck 0.9 skips about %d%% of QTEs, got %d / 2000" % [stats.MAX_SKIP_CHANCE * 100, skips])

	# Event QTEs never roll Luck: every one reaches the queue.
	events.timer.stop()
	var skipped_events := 0
	for i in 30:
		events.event_qte_pending = false
		events.spawn_random_qte()
		if queue.active_qte == null and queue.qte_queue.is_empty():
			skipped_events += 1
		if is_instance_valid(queue.active_qte):
			queue.active_qte.free()
		queue.active_qte = null
		queue.qte_queue.clear()
	check(skipped_events == 0, "event QTEs are never skipped by Luck, %d / 30 were" % skipped_events)
	clear_screens()
	events.timer.stop()

	# A friend QTE rolls Luck when it starts.
	var a: FriendData = recruitment.available_friends[0]
	a.mood = 50
	a.connection = 50
	var node_a = recruitment._complete_recruitment(a)
	await process_frame
	node_a.check_timer.stop()
	var lucky := 0
	for i in 40:
		node_a.request_friend_qte.emit(node_a)
		manager.start_qte(a)
		if is_instance_valid(queue.active_qte):
			queue.active_qte.free()
		queue.active_qte = null
		queue.qte_queue.clear()
		manager.open_qtes.erase(a)
		node_a.check_timer.stop()
	lucky = lucky_screens().size()
	check(lucky > 0, "a friend QTE shows the Lucky screen when Luck skips it")
	clear_screens()

	# A skipped friend QTE keeps the warning up, then pays the success reward.
	player.luck = 0.0
	a.connection = 50
	manager.alert_nodes[a] = node_a
	manager.open_qtes[a] = true
	manager.skip_qte(a, node_a)
	await process_frame
	var screens := lucky_screens()
	check(screens.size() == 1, "skip_qte shows one Lucky screen")
	check(manager.warning_active(), "the friend warning stays up while the Lucky screen shows")
	await screens[0].tree_exited
	check(a.connection > 50, "the skip pays the friend's connection gain")
	check(not manager.warning_active(), "the warning clears after the skip")

	print("test_luck_skip: %d failure(s)" % failures)
	quit(1 if failures > 0 else 0)
