extends CanvasLayer
class_name BaseQTE


signal finished(result: QTEData.Result)


#@onready var background: TextureRect = $Overlay/Panel/Content/Background
#@onready var character: TextureRect = $Overlay/Panel/Content/Character
#@onready var supporting_sprites: HBoxContainer = $Overlay/Panel/Content/SupportingSprites

@onready var title_label: Label = $Overlay/Panel/Content/TitleLabel
@onready var description_label: Label = $Overlay/Panel/Content/DescriptionLabel
@onready var timer_label: Label = $Overlay/Panel/Content/TimerLabel

@onready var success_button: Button = $Overlay/Panel/Content/SuccessButton
@onready var failure_button: Button = $Overlay/Panel/Content/FailureButton


var qte_data: QTEData
var time_remaining: float = 0.0
var is_finished: bool = false


func _ready() -> void:
	success_button.pressed.connect(_on_success_pressed)
	failure_button.pressed.connect(_on_failure_pressed)


func start(data: QTEData) -> void:
	qte_data = data
	time_remaining = qte_data.duration
	is_finished = false

	_apply_data()
	_update_timer()

	set_process(true)


func _process(delta: float) -> void:
	if is_finished:
		return

	time_remaining -= delta

	if time_remaining <= 0.0:
		time_remaining = 0.0
		_update_timer()
		_finish(QTEData.Result.FAILURE)
		return

	_update_timer()


func _apply_data() -> void:
	title_label.text = qte_data.title
	description_label.text = qte_data.description

	#background.texture = qte_data.background_texture

	success_button.icon = qte_data.success_button_texture
	failure_button.icon = qte_data.failure_button_texture

	#_clear_supporting_sprites()

	for texture in qte_data.supporting_textures:
		_add_supporting_sprite(texture)


#func _clear_supporting_sprites() -> void:
	#for child in supporting_sprites.get_children():
		#child.queue_free()


func _add_supporting_sprite(texture: Texture2D) -> void:
	var sprite := TextureRect.new()

	sprite.texture = texture
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	#supporting_sprites.add_child(sprite)


func _update_timer() -> void:
	timer_label.text = "TIME: %.1f" % time_remaining


func _on_success_pressed() -> void:
	_finish(QTEData.Result.SUCCESS)


func _on_failure_pressed() -> void:
	_finish(QTEData.Result.FAILURE)


func _finish(result: QTEData.Result) -> void:
	if is_finished:
		return

	is_finished = true
	set_process(false)

	finished.emit(result)
	queue_free()
