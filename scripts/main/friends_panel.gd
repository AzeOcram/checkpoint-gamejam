extends PanelContainer


# Nodes
const FRIEND_CARD_SCENE := preload("res://scenes/main/friend_card.tscn")

@onready var friend_list: GridContainer = $Pad/VBoxContainer/ScrollContainer/FriendList
@onready var friend_count_label: Label = $Pad/VBoxContainer/Header/HBoxContainer/FriendCountLabel
@onready var close_button: TextureButton = $Pad/VBoxContainer/Header/HBoxContainer/CloseButton


const CLOSE_NORMAL_SCALE := Vector2.ONE
const CLOSE_HOVER_SCALE := Vector2(1.3, 1.3)


# Reference to the Recruitment System.
@onready var recruitment_system = $"../../Systems/RecruitmentSystem"
@onready var social_battery_system = $"../../Systems/SocialBatterySystem"


var close_tween: Tween


func _ready() -> void:
	add_to_group(&"blocks_tap")
	close_button.set_meta(&"sfx_press", &"menu_close")
	close_button.pressed.connect(_on_close_pressed)
	close_button.mouse_entered.connect(_scale_close_button.bind(CLOSE_HOVER_SCALE))
	close_button.mouse_exited.connect(_scale_close_button.bind(CLOSE_NORMAL_SCALE))
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

	var progress: float = social_battery_system.generation_progress_bar.value

	for card: FriendCard in friend_list.get_children():
		card.refresh(progress)


func _on_friend_recruited(_friend: FriendNode) -> void:
	update_ui()


func _on_close_pressed() -> void:
	hide()


func _scale_close_button(target: Vector2) -> void:
	close_button.pivot_offset = close_button.size / 2.0

	if close_tween:
		close_tween.kill()

	close_tween = create_tween()
	close_tween.tween_property(close_button, "scale", target, 0.08)
