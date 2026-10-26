extends Control
class_name BaseQTE


signal finished(result: QTEData.Result)


var qte_data: QTEData


var time_remaining: float = 0.0
var is_finished: bool = false


func _ready() -> void:
	if qte_data != null:
		start(qte_data)


func start(data: QTEData) -> void:
	qte_data = data
	time_remaining = qte_data.duration
	is_finished = false

	set_process(true)


func _process(delta: float) -> void:
	if is_finished:
		return

	time_remaining -= delta

	if time_remaining <= 0.0:
		time_remaining = 0.0
		_on_timeout()
		return

	_update_qte(delta)


func _update_qte(_delta: float) -> void:
	pass


func _on_timeout() -> void:
	_finish(QTEData.Result.FAILURE)


func _finish(result: QTEData.Result) -> void:
	if is_finished:
		return

	is_finished = true
	set_process(false)

	finished.emit(result)
	queue_free()
