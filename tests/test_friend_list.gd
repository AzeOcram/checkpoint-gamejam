extends SceneTree

# Headless check for the friend list screen. Run:
#   /Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script tests/test_friend_list.gd

var failures := 0


func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		printerr("FAIL: " + message)


func card_for(cards: Node, data: FriendData) -> FriendCard:
	for c: FriendCard in cards.get_children():
		if c.data == data:
			return c
	return null


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

	check(cards.get_child_count() == 40, "every friend has a card")
	check(card_for(cards, data).is_locked() == false, "recruited friend's card is unlocked")
	var locked := 0
	for c: FriendCard in cards.get_children():
		if c.is_locked():
			locked += 1
	check(locked == 39, "only the recruited friend is unlocked")
	var sb_order := []
	for c: FriendCard in cards.get_children():
		sb_order.append(c.data.recruitment_cost)
	var sorted_sb := sb_order.duplicate()
	sorted_sb.sort()
	check(sb_order == sorted_sb, "cards sort from cheapest to most expensive")
	var other: FriendCard = null
	for c: FriendCard in cards.get_children():
		if c.is_locked():
			other = c
			break
	check(other.identity.modulate.r < 0.5, "locked card is shaded")
	check(card_for(cards, data).identity.modulate == Color.WHITE, "unlocked card is not shaded")
	check(other.buy_button.text.ends_with(" SB"), "locked card shows the cost")
	var sbs = main.get_node("Systems/SocialBatterySystem")
	var other_data: FriendData = other.data
	var cost: int = other_data.recruitment_cost
	sbs.spend(sbs.get_amount())
	panel.update_ui()
	panel.show()
	await process_frame
	other = card_for(cards, other_data)
	check(other.buy_button.disabled, "buy button disabled when SB is short")
	check(not recruitment.recruitment_in_progress, "no recruitment before buying")
	sbs.add(cost)
	await process_frame
	await process_frame
	check(not other.buy_button.disabled, "buy button enabled when SB is enough")
	other.buy_button.pressed.emit()
	check(recruitment.recruitment_in_progress, "buy button starts recruitment")
	recruitment.recruitment_in_progress = false
	panel.hide()
	check(panel.friend_count_label.text == "Friends: 1/40", "header shows recruited friends out of all friends")
	var card: FriendCard = card_for(cards, data)
	check(card.name_label.text == data.friend_name.get_slice(" ", 0), "card shows first name only")
	check(card.mood_bar.value == 40, "mood bar reflects mood")
	check(card.mood_icon.texture == FriendCard.mood_texture(40), "mood icon reflects mood")
	check(FriendCard.mood_texture(0) != FriendCard.mood_texture(100), "low and high mood use different icons")
	check(FriendCard.mood_texture(24) != FriendCard.mood_texture(25), "mood icon changes at the angry threshold")
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
	check(stats_x.size() == 40 and stats_x.all(func(x): return x == stats_x[0]), "stats line up across short and long names")
	check(card_for(cards, longest).name_label.get_theme_font_size(&"font_size") < FriendCard.NAME_FONT_SIZE, "long name uses a smaller font")
	button.pressed.emit()

	card = card_for(cards, data)
	data.mood = 10
	button.pressed.emit()
	await process_frame
	await process_frame
	check(card.mood_bar.value == 10, "open screen follows live mood changes")

	quit(1 if failures > 0 else 0)
