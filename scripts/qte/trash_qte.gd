extends BaseQTE
class_name TrashQTE


@onready var title_label: Label = $Overlay/TitleLabel
@onready var description_label: Label = $Overlay/DescriptionLabel
@onready var timer_label: Label = $Overlay/TimerLabel
@onready var feedback_label: Label = $Overlay/FeedbackLabel
@onready var trash_container: Control = $TrashContainer


# Placeholder sprite until real trash art exists.
const TRASH_TEXTURE: Texture2D = preload("res://icon.svg")

const MIN_TRASH_COUNT: int = 10
const MAX_TRASH_COUNT: int = 20
const TRASH_SCALE: float = 0.15

# Spawn area, kept clear of the labels at the top.
const SPAWN_AREA: Rect2 = Rect2(10, 40, 280, 110)


var trash_left: int = 0


func _ready() -> void:
	if qte_data != null:
		start(qte_data)


func start(data: QTEData) -> void:
	super.start(data)

	feedback_label.visible = false
	title_label.text = qte_data.title
	description_label.text = qte_data.description

	for child in trash_container.get_children():
		child.queue_free()

	_spawn_trash()
	_update_timer()


func _update_qte(_delta: float) -> void:
	_update_timer()


func _update_timer() -> void:
	timer_label.text = "TIME: %.1f" % time_remaining


func _spawn_trash() -> void:
	var item_size: Vector2 = TRASH_TEXTURE.get_size() * TRASH_SCALE
	var placed: Array[Rect2] = []

	trash_left = randi_range(MIN_TRASH_COUNT, MAX_TRASH_COUNT)

	for i in trash_left:
		var rect := Rect2(Vector2.ZERO, item_size)

		# Retry a few times so items don't overlap; give up and overlap if crowded.
		for attempt in 20:
			rect.position = Vector2(
				randf_range(SPAWN_AREA.position.x, SPAWN_AREA.end.x - item_size.x),
				randf_range(SPAWN_AREA.position.y, SPAWN_AREA.end.y - item_size.y)
			)

			if not placed.any(func(r: Rect2) -> bool: return r.intersects(rect)):
				break

		placed.append(rect)

		var trash := TextureButton.new()
		trash.texture_normal = TRASH_TEXTURE
		trash.scale = Vector2.ONE * TRASH_SCALE
		# Rotate around the sprite's center so it stays inside its spawn rect.
		trash.pivot_offset = TRASH_TEXTURE.get_size() / 2.0
		trash.rotation = randf_range(0.0, TAU)
		trash.position = rect.get_center() - trash.pivot_offset
		trash.pressed.connect(_on_trash_pressed.bind(trash))
		trash_container.add_child(trash)


func _on_trash_pressed(trash: TextureButton) -> void:
	if is_finished:
		return

	trash.queue_free()
	trash_left -= 1

	if trash_left <= 0:
		_finish(QTEData.Result.SUCCESS)


func _finish(result: QTEData.Result) -> void:
	if is_finished:
		return

	is_finished = true
	set_process(false)

	feedback_label.text = "SUCCESS!" if result == QTEData.Result.SUCCESS else "FAILURE!"
	feedback_label.visible = true

	await get_tree().create_timer(1.0).timeout

	finished.emit(result)
	queue_free()
