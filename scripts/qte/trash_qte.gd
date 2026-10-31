
extends BaseQTE
class_name TrashQTE


@onready var title_label: Label = $Overlay/TitleLabel
@onready var description_label: Label = $Overlay/DescriptionLabel
@onready var timer_label: Label = $Overlay/TimerLabel
@onready var feedback_label: Label = $Overlay/FeedbackLabel
@onready var trash_container: Control = $TrashContainer


# Placeholder sprite until real trash art exists.
const TRASH_TEXTURE1: Texture2D = preload("res://assets/art/qte/Trash 1.PNG")
const TRASH_TEXTURE2: Texture2D = preload("res://assets/art/qte/Trash 2.PNG")

const TRASH_SCALE: float = 1

# Spawn area, kept clear of the labels at the top.
const SPAWN_AREA: Rect2 = Rect2(10, 40, 280, 110)


var trash_left: int = 0


func _ready() -> void:
	if qte_data != null:
		start(qte_data)


func start(data: QTEData) -> void:
	super.start(data)
	time_remaining = pick(12.0, 10.0, 5.0)

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
	var item_size: Vector2 = TRASH_TEXTURE1.get_size() * TRASH_SCALE
	var placed: Array[Rect2] = []

	trash_left = pick(randi_range(12, 15), randi_range(10, 15), 10)

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

		# Randomly choose a texture for each trash item.
		var trash_texture: Texture2D = [TRASH_TEXTURE1, TRASH_TEXTURE2].pick_random()

		var trash := TextureButton.new()
		trash.texture_normal = trash_texture
		trash.scale = Vector2.ONE * TRASH_SCALE

		# Rotate around the sprite's center so it stays inside its spawn rect.
		trash.pivot_offset = trash_texture.get_size() / 2.0
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

	if result == QTEData.Result.SUCCESS:
		feedback_label.text = "SUCCESS!"
		feedback_label.modulate = Color.GREEN
	else:
		feedback_label.text = "FAILURE!"
		feedback_label.modulate = Color.RED

	feedback_label.visible = true

	await get_tree().create_timer(1.0).timeout

	finished.emit(result)
	queue_free()
