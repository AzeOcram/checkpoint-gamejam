extends Control


@onready var sprite_2d_2: Sprite2D = $Sprite2D2
@onready var sprite_2d_3: Sprite2D = $Sprite2D3


func _ready() -> void:
	if randf() < 0.5:
		sprite_2d_2.modulate.a = 1.0
		sprite_2d_3.modulate.a = 0.0
	else:
		sprite_2d_2.modulate.a = 0.0
		sprite_2d_3.modulate.a = 1.0
	
	start_sprite_animation()


func start_sprite_animation() -> void:
	while true:
		await get_tree().create_timer(4.0).timeout
		
		var tween := create_tween().set_parallel(true)
		tween.tween_property(sprite_2d_2, "modulate:a", 0.0, 0.5)
		tween.tween_property(sprite_2d_3, "modulate:a", 1.0, 0.5)
		await tween.finished
		
		await get_tree().create_timer(4.0).timeout
		
		tween = create_tween().set_parallel(true)
		tween.tween_property(sprite_2d_3, "modulate:a", 0.0, 0.5)
		tween.tween_property(sprite_2d_2, "modulate:a", 1.0, 0.5)
		await tween.finished


func _on_play_pressed() -> void:
	# Routes to Gender Selection first
	get_tree().change_scene_to_file("res://scenes/main_menu/gender_selection.tscn")

func _on_credits_pressed() -> void:
	# Change this path to match your actual credits scene file location
	get_tree().change_scene_to_file("res://scenes/main_menu/credit.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
