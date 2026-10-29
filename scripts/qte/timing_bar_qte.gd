extends BaseQTE
class_name TimingBarQTE

@onready var background: TextureRect = $BackgroundBar
@onready var success_zone: ColorRect = $BackgroundBar/SuccessZone
@onready var indicator: ColorRect = $BackgroundBar/Indicator
@onready var feedback_label: Label = $FeedbackLabel
@onready var title_label: Label = $TitleLabel
@onready var timer_label: Label = $TimerLabel
@onready var description_label: Label = $DescriptionLabel
@onready var ball: Sprite2D = $Sprite2D2

var move_speed: float = 400.0
var base_zone_width: float = 0.0
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
	move_speed = pick(300.0, 340.0, 400.0)
	is_finished = false
	feedback_showing = false
	
	if feedback_label:
		feedback_label.text = ""
	
	if title_label:
		title_label.text = qte_data.title
	
	if description_label:
		description_label.text = qte_data.description
	
	# Center the main bar on screen dynamically
	if background:
		background.anchor_left = 0.5
		background.anchor_top = 0.5
		background.anchor_right = 0.5
		background.anchor_bottom = 0.5
		background.grow_horizontal = Control.GROW_DIRECTION_BOTH
		background.grow_vertical = Control.GROW_DIRECTION_BOTH
		
		if base_zone_width == 0.0:
			base_zone_width = success_zone.size.x
		success_zone.size.x = base_zone_width * pick(1.35, 1.2, 1.0)

		# Randomize the green zone's position inside the background bar
		var max_x = background.size.x - success_zone.size.x
		success_zone.position.x = randf_range(0, max_x)

	is_playing = true
	set_process(true)
	
	super.start(data)
	time_remaining = pick(8.0, 7.0, 5.0)


func _update_qte(delta: float) -> void:
	if timer_label and not feedback_showing:
		timer_label.text = "%.2f" % time_remaining

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
	# Check for left mouse button click
	if is_playing and not feedback_showing and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
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
			_celebrate_ball()
		else:
			feedback_label.text = "FAILED!"
			feedback_label.modulate = Color.RED
			_shake_ball()

	# Wait 1.5 seconds so player can read the outcome text before closing
	await get_tree().create_timer(1.5).timeout

	_finish(result)

func _shake_ball() -> void:
	if not ball:
		return

	var original_position = ball.position
	var tween = create_tween()

	tween.tween_property(ball, "position", original_position + Vector2(-4, 0), 0.04)
	tween.tween_property(ball, "position", original_position + Vector2(4, 0), 0.04)
	tween.tween_property(ball, "position", original_position + Vector2(-3, 0), 0.04)
	tween.tween_property(ball, "position", original_position + Vector2(3, 0), 0.04)
	tween.tween_property(ball, "position", original_position, 0.04)

func _celebrate_ball() -> void:
	if not ball:
		return

	var original_position = ball.position
	var tween = create_tween()

	# Jump upward, then land back at the original position
	tween.tween_property(
		ball,
		"position",
		original_position + Vector2(0, -28),
		0.15
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		ball,
		"position",
		original_position,
		0.2
	).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

	# Shoot stars out of the ball
	_shoot_stars()


func _shoot_stars() -> void:
	var star_offsets = [
		Vector2(-25, -25),
		Vector2(25, -25),
		Vector2(-32, 5),
		Vector2(32, 5),
		Vector2(0, -35)
	]

	var star_colors = [
		Color.YELLOW,
		Color.CYAN,
		Color.HOT_PINK,
		Color.GOLD,
		Color.WHITE
	]

	for i in range(star_offsets.size()):
		var star = Label.new()
		star.text = "✦"
		star.add_theme_font_size_override("font_size", 20)
		star.modulate = star_colors[i]
		star.position = Vector2.ZERO
		star.size = Vector2(24, 24)
		star.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		star.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

		ball.add_child(star)

		var tween = create_tween()
		tween.set_parallel(true)

		tween.tween_property(
			star,
			"position",
			star_offsets[i],
			0.4
		).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

		tween.tween_property(
			star,
			"modulate:a",
			0.0,
			0.4
		)

		tween.tween_property(
			star,
			"scale",
			Vector2.ZERO,
			0.4
		)

		tween.chain().tween_callback(star.queue_free)
