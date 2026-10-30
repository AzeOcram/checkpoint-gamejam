extends SceneTree

# Headless check for the friend list screen. Run:
#   /Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script tests/test_friend_list.gd

var failures := 0


func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		printerr("FAIL: " + message)


func _initialize() -> void:
	var main = load("res://scenes/main/main.tscn").instantiate()
	root.add_child(main)
	await process_frame

	var panel: PanelContainer = main.get_node("UI/FriendsPanel")
	var button: TextureButton = main.get_node("UI/SocialCircleButton")
	var recruitment = main.get_node("Systems/RecruitmentSystem")
	var cards: GridContainer = panel.get_node("Pad/VBoxContainer/ScrollContainer/FriendList")

	check(not panel.visible, "friend list starts hidden")
	button.pressed.emit()
	check(panel.visible, "friend list button opens the screen")
	button.pressed.emit()
	check(not panel.visible, "friend list button closes the screen")
	button.pressed.emit()
	panel.get_node("Pad/VBoxContainer/Header/HBoxContainer/CloseButton").pressed.emit()
	check(not panel.visible, "close button closes the screen")

	var data: FriendData = recruitment.available_friends[0]
	data.mood = 40
	data.connection = 25
	data.social_battery_generation = 4
	recruitment._complete_recruitment(data)
	await process_frame

	check(cards.get_child_count() == 1, "recruiting adds one friend card")
	check(panel.friend_count_label.text == "Friends: 1/39", "header shows recruited friends out of 39")
	var card: FriendCard = cards.get_child(0)
	check(card.name_label.text == data.friend_name.get_slice(" ", 0), "card shows first name only")
	check(card.mood_bar.value == 40, "mood bar reflects mood")
	check(card.connection_bar.value == 25, "connection bar reflects connection")
	check(card.sb_label.text.ends_with("+4"), "SB label shows the friend's SB generation")

	var battery = main.get_node("Systems/SocialBatterySystem")
	button.pressed.emit()
	await process_frame
	var first: float = card.sb_bar.value
	await create_timer(0.3).timeout
	var second: float = card.sb_bar.value
	check(absf(second - battery.generation_progress_bar.value) < 5.0, "SB bar follows the generation cycle")
	check(second != first, "SB bar moves while the screen is open")
	button.pressed.emit()

	var longest: FriendData = data
	for candidate: FriendData in recruitment.available_friends:
		if candidate.friend_name.get_slice(" ", 0).length() > longest.friend_name.get_slice(" ", 0).length():
			longest = candidate
	recruitment._complete_recruitment(longest)
	button.pressed.emit()
	await process_frame
	await process_frame
	var stats_x := []
	for c: FriendCard in cards.get_children():
		stats_x.append(c.get_node("HBoxContainer/Stats").global_position.x)
	check(stats_x.size() == 2 and stats_x[0] == stats_x[1], "stats line up across short and long names")
	check(cards.get_child(1).name_label.get_theme_font_size(&"font_size") < FriendCard.NAME_FONT_SIZE, "long name uses a smaller font")
	button.pressed.emit()

	card = cards.get_child(0)
	data.mood = 10
	button.pressed.emit()
	await process_frame
	await process_frame
	check(card.mood_bar.value == 10, "open screen follows live mood changes")

	quit(1 if failures > 0 else 0)
