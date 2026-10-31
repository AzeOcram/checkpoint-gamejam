extends SceneTree

# Headless check: a long friend title stays inside the intro panel. Run:
#   /Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script tests/test_starting_screen.gd

var failures := 0


func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		printerr("FAIL: " + message)


func _initialize() -> void:
	await process_frame
	var data := QTEData.new()
	data.description = "Respond quickly to help them!"

	for title in ["Slice the Paper!", "Jasmine Marie Villanueva NEEDS YOU", "Abigail Linette Castro NEEDS YOU"]:
		data.title = title
		var screen := QTEStartingScreen.new_screen()
		root.add_child(screen)
		await process_frame
		screen.play(data)
		await process_frame
		await process_frame
		var label: Label = screen.title_label
		check(label.size.x <= 208.0 and label.size.y <= 30.0, "'%s' fits the title area, got %s" % [title, label.size])
		screen.free()

	print("test_starting_screen: %d failure(s)" % failures)
	quit(1 if failures > 0 else 0)
