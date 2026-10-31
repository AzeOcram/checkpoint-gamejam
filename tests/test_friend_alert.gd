extends SceneTree

# Headless check for friend QTE alerts. Run:
#   /Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script tests/test_friend_alert.gd

var failures := 0


func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		printerr("FAIL: " + message)


# Untyped on purpose: naming script classes here compiles them before the autoloads exist.
func map_node_for(map: Node, data: FriendData):
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
	var panel = map.friend_info_panel

	var a: FriendData = recruitment.available_friends[0]
	var b: FriendData = recruitment.available_friends[1]
	a.mood = 50
	a.connection = 50
	var node_a = recruitment._complete_recruitment(a)
	var node_b = recruitment._complete_recruitment(b)
	await process_frame
	node_a.check_timer.stop()
	node_b.check_timer.stop()

	var seat_a = map_node_for(map, a)
	var seat_b = map_node_for(map, b)

	node_a.request_friend_qte.emit(node_a)
	check(queue.active_qte == null and queue.qte_queue.is_empty(), "a request alone starts no QTE")
	check(manager.has_alert(a), "a request opens an alert")
	check(is_equal_approx(manager.alert_time_left(a), 10.0), "alert lasts 10 seconds")
	check(seat_a.alert_label.visible, "alert shows over the friend's seat")
	check(not seat_b.alert_label.visible, "other seats show no alert")

	node_b.request_friend_qte.emit(node_b)
	manager.tick_alerts(4.0)
	check(manager.has_alert(a) and manager.has_alert(b), "alerts run concurrently")
	check(is_equal_approx(manager.alert_time_left(a), 6.0), "alert counts down")
	check(seat_a.alert_label.text.ends_with("6"), "label shows the seconds left")

	seat_a.texture_button.pressed.emit()
	check(not panel.visible, "clicking an alerted friend does not open the info panel")
	check(not manager.has_alert(a), "clicking clears that friend's alert")
	check(not seat_a.alert_label.visible, "clicking hides the label")
	check(manager.has_alert(b), "other alert keeps running")
	check(queue.active_qte != null and queue.active_qte.friend_data == a, "clicking starts that friend's QTE")

	var mood_before: int = b.mood
	var connection_before: int = b.connection
	manager.tick_alerts(10.0)
	check(not manager.has_alert(b), "an expired alert closes")
	check(b.mood < mood_before or mood_before == 0, "expiry lowers mood like a failed QTE")
	check(b.connection <= connection_before, "expiry never raises connection")
	check(not seat_b.alert_label.visible, "expired label hides")
	check(not node_b.check_timer.is_stopped(), "expiry restarts the friend's timer")

	seat_b.texture_button.pressed.emit()
	check(panel.visible, "an unalerted friend still opens the info panel")

	quit(1 if failures > 0 else 0)
