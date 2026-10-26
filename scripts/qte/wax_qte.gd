extends BaseQTE


@onready var title_label: Label = $Content/TitleLabel
@onready var description_label: Label = $Content/DescriptionLabel
@onready var timer_label: Label = $TimerLabel
@onready var feedback_label: Label = $FeedbackLabel

@onready var canvas: ColorRect = $SubViewportContainer/Paint/Canvas
@onready var paint: SubViewport = $SubViewportContainer/Paint


@export var brush_radius: float = 0.05
@export var brush_color: Color = Color.RED

@export_range(0.0, 1.0) var required_coverage: float = 0.8


var shader: ShaderMaterial
var is_painting: bool = false
var prev_uv: Vector2 = Vector2.ZERO

var painted_percentage: float = 0.0
var initial_image: Image


func _ready() -> void:
	super._ready()


func start(data: QTEData) -> void:
	qte_data = data
	canvas.size = paint.size
	
	# Get QTE settings from QTEData.
	time_remaining = qte_data.duration
	is_finished = false
	
	# Reset QTE state.
	is_painting = false
	prev_uv = Vector2.ZERO
	painted_percentage = 0.0
	
	# Display QTEData information.
	title_label.text = qte_data.title
	description_label.text = qte_data.description
	_update_timer()
	
	# Hide feedback while playing.
	feedback_label.visible = false
	
	
	shader = canvas.material as ShaderMaterial
	shader.set_shader_parameter("radius", brush_radius)
	shader.set_shader_parameter("color", brush_color)
	shader.set_shader_parameter("canvas", paint.get_texture())
	
	# Wait for the viewport to render its initial state.
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
		
		# Check coverage only once when time runs out.
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
	var painting_now = Input.is_action_pressed("tap")
	
	var local_pos = canvas.get_local_mouse_position()
	var uv = local_pos / canvas.size
	
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
	
	if result == QTEData.Result.SUCCESS:
		feedback_label.text = "SUCCESS!"
	else:
		feedback_label.text = "FAILURE!"
	
	feedback_label.visible = true
	
	# Keep the result visible for 2 seconds.
	await get_tree().create_timer(2.0).timeout
	
	finished.emit(result)
	queue_free()


func get_painted_percentage() -> float:
	if initial_image == null:
		return 0.0
	
	var current_image = paint.get_texture().get_image()
	
	if current_image == null:
		return 0.0
	
	var width = current_image.get_width()
	var height = current_image.get_height()
	
	if width == 0 or height == 0:
		return 0.0
	
	var changed_pixels: int = 0
	var total_pixels: int = width * height
	
	for y in range(height):
		for x in range(width):
			var initial_color = initial_image.get_pixel(x, y)
			var current_color = current_image.get_pixel(x, y)
			
			if (
				abs(initial_color.r - current_color.r) > 0.05
				or abs(initial_color.g - current_color.g) > 0.05
				or abs(initial_color.b - current_color.b) > 0.05
			):
				changed_pixels += 1
	
	return float(changed_pixels) / float(total_pixels)
