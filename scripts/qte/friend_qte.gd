extends BaseQTE
class_name FriendQTE

@onready var title_label: Label = $Overlay/Panel/TitleLabel
@onready var description_label: Label = $Overlay/Panel/DescriptionLabel
@onready var timer_label: Label = $Overlay/Panel/TimerLabel

@onready var success_button: BaseButton = $Overlay/Panel/SuccessButton
@onready var failure_button: BaseButton = $Overlay/Panel/FailButton

@onready var success_label: Label = $Overlay/Panel/SuccessButton/SuccessLabel
@onready var failure_label: Label = $Overlay/Panel/FailButton/FailLabel

var friend_data: FriendData
var success_button_position: Vector2
var failure_button_position: Vector2


func _ready() -> void:
	success_button_position = success_button.position
	failure_button_position = failure_button.position
	success_button.pressed.connect(_on_success_pressed)
	failure_button.pressed.connect(_on_failure_pressed)
	super._ready()


func start(data: QTEData) -> void:
	print("Success label: ", success_label)
	print("Failure label: ", failure_label)

	qte_data = data
	is_finished = false

	if friend_data != null:
		var min_time = minf(friend_data.friend_qte_timer_min, friend_data.friend_qte_timer_max)
		var max_time = maxf(friend_data.friend_qte_timer_min, friend_data.friend_qte_timer_max)

		time_remaining = randf_range(min_time, max_time)
		success_label.text = friend_data.friend_qte_success_text
		failure_label.text = friend_data.friend_qte_failure_text
	else:
		time_remaining = qte_data.duration
		success_label.text = "Let's talk!"
		failure_label.text = "Not now"

	if randf() < 0.5:
		success_button.position = success_button_position
		failure_button.position = failure_button_position
	else:
		success_button.position = failure_button_position
		failure_button.position = success_button_position

	title_label.text = qte_data.title
	description_label.text = qte_data.description
	timer_label.text = "TIME: %.1f" % time_remaining

	set_process(true)


func _update_qte(_delta: float) -> void:
	timer_label.text = "%.2f" % time_remaining


func _on_success_pressed() -> void:
	_finish(QTEData.Result.SUCCESS)


func _on_failure_pressed() -> void:
	_finish(QTEData.Result.FAILURE)
