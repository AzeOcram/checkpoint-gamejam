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

	queue.active_qte.queue_free() # its overlay would swallow the clicks below
	queue.active_qte = null
	await create_timer(4.5).timeout # day intro and camera settle

	# Crowded rows: an alerted friend must stay visible and clickable above the friends behind it.
	for d: FriendData in recruitment.available_friends:
		if not d.unlocked:
			recruitment._complete_recruitment(d).check_timer.stop()
	await process_frame
	panel.hide()
	var clicked := []
	var seats := []
	for c in map.get_children():
		if "alert_label" in c:
			seats.append(c)
			c.friend_clicked.disconnect(map._on_friend_clicked)
			c.friend_clicked.connect(func(n): clicked.append(n))
	var wrong := 0
	var hidden := 0
	for seat in seats:
		var order: int = seat.get_index()
		var ev_node = recruitment.friends[recruitment.friends.map(func(f): return f.data).find(seat.data)]
		ev_node.request_friend_qte.emit(ev_node)
		for other in seats:
			if other != seat and other.z_index >= seat.z_index:
				hidden += 1
		var center: Vector2 = root.get_final_transform() * (seat.texture_button.get_global_transform_with_canvas() * (seat.texture_button.size * Vector2(0.5, 0.85)))
		clicked.clear()
		var hover := InputEventMouseMotion.new()
		hover.position = center
		root.push_input(hover)
		await process_frame
		for pressed in [true, false]:
			var click := InputEventMouseButton.new()
			click.button_index = MOUSE_BUTTON_LEFT
			click.pressed = pressed
			click.position = center
			root.push_input(click)
		if clicked.is_empty() or clicked[0] != seat:
			wrong += 1
		manager.tick_alerts(10.0)
		check(seat.get_index() == order, "%s goes back to its seat order after the alert" % seat.data.friend_name)
	check(hidden == 0, "an alerted seat is drawn above every other seat")
	check(wrong == 0, "clicking an alerted friend reaches that friend (%d of %d went elsewhere)" % [wrong, seats.size()])

	quit(1 if failures > 0 else 0)
