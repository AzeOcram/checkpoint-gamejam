extends BaseQTE
class_name SlicePaperQTE


@onready var cut_path: Line2D = $Paper/CutPath
@onready var cut_line: Line2D = $Paper/CutLine

@onready var title_label: Label = $Overlay/TitleLabel
@onready var description_label: Label = $Overlay/DescriptionLabel
@onready var timer_label: Label = $Overlay/TimerLabel
@onready var feedback_label: Label = $Overlay/FeedbackLabel

@onready var paper: Node2D = $Paper
@onready var paper_sprite: Sprite2D = $Paper/PaperSprite
@onready var paper_sprite_success: Sprite2D = $Paper/PaperSprite2
@onready var paper_sprite_fail: Sprite2D = $Paper/PaperSprite3


# How far away from the path the player is allowed to cut.
const PATH_TOLERANCE: float = 25.0

# How close the player needs to be to the top when starting.
const START_TOLERANCE: float = 25.0

# Vertical cutting path.
const PATH_TOP: float = -60.0
const PATH_BOTTOM: float = 60.0

# Pacing.
const MIN_CUT_TIME: float = 0.8
const MAX_CUT_TIME: float = 3.0


var is_cutting: bool = false
var cut_elapsed: float = 0.0
var current_y: float = PATH_TOP


func _ready() -> void:
	_setup_cut_path()
	paper_sprite_fail.visible = false
	paper_sprite_success.visible = false

	if qte_data != null:
		start(qte_data)


func _process(delta: float) -> void:
	if is_finished:
		return

	time_remaining -= delta

	if is_cutting:
		cut_elapsed += delta

		# Player is cutting too slowly.
		if cut_elapsed > MAX_CUT_TIME:
			_finish(QTEData.Result.FAILURE)
			return

	if time_remaining <= 0.0:
		time_remaining = 0.0
		_update_timer()

		_finish(QTEData.Result.FAILURE)
		return

	_update_timer()


func _input(event: InputEvent) -> void:
	if is_finished:
		return

	if event is InputEventMouseButton:
		if event.button_index != MOUSE_BUTTON_LEFT:
			return

		if event.pressed:
			_start_cut()
		else:
			_end_cut()

	elif event is InputEventMouseMotion:
		if is_cutting:
			_update_cut()


func start(data: QTEData) -> void:
	qte_data = data

	time_remaining = qte_data.duration
	is_finished = false

	is_cutting = false
	cut_elapsed = 0.0
	current_y = PATH_TOP

	feedback_label.visible = false
	cut_line.clear_points()

	_apply_data()
	_update_timer()

	set_process(true)


func _apply_data() -> void:
	title_label.text = qte_data.title
	description_label.text = qte_data.description


func _update_timer() -> void:
	timer_label.text = "%.1f" % time_remaining


func _setup_cut_path() -> void:
	cut_path.clear_points()

	# Vertical path.
	cut_path.add_point(Vector2(0, PATH_TOP))
	cut_path.add_point(Vector2(0, PATH_BOTTOM))

	cut_path.width = 2.0
	cut_path.default_color = Color.WHITE

	cut_line.clear_points()
	cut_line.width = 2.0
	cut_line.default_color = Color.RED


func _start_cut() -> void:
	var mouse_position: Vector2 = paper.to_local(
		get_viewport().get_mouse_position()
	)

	# Must start near the top of the path.
	if abs(mouse_position.x) > PATH_TOLERANCE:
		_finish(QTEData.Result.FAILURE)
		return

	if abs(mouse_position.y - PATH_TOP) > START_TOLERANCE:
		_finish(QTEData.Result.FAILURE)
		return

	is_cutting = true
	cut_elapsed = 0.0
	current_y = PATH_TOP

	cut_line.clear_points()

	cut_line.add_point(
		Vector2(mouse_position.x, PATH_TOP)
	)


func _end_cut() -> void:
	if not is_cutting:
		return

	# Releasing before reaching the bottom means
	# the paper was not completely sliced.
	if current_y < PATH_BOTTOM:
		_finish(QTEData.Result.FAILURE)
		return

	is_cutting = false


func _update_cut() -> void:
	var mouse_position: Vector2 = paper.to_local(
		get_viewport().get_mouse_position()
	)

	# Too far away from the cutting path.
	if abs(mouse_position.x) > PATH_TOLERANCE:
		_finish(QTEData.Result.FAILURE)
		return

	# Don't allow the player to move backwards.
	if mouse_position.y < current_y:
		return

	current_y = mouse_position.y

	cut_line.add_point(
		Vector2(mouse_position.x, current_y)
	)

	# Reached the bottom.
	if current_y >= PATH_BOTTOM:
		_complete_cut()


func _complete_cut() -> void:
	if not is_cutting:
		return

	is_cutting = false

	# Too fast.
	if cut_elapsed < MIN_CUT_TIME:
		_finish(QTEData.Result.FAILURE)
		return

	# Too slow.
	if cut_elapsed > MAX_CUT_TIME:
		_finish(QTEData.Result.FAILURE)
		return

	# Good pacing.
	_finish(QTEData.Result.SUCCESS)


func _finish(result: QTEData.Result) -> void:
	if is_finished:
		return

	is_finished = true
	is_cutting = false
	set_process(false)

	if result == QTEData.Result.SUCCESS:
		feedback_label.text = "SUCCESS!"
		feedback_label.modulate = Color.GREEN
		paper_sprite.visible = false
		paper_sprite_success.visible = true
	else:
		feedback_label.text = "FAILURE!"
		feedback_label.modulate = Color.RED
		paper_sprite.visible = false
		paper_sprite_fail.visible = true

	feedback_label.visible = true

	await get_tree().create_timer(2.0).timeout

	finished.emit(result)
	queue_free()
