extends SceneTree

# Headless check: QTE difficulty follows the friend count (Easy < 5, Moderate < 20, Hard after). Run:
#   /Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script tests/test_difficulty.gd

# Script classes are loaded, not named: naming one compiles it before the autoloads exist.
var failures := 0
var QTEDataS = load("res://resources/qte/qte_data.gd")


func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		printerr("FAIL: " + message)


func _initialize() -> void:
	var main = load("res://scenes/main/main.tscn").instantiate()
	root.add_child(main)
	await process_frame

	var recruitment = main.get_node("Systems/RecruitmentSystem")
	var queue = main.get_node("Systems/QTEQueueManager")
	var qte_list = load("res://resources/qte/qte_list.gd").new().qte_list
	var math_entry: Dictionary = qte_list[1]

	var tiers := {0: QTEDataS.Difficulty.EASY, 4: QTEDataS.Difficulty.EASY, 5: QTEDataS.Difficulty.MODERATE,
		19: QTEDataS.Difficulty.MODERATE, 20: QTEDataS.Difficulty.HARD, 41: QTEDataS.Difficulty.HARD}
	for friends in tiers:
		check(QTEDataS.difficulty_for_friends(friends) == tiers[friends], "%d friends -> tier %d" % [friends, tiers[friends]])

	# The queue gives every QTE the tier for the current friend count.
	for friends in tiers:
		recruitment.friends.clear()
		for i in friends:
			recruitment.friends.append(null)
		queue.enqueue_qte(math_entry["scene"], math_entry["data"])
		check(queue.active_qte != null and queue.active_qte.difficulty == tiers[friends], "%d friends -> a started QTE has tier %d" % [friends, tiers[friends]])
		queue.active_qte.free()
		queue.active_qte = null

	# No friends: math is addition only, never multiplication.
	recruitment.friends.clear()
	queue.enqueue_qte(math_entry["scene"], math_entry["data"])
	var math = queue.active_qte
	var times := 0
	for i in 100:
		math._generate_question()
		if math.question_label.text.contains("×") or math.question_label.text.contains("-"):
			times += 1
	check(times == 0, "0 friends: math has no multiplication or subtraction, got %d / 100" % times)
	math.free()
	queue.active_qte = null

	print("test_difficulty: %d failure(s)" % failures)
	quit(1 if failures > 0 else 0)
