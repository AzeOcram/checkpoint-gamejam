extends SceneTree

# Headless check: Luck skips event QTEs only, and the intro says whether the player was lucky. Run:
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
	var slice_data: QTEData = events.qte_list[0]["data"]

	# Stacked luck (shop + friends) is capped.
	player.luck = 0.9
	var skips := 0
	for i in 2000:
		if stats.roll_luck_skip():
			skips += 1
	check(skips > 800 and skips < 1200, "luck 0.9 skips about %d%% of QTEs, got %d / 2000" % [stats.MAX_SKIP_CHANCE * 100, skips])

	# Friend QTEs never roll Luck: every one reaches the queue and no Lucky screen shows.
	events.timer.stop()
	var a: FriendData = recruitment.available_friends[0]
	a.mood = 50
	a.connection = 50
	var node_a = recruitment._complete_recruitment(a)
	await process_frame
	node_a.check_timer.stop()
	var skipped_friend := 0
	for i in 30:
		node_a.request_friend_qte.emit(node_a)
		manager.start_qte(a)
		if queue.active_qte == null:
			skipped_friend += 1
		else:
			queue.active_qte.free()
		queue.active_qte = null
		queue.qte_queue.clear()
		manager.open_qtes.erase(a)
		node_a.check_timer.stop()
	check(skipped_friend == 0 and lucky_screens().is_empty(), "friend QTEs are never skipped by Luck, %d / 30 were" % skipped_friend)
	clear_screens()

	# An event skip shows the event QTE's own title (no friend name), says Lucky, then pays the reward.
	player.energy = 0
	player.luck = 0.0
	events.timer.stop()
	events.event_qte_pending = true
	events.skip_qte(slice_data)
	await process_frame
	var screens := lucky_screens()
	check(screens.size() == 1, "an event skip shows one Lucky screen")
	var screen: QTEStartingScreen = screens[0]
	check(screen.title_label.text == slice_data.title, "the Lucky screen uses the event QTE's title, got '%s'" % screen.title_label.text)
	check(events.event_qte_pending, "the event stays pending while the Lucky screen shows")
	await screen.tree_exited
	check(player.energy > 0, "the skip pays the success reward")
	check(not events.event_qte_pending and not events.timer.is_stopped(), "the next event QTE is scheduled after the skip")

	# A rolled-but-missed event QTE says so before it starts.
	queue.enqueue_qte(events.qte_list[0]["scene"], slice_data, Callable(), null, true, true)
	await process_frame
	screens = lucky_screens()
	check(screens.size() == 1, "an unlucky event QTE shows its intro")
	var seen := false
	for i in 400:
		if screens[0].description_label.text == QTEStartingScreen.NOT_LUCKY_MESSAGE:
			seen = true
			break
		await process_frame
	check(seen, "the intro says the player was not lucky")

	print("test_luck_skip: %d failure(s)" % failures)
	quit(1 if failures > 0 else 0)
