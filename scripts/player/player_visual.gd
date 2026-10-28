extends Node2D

# Nodes
@onready var sprite_1: Sprite2D = $Sprite2D
@onready var sprite_2: Sprite2D = $Sprite2D2

# Animation
var animation_timer: float = 0.0
var animation_interval: float = 0.5
var showing_sprite_1: bool = true


func _ready() -> void:
	sprite_1.visible = true
	sprite_2.visible = false


func _process(delta: float) -> void:
	animation_timer += delta
	
	if animation_timer >= animation_interval:
		animation_timer = 0.0
		showing_sprite_1 = !showing_sprite_1
		
		sprite_1.visible = showing_sprite_1
		sprite_2.visible = !showing_sprite_1
