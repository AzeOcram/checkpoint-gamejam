extends Control
class_name KeyHint


# Fully visible for HOLD seconds after the day intro, then fades out over FADE seconds.
const HOLD := 60.0
const FADE := 4.0


@onready var intro: DayIntroCutscene = $"../../DayIntroCutscene"

var elapsed := 0.0


func _ready() -> void:
	_add_badge("F", $"../SocialCircleButton")
	_add_badge("S", $"../CharacterButton")


func _process(delta: float) -> void:
	if is_instance_valid(intro) and intro.is_playing():
		return

	advance(delta)


func advance(delta: float) -> void:
	elapsed += delta
	modulate.a = 1.0 - clampf((elapsed - HOLD) / FADE, 0.0, 1.0)
	visible = modulate.a > 0.0


func _add_badge(key: String, button: Control) -> void:
	var cap := PanelContainer.new()
	var box := StyleBoxFlat.new()
	var label := Label.new()

	box.bg_color = Color(0.12, 0.08, 0.05, 0.85)
	box.set_corner_radius_all(2)
	box.content_margin_left = 3.0
	box.content_margin_right = 3.0
	box.content_margin_top = 0.0
	box.content_margin_bottom = 0.0
	cap.add_theme_stylebox_override(&"panel", box)
	cap.mouse_filter = Control.MOUSE_FILTER_IGNORE

	label.text = key
	label.add_theme_font_size_override(&"font_size", 8)
	label.add_theme_color_override(&"font_color", Color(1.0, 0.9, 0.6))
	cap.add_child(label)
	add_child(cap)

	# Centred under the button, which is scaled down so its rect is size * scale.
	var bottom_middle := button.position + Vector2(button.size.x * 0.5, button.size.y) * button.scale
	cap.position = bottom_middle - Vector2(cap.get_combined_minimum_size().x * 0.5, 2.0)
