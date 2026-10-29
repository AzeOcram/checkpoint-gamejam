extends BaseQTE


@onready var title_label: Label = $TitleLabel
@onready var description_label: Label = $DescriptionLabel
@onready var timer_label: Label = $TimerLabel
@onready var feedback_label: Label = $FeedbackLabel

@onready var canvas: ColorRect = $WaxOverlay/SubViewportContainer/Paint/Canvas
@onready var paint: SubViewport = $WaxOverlay/SubViewportContainer/Paint

@onready var cursor: TextureRect = $Cursor


@export var brush_radius: float = 0.05
@export var brush_color: Color = Color(0.8, 0.15, 0.1, 0.20)

var required_coverage: float = 0.8


var shader: ShaderMaterial
var is_painting: bool = false
var prev_uv: Vector2 = Vector2.ZERO

var painted_percentage: float = 0.0
var initial_image: Image


func _ready() -> void:
	super._ready()

	cursor.mouse_filter = Control.MOUSE_FILTER_IGNORE


func start(data: QTEData) -> void:
	qte_data = data

	# Make the painting area match the floor map.
	canvas.set_deferred("size", paint.size)

	time_remaining = pick(12.0, 10.0, 7.0)
	required_coverage = pick(0.6, 0.7, 0.8)
	is_finished = false

	is_painting = false
	prev_uv = Vector2.ZERO
	painted_percentage = 0.0

	title_label.text = qte_data.title
	description_label.text = qte_data.description

	_update_timer()

	feedback_label.visible = false
	cursor.visible = true

	shader = canvas.material as ShaderMaterial

	shader.set_shader_parameter("radius", brush_radius)
	shader.set_shader_parameter("color", brush_color)
	shader.set_shader_parameter("canvas", paint.get_texture())

	await get_tree().process_frame

	initial_image = paint.get_texture().get_image()

	set_process(true)


func _process(delta: float) -> void:
	if is_finished:
		return

	time_remaining -= delta

	if time_remaining <= 0.0:
		time_remaining = 0.0

		_update_timer()

		painted_percentage = get_painted_percentage()

		print("Final painted coverage: ", painted_percentage * 100.0, "%")
		print("Required coverage: ", required_coverage * 100.0, "%")

		if painted_percentage >= required_coverage:
			_show_result(QTEData.Result.SUCCESS)
		else:
			_show_result(QTEData.Result.FAILURE)

		return

	_update_timer()
	_update_qte(delta)


func _update_qte(_delta: float) -> void:
	var painting_now := Input.is_action_pressed("tap")

	var local_pos := canvas.get_local_mouse_position()
	var uv := local_pos / canvas.size

	# Keep cursor centered on the mouse.
	cursor.position = (
		$WaxOverlay.position
		+ $WaxOverlay/SubViewportContainer.position
		+ local_pos
		- cursor.size / 2.0
	)

	if painting_now and not is_painting:
		prev_uv = uv

	shader.set_shader_parameter("is_drawing", painting_now)
	shader.set_shader_parameter("prev_pos", prev_uv)
	shader.set_shader_parameter("curr_pos", uv)

	prev_uv = uv
	is_painting = painting_now


func _update_timer() -> void:
	timer_label.text = "TIME: %.1f" % time_remaining


func _show_result(result: QTEData.Result) -> void:
	is_finished = true
	is_painting = false

	set_process(false)

	cursor.visible = false

	if result == QTEData.Result.SUCCESS:
		feedback_label.text = "SUCCESS!"
		feedback_label.add_theme_color_override(
			"font_color",
			Color("#5CFF6D")
		)
	else:
		feedback_label.text = "FAILURE!"
		feedback_label.add_theme_color_override(
			"font_color",
			Color("#FF5C5C")
		)

	feedback_label.visible = true

	await get_tree().create_timer(2.0).timeout

	finished.emit(result)
	queue_free()


func get_painted_percentage() -> float:
	if initial_image == null:
		return 0.0

	var current_image := paint.get_texture().get_image()

	if current_image == null:
		return 0.0

	var width := current_image.get_width()
	var height := current_image.get_height()

	if width == 0 or height == 0:
		return 0.0

	var changed_pixels: int = 0
	var total_pixels: int = width * height

	for y in range(height):
		for x in range(width):
			var initial_color := initial_image.get_pixel(x, y)
			var current_color := current_image.get_pixel(x, y)

			if (
				abs(initial_color.r - current_color.r) > 0.05
				or abs(initial_color.g - current_color.g) > 0.05
				or abs(initial_color.b - current_color.b) > 0.05
				or abs(initial_color.a - current_color.a) > 0.05
			):
				changed_pixels += 1

	return float(changed_pixels) / float(total_pixels)
