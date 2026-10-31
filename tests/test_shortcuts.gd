extends SceneTree

# Headless check for the S / F shortcuts and their fading hint. Run:
#   /Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script tests/test_shortcuts.gd

var failures := 0


func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		printerr("FAIL: " + message)


func press(key: Key) -> void:
	for pressed in [true, false]:
		var ev := InputEventKey.new()
		ev.keycode = key
		ev.physical_keycode = key
		ev.pressed = pressed
		root.push_input(ev)


func _initialize() -> void:
	var main = load("res://scenes/main/main.tscn").instantiate()
	root.add_child(main)
	await process_frame

	var friends: Control = main.get_node("UI/FriendsPanel")
	var shop: Control = main.get_node("UI/StatsShop")
	var queue = main.get_node("Systems/QTEQueueManager")
	var intro = main.get_node("DayIntroCutscene")
	var hint = main.get_node("UI/KeyHint")

	press(KEY_S)
	press(KEY_F)
	check(not shop.visible and not friends.visible, "shortcuts are ignored during the day intro")
	await process_frame
	check(hint.elapsed == 0.0, "hint does not start counting during the intro")

	while is_instance_valid(intro) and intro.is_playing():
		await process_frame

	press(KEY_S)
	check(shop.visible and not friends.visible, "S opens the shop")
	press(KEY_S)
	check(not shop.visible, "S again closes the shop")
	press(KEY_F)
	check(friends.visible and not shop.visible, "F opens the friend list")
	press(KEY_S)
	check(shop.visible and not friends.visible, "S while the friend list is open swaps to the shop")
	press(KEY_F)
	check(friends.visible and not shop.visible, "F while the shop is open swaps to the friend list")
	press(KEY_F)
	check(not friends.visible, "F again closes the friend list")

	queue.active_qte = load("res://scripts/qte/base_qte.gd").new()
	press(KEY_S)
	press(KEY_F)
	check(not shop.visible and not friends.visible, "shortcuts are ignored during a QTE")
	queue.active_qte.free()
	queue.active_qte = null

	var badges: Array = hint.get_children()
	check(badges.size() == 2 and badges.all(func(b): return b.visible), "hint shows an S and an F badge")
	hint.elapsed = 0.0
	hint.advance(58.0)
	check(hint.modulate.a == 1.0, "hint is fully visible through the first minute")
	hint.advance(3.0)
	check(hint.modulate.a < 1.0 and hint.modulate.a > 0.0, "hint fades after one minute")
	hint.advance(10.0)
	check(not hint.visible, "hint is gone once the fade ends")

	quit(1 if failures > 0 else 0)
