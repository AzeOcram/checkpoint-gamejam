extends Sprite2D

@onready var amount_label: Label = $AmountLabel


func set_amount(amount: int) -> void:
	amount_label.text = "+" + NumberFormatter.format_number(amount) + " SB"


func _ready() -> void:
	var tween := create_tween()

	tween.set_parallel(true)

	tween.tween_property(
		self,
		"position",
		position + Vector2(0, -50),
		0.7
	)

	tween.tween_property(
		self,
		"modulate:a",
		0.0,
		0.7
	)

	tween.set_parallel(false)

	tween.tween_callback(queue_free)
