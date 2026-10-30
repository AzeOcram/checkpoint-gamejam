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
	var cards: VBoxContainer = panel.get_node("VBoxContainer/ScrollContainer/FriendList")

	check(not panel.visible, "friend list starts hidden")
	button.pressed.emit()
	check(panel.visible, "friend list button opens the screen")
	button.pressed.emit()
	check(not panel.visible, "friend list button closes the screen")

	var data: FriendData = recruitment.available_friends[0]
	data.mood = 40
	data.connection = 25
	data.social_battery_generation = 4
	recruitment._complete_recruitment(data)
	await process_frame

	check(cards.get_child_count() == 1, "recruiting adds one friend card")
	var card: FriendCard = cards.get_child(0)
	check(card.name_label.text == data.friend_name.get_slice(" ", 0), "card shows first name only")
	check(card.mood_bar.value == 40, "mood bar reflects mood")
	check(card.connection_bar.value == 25, "connection bar reflects connection")
	check(card.sb_bar.value == 4, "SB bar reflects SB generation")

	data.mood = 10
	button.pressed.emit()
	await process_frame
	check(card.mood_bar.value == 10, "open screen follows live mood changes")

	quit(1 if failures > 0 else 0)
