extends Node2D

# Nodes
@onready var female_1: Sprite2D = $Female1
@onready var female_2: Sprite2D = $Female2
@onready var male_1: Sprite2D = $Male1
@onready var male_2: Sprite2D = $Male2

# Animation
var animation_timer: float = 0.0
var animation_interval: float = 0.5
var showing_sprite_1: bool = true


func _ready() -> void:
	if Player.gender == Player.Gender.FEMALE:
		female_1.visible = true
		female_2.visible = false
		male_1.visible = false
		male_2.visible = false
	else:
		male_1.visible = true
		male_2.visible = false
		female_1.visible = false
		female_2.visible = false


func _process(delta: float) -> void:
	animation_timer += delta
	
	if animation_timer >= animation_interval:
		animation_timer = 0.0
		showing_sprite_1 = !showing_sprite_1
		
		if Player.gender == Player.Gender.FEMALE:
			female_1.visible = showing_sprite_1
			female_2.visible = !showing_sprite_1
		else:
			male_1.visible = showing_sprite_1
			male_2.visible = !showing_sprite_1
