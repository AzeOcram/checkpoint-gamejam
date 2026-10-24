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


func update_appearance() -> void:
	if data == null:
		return

	if data.unlocked:
		texture_button.modulate = Color.WHITE
	else:
		texture_button.modulate = Color(0.35, 0.35, 0.35, 1.0)


func _on_pressed() -> void:
	print("CLICKED FRIEND: ", data.friend_name)
	friend_clicked.emit(self)
