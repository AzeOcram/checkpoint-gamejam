extends SceneTree

# Headless check for the SFX autoload. Run:
#   /Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script tests/test_sfx.gd

var failures := 0


func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		printerr("FAIL: " + message)


func _initialize() -> void:
	var main = load("res://scenes/main/main.tscn").instantiate()
	root.add_child(main)
	await process_frame

	var sfx = root.get_node("SFX")
	var shop_script = load("res://scripts/stats/stats_shop.gd")
	var stats_ids: Array = ["energy_per_tap", "luck", "max_hp"]

	for sound in sfx.OTHER:
		check(sfx._players.has(sound), "%s has a player" % sound)
		check(sfx._players[sound].stream != null, "%s stream loads" % sound)
		sfx.play(sound)

	for stat_id in stats_ids:
		var sounds: Array = shop_script.UPGRADE_SOUNDS[stat_id]
		check(not sounds.is_empty(), "%s has upgrade sounds" % stat_id)
		for sound in sounds:
			check(sfx._players.has(sound), "%s upgrade sound %s exists" % [stat_id, sound])

	sfx.play_random([&"qte_success", &"qte_fail"])

	print("test_sfx: %d failure(s)" % failures)
	quit(1 if failures > 0 else 0)
