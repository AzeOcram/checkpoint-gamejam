extends SceneTree

# Headless check for the persistent friend warning. Run:
#   /Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script tests/test_friend_warning.gd

var failures := 0


func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		printerr("FAIL: " + message)


# Untyped on purpose: naming script classes here compiles them before the autoloads exist.
func seat_for(map: Node, data: FriendData):
	for c in map.get_children():
		if "alert_label" in c and c.data == data:
			return c
	return null


func _initialize() -> void:
	var main = load("res://scenes/main/main.tscn").instantiate()
	root.add_child(main)
	await process_frame

	var recruitment = main.get_node("Systems/RecruitmentSystem")
	var manager = main.get_node("Systems/FriendQTEManager")
	var queue = main.get_node("Systems/QTEQueueManager")
	var map = main.get_node("Map/FriendMap")
	var warning = main.get_node("FriendWarning")
	var banner: Control = warning.banner

	check(not banner.visible, "warning starts hidden")
	check(warning.layer > 0, "warning sits on a layer above the game and every screen")
	check(is_equal_approx(banner.size.y, root.get_visible_rect().size.y * 0.15), "warning takes about 15% of the screen height")

	var a: FriendData = recruitment.available_friends[0]
	var b: FriendData = recruitment.available_friends[1]
	var node_a = recruitment._complete_recruitment(a)
	var node_b = recruitment._complete_recruitment(b)
	node_a.check_timer.stop()
	node_b.check_timer.stop()

	node_a.request_friend_qte.emit(node_a)
	await process_frame
	check(manager.warning_active(), "an open alert is a pending warning")
	check(not banner.visible, "warning stays hidden during the day intro")

	await create_timer(4.5).timeout
	check(banner.visible, "warning shows once the intro is over")

	main.get_node("UI/FriendsPanel").show()
	main.get_node("UI/StatsShop").show()
	await process_frame
	check(banner.visible, "warning stays over the friend list and the shop")
	main.get_node("UI/FriendsPanel").hide()
	main.get_node("UI/StatsShop").hide()

	node_b.request_friend_qte.emit(node_b)
	seat_for(map, a).texture_button.pressed.emit()
	await process_frame
	check(queue.active_qte != null, "clicking starts the friend QTE")
	check(manager.warning_active(), "warning continues while the friend QTE runs")
	await create_timer(0.4).timeout
	check(not banner.visible, "warning is gone while the friend QTE screen is up")

	queue.active_qte.finished.emit(0)
	await create_timer(0.4).timeout
	check(manager.warning_active(), "warning stays while another friend still waits")
	check(banner.visible, "warning stays up until every friend is answered")

	manager.tick_alerts(10.0)
	await create_timer(0.4).timeout
	check(not manager.warning_active(), "no alert and no QTE means no warning")
	check(not banner.visible, "warning hides when the last friend is done")

	quit(1 if failures > 0 else 0)
