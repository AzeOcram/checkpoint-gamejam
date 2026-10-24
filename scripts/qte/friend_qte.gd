extends BaseQTE
class_name FriendQTE


@onready var title_label: Label = $Overlay/Panel/Content/TitleLabel
@onready var description_label: Label = $Overlay/Panel/Content/DescriptionLabel
@onready var timer_label: Label = $Overlay/Panel/Content/TimerLabel

@onready var success_button: Button = $Overlay/Panel/Content/SuccessButton
@onready var failure_button: Button = $Overlay/Panel/Content/FailButton


func _ready() -> void:
	success_button.pressed.connect(_on_success_pressed)
	failure_button.pressed.connect(_on_failure_pressed)

	super._ready()


func start(data: QTEData) -> void:
	qte_data = data
	time_remaining = qte_data.duration
	is_finished = false

	title_label.text = qte_data.title
	description_label.text = qte_data.description
	timer_label.text = "TIME: %.1f" % time_remaining

	set_process(true)


func _update_qte(_delta: float) -> void:
	timer_label.text = "TIME: %.1f" % time_remaining


func _on_success_pressed() -> void:
	_finish(QTEData.Result.SUCCESS)


func _on_failure_pressed() -> void:
	_finish(QTEData.Result.FAILURE)
