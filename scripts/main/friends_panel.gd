extends PanelContainer


# Nodes
const FRIEND_CARD_SCENE := preload("res://scenes/main/friend_card.tscn")

@onready var friend_list: GridContainer = $VBoxContainer/ScrollContainer/FriendList
@onready var friend_count_label: Label = $VBoxContainer/Header/HBoxContainer/FriendCountLabel
@onready var close_button: TextureButton = $VBoxContainer/Header/HBoxContainer/CloseButton


# Reference to the Recruitment System.
@onready var recruitment_system = $"../../Systems/RecruitmentSystem"


func _ready() -> void:
	add_to_group(&"blocks_tap")
	close_button.set_meta(&"sfx_press", &"menu_close")
	close_button.pressed.connect(_on_close_pressed)
	recruitment_system.friend_recruited.connect(_on_friend_recruited)

	call_deferred("update_ui")


func update_ui() -> void:
	update_friend_count()
	update_friend_list()


func update_friend_count() -> void:
	var current: int = recruitment_system.friends.size()
	var total: int = recruitment_system.available_friends.size() + current

	friend_count_label.text = "Friends: " + str(current) + " / " + str(total)


func update_friend_list() -> void:
	for child in friend_list.get_children():
		child.queue_free()

	for friend in recruitment_system.friends:
		add_friend_to_list(friend)


func add_friend_to_list(friend: FriendNode) -> void:
	var card: FriendCard = FRIEND_CARD_SCENE.instantiate()

	friend_list.add_child(card)
	card.setup(friend.data)


func _process(_delta: float) -> void:
	if not visible:
		return

	for card: FriendCard in friend_list.get_children():
		card.refresh()


func _on_friend_recruited(_friend: FriendNode) -> void:
	update_ui()


func _on_close_pressed() -> void:
	hide()
