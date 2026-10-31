extends BaseQTE
class_name MathQTE


@onready var title_label: Label = $TitleLabel
@onready var desc_label: Label = $DescriptionLabel
@onready var question_label: Label = $QuestionLabel
@onready var timer_label: Label = $TimerLabel

@onready var answer_input: LineEdit = $AnswerInput
@onready var feedback_label: Label = $FeedbackLabel


var correct_answer: int
var feedback_showing: bool = false


func _ready() -> void:
	answer_input.text_submitted.connect(_on_answer_submitted)

	feedback_label.text = ""

	super._ready()


func start(data: QTEData) -> void:
	qte_data = data
	time_remaining = pick(10.0, 8.0, 5.0)
	is_finished = false
	feedback_showing = false

	title_label.text = qte_data.title
	desc_label.text = qte_data.description

	feedback_label.text = ""

	answer_input.clear()
	answer_input.editable = true

	_generate_question()

	_update_timer()

	set_process(true)
	answer_input.grab_focus()


func _generate_question() -> void:
	var first_number := randi_range(1, 9)
	var second_number := randi_range(1, 9)

	var operation := randi_range(0, pick(0, 1, 2))

	match operation:
		0:
			correct_answer = first_number + second_number

			question_label.text = "%d + %d = ?" % [
				first_number,
				second_number
			]

		1:
			if second_number > first_number:
				var temp := first_number
				first_number = second_number
				second_number = temp

			correct_answer = first_number - second_number

			question_label.text = "%d - %d = ?" % [
				first_number,
				second_number
			]

		2:
			correct_answer = first_number * second_number

			question_label.text = "%d × %d = ?" % [
				first_number,
				second_number
			]


func _update_qte(_delta: float) -> void:
	_update_timer()


func _update_timer() -> void:
	timer_label.text = "%.1f" % time_remaining


func _on_submit_pressed() -> void:
	_check_answer()


func _on_answer_submitted(_text: String) -> void:
	_check_answer()


func _check_answer() -> void:
	if is_finished or feedback_showing:
		return

	var answer_text := answer_input.text.strip_edges()

	if answer_text == "":
		return

	SFX.play(&"chalk")

	if not answer_text.is_valid_int():
		_show_feedback(QTEData.Result.FAILURE)
		return

	var player_answer := answer_text.to_int()

	if player_answer == correct_answer:
		_show_feedback(QTEData.Result.SUCCESS)
	else:
		_show_feedback(QTEData.Result.FAILURE)


func _show_feedback(result: QTEData.Result) -> void:
	if feedback_showing:
		return

	feedback_showing = true
	set_process(false)
	_play_result_sfx(result)

	answer_input.editable = false

	if result == QTEData.Result.SUCCESS:
		feedback_label.text = "CORRECT"
		feedback_label.add_theme_color_override("font_color", Color.GREEN)
	else:
		feedback_label.text = "WRONG"
		feedback_label.add_theme_color_override("font_color", Color.RED)

	await get_tree().create_timer(2.0).timeout

	_finish(result)
