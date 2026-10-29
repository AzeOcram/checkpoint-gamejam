extends Node
class_name EventQTESystem


# This is set in the Main scene
@export var recruitment_system: Node


@onready var timer: Node = $Timer
@onready var stats_system: Node = get_node("../StatsSystem")


var qte_list = QTEList.new().qte_list

var active_qte: BaseQTE = null

# Utils
func friends_amount() -> int:
	return recruitment_system.get_friends_amount()


func play_time() -> float:
	return Player.get_play_time()


func calculate_interval() -> float:
	return 5.0 # TEMP: testing, remove to restore progress-based intervals

	var progress = Player.progress_score
	
	if progress < 0.2:
		return randf_range(21.0, 26.0)
	elif progress < 0.4:
		return randf_range(20.0, 24.0)
	elif progress < 0.6:
		return randf_range(17.0, 20.0)
	elif progress < 0.8:
		return randf_range(12.0, 16.0)
	else:
		return randf_range(7.0, 11.0)


# Start the cycle
func _ready() -> void:
	print("========== EVENT QTE SYSTEM READY ==========")
	set_next_qte_cycle()


# Update player progress score and start timer with new interval
func set_next_qte_cycle() -> void:
	print("set_next_qte_cycle() called")
	
	if active_qte != null:
		print("QTE cycle blocked: active_qte already exists")
		return
	
	update_progress()
	
	print("Player progress score: ", Player.progress_score)
	print("Calculated QTE interval: ", calculate_interval())
	print("Starting QTE timer...")
	
	timer.start(calculate_interval())
	
	print("Timer started. Timer time_left: ", timer.time_left)


func _on_timer_timeout() -> void:
	print("========== EVENT QTE TIMER FIRED ==========")
	spawn_random_qte()


# Currently directly updating player's fields
func update_progress() -> void:
	print("update_progress() called")
	
	if not Player or not recruitment_system:
		print("Progress update aborted!")
		print("Player exists: ", Player != null)
		print("Recruitment system exists: ", recruitment_system != null)
		return
		
	var play_time_factor = min(play_time() / 20.0, 1.0) * 0.6
	var friends_factor = min(float(friends_amount()) / 10.0, 1.0) * 0.4
	
	print("Play time factor: ", play_time_factor)
	print("Friends factor: ", friends_factor)
	
	Player.progress_score = clamp(play_time_factor + friends_factor, 0.0, 1.0)
	
	print("Updated progress score: ", Player.progress_score)


# Spawn a random QTE
func spawn_random_qte() -> void:
	print("spawn_random_qte() called")
	
	if active_qte != null:
		print("QTE spawn blocked: active_qte already exists")
		return
	
	if qte_list.is_empty():
		print("No QTEs available!")
		set_next_qte_cycle()
		return
	
	var qte_entry = qte_list.pick_random()
	
	var qte_scene: PackedScene = qte_entry["scene"]
	var qte_data: QTEData = qte_entry["data"]
	
	print("Selected QTE: ", qte_data.title)
	
	# Reserve the slot so the timer can't spawn a second QTE during the intro.
	active_qte = qte_scene.instantiate()

	var intro := QTEStartingScreen.new_screen()
	get_tree().root.add_child(intro)
	# Luck skips random event QTEs only; friend-request QTEs never roll.
	var lucky: bool = stats_system.roll_luck_skip()
	await intro.play(qte_data, lucky)

	if lucky:
		active_qte.queue_free()
		active_qte = null
		on_qte_finish(QTEData.Result.SUCCESS)
		return

	print("QTE instantiated")
	
	active_qte.finished.connect(on_qte_finish)
	print("Connected QTE finished signal")
	
	get_tree().root.add_child(active_qte)
	print("QTE added to scene tree")
	
	active_qte.start(qte_data)
	print("QTE started")


# Connects to BaseQTE's finished signal
func on_qte_finish(result: QTEData.Result) -> void:
	print("========== EVENT QTE FINISHED ==========")
	print("QTE result: ", result)
	
	if result == QTEData.Result.SUCCESS:
		# Grant energy
		var energy_reward = lerp(20, 50, Player.progress_score)
		Player.energy += energy_reward
		
		print("QTE SUCCESS - Energy gained: ", energy_reward)
	else:
		# Deduct HP
		Player.take_damage(1)
		
		print("QTE FAILURE - HP lost. Current HP: ", Player.hp)
		
	active_qte = null
	print("Active QTE cleared")
	
	set_next_qte_cycle()
