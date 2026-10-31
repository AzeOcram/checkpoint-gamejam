extends CanvasLayer
class_name FriendWarning


# Share of the screen height the banner takes.
const HEIGHT_RATIO := 0.15
const WIDTH := 170.0
const POP_TIME := 0.2


@onready var banner: PanelContainer = $Banner
@onready var manager: FriendQTEManager = $"../Systems/FriendQTEManager"
@onready var intro: DayIntroCutscene = $"../DayIntroCutscene"
@onready var queue: QTEQueueManager = $"../Systems/QTEQueueManager"

var shown := false
var tween: Tween


func _ready() -> void:
	var screen := get_viewport().get_visible_rect().size

	banner.size = Vector2(WIDTH, screen.y * HEIGHT_RATIO)
	banner.position = Vector2((screen.x - WIDTH) / 2.0, screen.y - banner.size.y - 2.0)
	banner.pivot_offset = banner.size / 2.0
	banner.visible = false
	banner.modulate.a = 0.0


func _process(_delta: float) -> void:
	var want := manager.warning_active() and not _intro_playing() and not _friend_qte_open()

	if want != shown:
		_set_shown(want)


func _intro_playing() -> bool:
	return is_instance_valid(intro) and intro.is_playing()


# The banner has done its job once the friend QTE screen is up.
func _friend_qte_open() -> bool:
	return is_instance_valid(queue.active_qte) and queue.active_qte is FriendQTE


func _set_shown(value: bool) -> void:
	shown = value

	if tween:
		tween.kill()

	tween = create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	if value:
		banner.visible = true
		banner.scale = Vector2(0.8, 0.8)
		tween.tween_property(banner, "scale", Vector2.ONE, POP_TIME)
		tween.tween_property(banner, "modulate:a", 1.0, POP_TIME)
	else:
		tween.tween_property(banner, "modulate:a", 0.0, POP_TIME)
		tween.chain().tween_callback(banner.hide)
