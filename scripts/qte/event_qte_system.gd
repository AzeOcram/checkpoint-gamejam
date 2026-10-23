extends Node
class_name EventQTESystem

@export var recruitment_system: Node

@onready var timer: Node = $Timer
var active_qte: BaseQTE = null


# Utils
func friends_amount() -> int:
	return recruitment_system.get_friends_amount()

func play_time() -> float:
	return Player.get_play_time()

func calculate_interval() -> float:
	return lerp(30, 15, Player.progress_score)


# Start the cycle
func _ready() -> void:
	set_next_qte_cycle()
	
# Update player progress score and start timer with new interval
func set_next_qte_cycle() -> void:
	if active_qte != null:
		return
	
	update_progress()
	timer.start(calculate_interval())
	
func _on_timer_timeout() -> void:
	spawn_random_qte()
	

# Currently directly updating player's fields
func update_progress() -> void:
	if not Player or not recruitment_system:
		return
		
	var play_time_factor = min(play_time() / 30.0, 1.0) * 0.6
	var friends_factor = min(float(friends_amount()) / 10.0, 1.0) * 0.4
	
	Player.progress_score = clamp(play_time_factor + friends_factor, 0.0, 1.0)

# spawn and add to tree new qte
# uses base_qte and qte_data api
func spawn_random_qte() -> void:
	if active_qte != null:
		return
		
	var base_qte = preload("res://scenes/qte/base_qte.tscn")
	active_qte = base_qte.instantiate()
	active_qte.finished.connect(on_qte_finish)
	
	var qte_data = QTEData.new()
	qte_data.title = "Placeholder Title"
	qte_data.description = "Lorem Ipsum"
	qte_data.duration = 6.7
	
	get_tree().root.add_child(active_qte)
	active_qte.start(qte_data)

# connects to BaseQTe's finished signal
func on_qte_finish(result: QTEData.Result) -> void:
	if result == QTEData.Result.SUCCESS:
		# grant energy
		Player.energy += lerp(20, 50, Player.progress_score)
	else:
		# deduct hp
		Player.hp -= 1
		
	active_qte = null
	set_next_qte_cycle()
	
	

	
