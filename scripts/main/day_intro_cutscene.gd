extends CanvasLayer
class_name DayIntroCutscene


@onready var black_screen: ColorRect = $BlackScreen
@onready var day_title: Label = $DayTitle
@onready var camera: Camera2D = $Camera2D


func _ready() -> void:
	if Player.day_intro_played:
		queue_free()
		return

	Player.day_intro_played = true

	# The CanvasLayer never hides; the black screen does when the intro ends.
	black_screen.add_to_group(&"blocks_tap")

	# Initial camera close-up
	camera.zoom = Vector2(3.0, 3.0)

	# Initial black screen
	black_screen.material.set_shader_parameter("radius", 0.0)

	# Show day title
	day_title.modulate.a = 1.0

	start_cutscene()


func start_cutscene() -> void:
	# Show text
	day_title.text = "FIRST DAY OF\nNEW SCHOOL"
	day_title.modulate.a = 1.0
	
	await get_tree().create_timer(0.9).timeout
	
	
	# Fade out text
	var text_tween := create_tween()
	text_tween.tween_property(
		day_title,
		"modulate:a",
		0.0,
		0.4
	)
	
	await text_tween.finished
	
	
	# Small circle around player
	black_screen.material.set_shader_parameter("radius", 0.18)
	
	await get_tree().create_timer(0.7).timeout
	
	
	# Zoom out + expand circle together
	var reveal_tween := create_tween()
	
	reveal_tween.tween_method(
		Callable(self, "_update_reveal"),
		0.0,
		1.0,
		1.5
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	
	await reveal_tween.finished
	
	
	# Finish cutscene
	black_screen.visible = false


func _update_reveal(progress: float) -> void:
	# Camera zoom
	var zoom_value: float = lerp(3.0, 1.0, progress)
	camera.zoom = Vector2(zoom_value, zoom_value)
	
	# Circle expansion
	var radius: float= lerp(0.18, 4.0, progress)
	black_screen.material.set_shader_parameter("radius", radius)
