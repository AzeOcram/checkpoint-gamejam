extends Node


const BASE_QTE = preload("res://scenes/qte/base_qte.tscn")
const TEST_QTE_DATA = preload("res://resources/qte/test.tres")


func _ready() -> void:
	start_test_qte.call_deferred()


func start_test_qte() -> void:
	var qte = BASE_QTE.instantiate()

	get_tree().current_scene.add_child(qte)

	qte.finished.connect(_on_qte_finished)

	qte.start(TEST_QTE_DATA)


func _on_qte_finished(result: QTEData.Result) -> void:
	if result == QTEData.Result.SUCCESS:
		print("========== QTE TEST ==========")
		print("RESULT: SUCCESS")
		print("==============================")
	else:
		print("========== QTE TEST ==========")
		print("RESULT: FAILURE")
		print("==============================")
