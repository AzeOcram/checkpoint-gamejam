
extends BaseQTE
class_name FriendQTE

@onready var description_label: Label = $Overlay/DescriptionLabel
@onready var timer_label: Label = $Overlay/TimerLabel
@onready var name_label: Label = $Overlay/NameLabel

@onready var success_button: Button = $Overlay/SuccessButton
@onready var failure_button: Button = $Overlay/FailButton

@onready var feedback_label: Label = $Overlay/FeedbackLabel
@onready var friend_sprite: Sprite2D = $Sprite2D

var friend_data: FriendData
var friend_qte_data: FriendQTEData

var success_button_position: Vector2
var failure_button_position: Vector2

var feedback_showing: bool = false


func _ready() -> void:
	success_button_position = success_button.position
	failure_button_position = failure_button.position

	success_button.pressed.connect(_on_success_pressed)
	failure_button.pressed.connect(_on_failure_pressed)

	super._ready()


func start(data: QTEData) -> void:
	print("Friend data: ", friend_data)
	print("Friend name: ", friend_data.friend_name if friend_data != null else "NULL")
	print("Friend sprite: ", friend_data.sprite if friend_data != null else "NULL")

	qte_data = data
	is_finished = false
	feedback_showing = false

	feedback_label.text = ""

	success_button.disabled = false
	failure_button.disabled = false

	if friend_data != null:
		friend_sprite.texture = friend_data.sprite
		name_label.text = friend_data.friend_name.split(" ")[0]

		if friend_qte_data == null and not friend_data.friend_qtes.is_empty():
			friend_qte_data = friend_data.friend_qtes.pick_random()

		if friend_qte_data != null:
			description_label.text = friend_qte_data.question
			success_button.text = friend_qte_data.success_label
			failure_button.text = friend_qte_data.failure_label
		else:
			description_label.text = qte_data.description
			success_button.text = "Let's talk!"
			failure_button.text = "Not now"
	else:
		description_label.text = qte_data.description
		success_button.text = "Let's talk!"
		failure_button.text = "Not now"

	time_remaining = qte_data.duration

	if randf() < 0.5:
		success_button.position = success_button_position
		failure_button.position = failure_button_position
	else:
		success_button.position = failure_button_position
		failure_button.position = success_button_position

	timer_label.text = "TIME: %.1f" % time_remaining

	set_process(true)


func _update_qte(_delta: float) -> void:
	timer_label.text = "%.2f" % time_remaining


func _on_success_pressed() -> void:
	_show_feedback(QTEData.Result.SUCCESS)


func _on_failure_pressed() -> void:
	_show_feedback(QTEData.Result.FAILURE)


func _show_feedback(result: QTEData.Result) -> void:
	if feedback_showing or is_finished:
		return

	feedback_showing = true
	set_process(false)
	_play_result_sfx(result)

	success_button.disabled = true
	failure_button.disabled = true

	if friend_qte_data != null:
		if result == QTEData.Result.SUCCESS:
			feedback_label.text = friend_qte_data.success_feedback
		else:
			feedback_label.text = friend_qte_data.failure_feedback
	else:
		if result == QTEData.Result.SUCCESS:
			feedback_label.text = "Good job!"
		else:
			feedback_label.text = "Maybe next time..."

	await get_tree().create_timer(2.0).timeout

	_finish(result)
