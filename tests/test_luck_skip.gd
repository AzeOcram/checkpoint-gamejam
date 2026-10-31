extends SceneTree

# Headless check: a Luck skip is shown to the player and never swallows most event QTEs. Run:
#   /Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script tests/test_luck_skip.gd

var failures := 0


func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		printerr("FAIL: " + message)


func _initialize() -> void:
	var main = load("res://scenes/main/main.tscn").instantiate()
	root.add_child(main)
	await process_frame

	var stats = main.get_node("Systems/StatsSystem")
	var events = main.get_node("Systems/EventQTESystem")
	var player = root.get_node("Player")

	# Stacked luck (shop + friends) is capped so event QTEs keep appearing.
	player.luck = 0.9
	var skips := 0
	for i in 2000:
		if stats.roll_luck_skip():
			skips += 1
	check(skips > 800 and skips < 1200, "luck 0.9 skips about %d%% of QTEs, got %d / 2000" % [stats.MAX_SKIP_CHANCE * 100, skips])

	# A skip shows the Lucky screen, then pays the success reward and schedules the next QTE.
	player.energy = 0
	player.luck = 0.0
	events.timer.stop()
	events.event_qte_pending = true
	events.skip_qte(events.qte_list[0]["data"])
	await process_frame
	var screens := root.get_children().filter(func(n): return n is QTEStartingScreen)
	check(screens.size() == 1, "a Luck skip shows the Lucky screen")
	check(events.event_qte_pending, "the event stays pending while the Lucky screen shows")
	await screens[0].tree_exited
	check(player.energy > 0, "the skip still pays the success reward")
	check(not events.event_qte_pending and not events.timer.is_stopped(), "the next event QTE is scheduled after the skip")

	print("test_luck_skip: %d failure(s)" % failures)
	quit(1 if failures > 0 else 0)
