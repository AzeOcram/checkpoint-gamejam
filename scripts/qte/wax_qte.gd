extends BaseQTE


@onready var title_label: Label = $Overlay/Panel/Content/TitleLabel
@onready var timer_label: Label = $Overlay/Panel/Content/TimerLabel

# @onready var canvas: ColorRect = $Overlay/Panel/SubViewportContainer/Paint/Canvas
# @onready var paint: SubViewport = $Overlay/Panel/SubViewportContainer/Paint

@onready var canvas: ColorRect = $SubViewportContainer/Paint/Canvas
@onready var paint: SubViewport = $SubViewportContainer/Paint

@export var brush_radius: float = 0.01
@export var brush_color: Color = Color.RED 

var shader: ShaderMaterial
var is_painting: bool = false
var prev_uv: Vector2 = Vector2.ZERO


func _ready() -> void:
	super._ready()


func start(data: QTEData) -> void:
	qte_data = data
	time_remaining = qte_data.duration
	is_finished = false

	title_label.text = qte_data.title

	_update_timer()

	canvas.size = paint.size

	shader = canvas.material as ShaderMaterial
	shader.set_shader_parameter("radius", brush_radius)
	shader.set_shader_parameter("color", brush_color)
	shader.set_shader_parameter("canvas", paint.get_texture())


	set_process(true)

func _update_qte(_delta: float) -> void:
	_update_timer()
	
	# PLS LANG PLS LANG OWORKOKRWKWOOWKROKWRK
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
