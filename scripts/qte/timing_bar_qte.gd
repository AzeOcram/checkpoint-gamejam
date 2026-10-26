extends BaseQTE
class_name TimingBarQTE

@onready var background: ColorRect = $BackgroundBar
@onready var success_zone: ColorRect = $BackgroundBar/SuccessZone
@onready var indicator: ColorRect = $BackgroundBar/Indicator
@onready var feedback_label: Label = $FeedbackLabel
@onready var title_label: Label = $TitleLabel
@onready var timer_label: Label = $TimerLabel

var move_speed: float = 400.0
var direction: int = 1
var is_playing: bool = false
var feedback_showing: bool = false


func _ready() -> void:
	# Stretch root control to cover full screen
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	if feedback_label:
		feedback_label.text = ""
	super._ready()


func start(data: QTEData) -> void:
	qte_data = data
	time_remaining = qte_data.duration
	is_finished = false
	feedback_showing = false
	
	if feedback_label:
		feedback_label.text = ""
	
	if title_label:
		title_label.text = qte_data.title
	
	# Center the main bar on screen dynamically
	if background:
		background.anchor_left = 0.5
		background.anchor_top = 0.5
		background.anchor_right = 0.5
		background.anchor_bottom = 0.5
		background.grow_horizontal = Control.GROW_DIRECTION_BOTH
		background.grow_vertical = Control.GROW_DIRECTION_BOTH
		
		# Randomize the green zone's position inside the background bar
		var max_x = background.size.x - success_zone.size.x
		success_zone.position.x = randf_range(0, max_x)

	is_playing = true
	set_process(true)
	
	super.start(data)


func _update_qte(delta: float) -> void:
	if timer_label and not feedback_showing:
		timer_label.text = "TIME: %.1f" % time_remaining

	if not is_playing or feedback_showing:
		return
		
	# Move indicator across bar
	indicator.position.x += move_speed * direction * delta
	
	# Bounce at edges
	if indicator.position.x <= 0:
		indicator.position.x = 0
		direction = 1
	elif indicator.position.x >= background.size.x - indicator.size.x:
		indicator.position.x = background.size.x - indicator.size.x
		direction = -1


func _input(event: InputEvent) -> void:
	if is_playing and not feedback_showing and event.is_action_pressed("ui_accept"): 
		_check_timing()


func _check_timing() -> void:
	if is_finished or feedback_showing:
		return
		
	is_playing = false
	
	var indicator_center = indicator.position.x + (indicator.size.x / 2.0)
	var zone_start = success_zone.position.x
	var zone_end = zone_start + success_zone.size.x
	
	if indicator_center >= zone_start and indicator_center <= zone_end:
		_show_feedback(QTEData.Result.SUCCESS)
	else:
		_show_feedback(QTEData.Result.FAILURE)


func _show_feedback(result: QTEData.Result) -> void:
	feedback_showing = true
	set_process(false)

	if feedback_label:
		if result == QTEData.Result.SUCCESS:
			feedback_label.text = "SUCCESS!"
			feedback_label.modulate = Color.GREEN
		else:
			feedback_label.text = "FAILED!"
			feedback_label.modulate = Color.RED

	# Wait 1.5 seconds so player can read the outcome text before closing
	await get_tree().create_timer(1.5).timeout

	_finish(result)
