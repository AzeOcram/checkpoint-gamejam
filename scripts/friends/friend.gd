extends Control
class_name FriendNode

# Signal to tell the QTE Manager to spawn a QTE for this specific friend
signal request_friend_qte(friend_node: Node)

# Nodes
@onready var friend_sprite: Sprite2D = $VBoxContainer/FriendSprite
@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var mood_label: Label = $VBoxContainer/MoodLabel
@onready var connection_label: Label = $VBoxContainer/ConnectionLabel
@onready var generation_label: Label = $VBoxContainer/GenerationLabel
@onready var check_timer: Timer = $MoodCheckTimer # Added Timer Reference

# Friend Data
var data: FriendData


func _ready() -> void:
	# Set up the timer connection but don't start it until setup() is called
	check_timer.timeout.connect(_on_mood_check_timer_timeout)
	if data != null:
		update_display()
		start_mood_timer()


# Sets the data for this friend.
func setup(friend_data: FriendData) -> void:
	data = friend_data
	
	# Only update display if the node is already fully loaded in the scene tree
	if is_node_ready():
		update_display()
		start_mood_timer()


func update_display() -> void:
	if data == null:
		return

	name_label.text = "Name: " + data.friend_name
	mood_label.text = "Mood: " + str(data.mood)
	connection_label.text = "Connection: " + str(data.connection)
	generation_label.text = "Generation: +" + str(data.social_battery_generation) + " SB/sec"


# --- MOOD DECREASE & QTE LOGIC ---

func start_mood_timer() -> void:
	check_timer.wait_time = randf_range(
		data.friend_qte_timer_min,
		data.friend_qte_timer_max
	)
	check_timer.start()


func _on_mood_check_timer_timeout() -> void:
	if data == null:
		return
	
	# Random Mood Decrease Check using the friend's specific rate
	if randf() <= data.mood_decrease_rate:
		trigger_mood_decrease()
	else:
		# No QTE this time, so randomize the next timer
		start_mood_timer()


func trigger_mood_decrease() -> void:
	# 1. Pause the timer so they don't trigger another QTE while this one is active
	check_timer.stop() 
	
	# 2. Tell the manager to spawn the QTE
	request_friend_qte.emit(self)


func resume_monitoring() -> void:
	# Called by the FriendQTEManager after the QTE finishes
	# Refresh the UI in case they succeeded (Mood +1, Connection +1) or failed (Connection -1)
	update_display()
	start_mood_timer()
