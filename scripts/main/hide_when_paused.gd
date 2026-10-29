extends CanvasLayer
# CanvasLayers always draw above z_index, so hide floating feedback while a QTE (or the pause menu) is up.


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(_delta: float) -> void:
	visible = not get_tree().paused
