extends Control
class_name FriendMapNode


signal friend_clicked(friend_node: FriendMapNode)


@onready var texture_button: TextureButton = $TextureButton


var data: FriendData


func _ready() -> void:
	texture_button.pressed.connect(_on_pressed)


func setup(friend_data: FriendData) -> void:
	data = friend_data

	if data == null:
		return

	texture_button.texture_normal = data.sprite

	update_appearance()

	start_animation()


func update_appearance() -> void:
	if data == null:
		return

	if data.unlocked:
		texture_button.modulate = Color.WHITE
	else:
		texture_button.modulate = Color(0.35, 0.35, 0.35, 1.0)


func start_animation() -> void:
	var showing_sprite_1 := true
	
	while true:
		await get_tree().create_timer(randf_range(1.0, 3.0)).timeout

		if data == null:
			return

		showing_sprite_1 = !showing_sprite_1

		if showing_sprite_1:
			texture_button.texture_normal = data.sprite
		else:
			texture_button.texture_normal = data.sprite2


func _on_pressed() -> void:
	print("CLICKED FRIEND: ", data.friend_name)
	friend_clicked.emit(self)
