extends SceneTree

# Headless check for StatsSystem. Run:
#   /Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script tests/test_stats_system.gd

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
	var energy = main.get_node("Systems/EnergySystem")
	var player = root.get_node("Player")

	# Starting values from the issue.
	check(player.energy_per_tap == 1, "energy_per_tap starts at 1")
	check(player.luck == 0, "luck starts at 0")
	check(player.max_hp == 3, "max_hp starts at 3")
	check(stats.get_level("luck") == 0, "luck level starts at 0")

	# Cost grows with the stat's own level; stats are independent.
	check(stats.get_cost("energy_per_tap") == 10, "energy_per_tap first cost is base cost 10")
	check(stats.get_cost("luck") == 25, "luck first cost is base cost 25")
	check(stats.get_cost("max_hp") == 50, "max_hp first cost is base cost 50")

	# Not enough energy: rejected, nothing changes.
	check(not stats.upgrade("energy_per_tap"), "upgrade rejected without energy")
	check(player.energy_per_tap == 1, "stat unchanged after rejection")

	# Enough energy: deducts and increases.
	energy.add(100)
	check(stats.upgrade("energy_per_tap"), "upgrade succeeds with energy")
	check(player.energy_per_tap == 2, "energy_per_tap 1 -> 2")
	check(energy.get_amount() == 90, "10 energy deducted")
	check(stats.get_cost("energy_per_tap") == 20, "cost rises with level")
	check(stats.get_cost("luck") == 25, "other stats' cost unaffected")

	# Max HP raises current HP too.
	energy.add(1000)
	check(stats.upgrade("max_hp"), "max_hp upgrade succeeds")
	check(player.max_hp == 4 and player.hp == 4, "max_hp and hp both rise")

	# Luck caps at 10 and refuses further upgrades without spending.
	energy.add(100000)
	for i in 10:
		check(stats.upgrade("luck"), "luck upgrade %d succeeds" % (i + 1))
	check(player.luck == 10, "luck reaches 10")
	check(stats.is_maxed("luck"), "luck is maxed")
	var before: int = energy.get_amount()
	check(not stats.upgrade("luck"), "luck upgrade refused at max")
	check(player.luck == 10, "luck never exceeds 10")
	check(energy.get_amount() == before, "no energy spent at max")

	# Luck chance is 1% per point; roll is deterministic when injected.
	check(is_equal_approx(stats.get_luck_chance(), 0.10), "luck 10 -> 10% skip chance")
	check(stats.roll_luck_skip(0.05), "roll below chance skips")
	check(not stats.roll_luck_skip(0.10), "roll at chance does not skip")
	player.luck = 0
	check(not stats.roll_luck_skip(0.0), "luck 0 never skips")
	player.luck = 10

	# Every stat reaches its cap and no further.
	while stats.upgrade("energy_per_tap"):
		pass
	check(stats.is_maxed("energy_per_tap"), "energy_per_tap maxes out")
	while stats.upgrade("max_hp"):
		pass
	check(stats.is_maxed("max_hp"), "max_hp maxes out")

	# Shop UI: opens, shows cost, buying refreshes label and Stats panel text.
	var shop = main.get_node("StatsShop")
	shop.get_node("ToggleButton").pressed.emit()
	check(shop.get_node("ShopPanel").visible, "shop opens")
	player.luck = 0
	player.energy = 0
	stats.stats_changed.emit()
	var luck_button: Button = shop._rows["luck"].button
	check(luck_button.disabled, "luck button disabled without energy")
	energy.add(25)
	check(not luck_button.disabled, "luck button enabled when affordable")
	luck_button.pressed.emit()
	check(player.luck == 1, "shop button buys luck")
	check(shop._rows["luck"].label.text == "Luck: 1 (Lv 1)", "shop label refreshes")
	check(main.get_node("UI/StatsPanel/VBoxContainer/LuckLabel").text == "Luck: 1", "stats panel refreshes")

	print("stats tests: %s" % ("PASS" if failures == 0 else "%d FAILED" % failures))
	quit(failures)
