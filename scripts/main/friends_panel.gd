extends PanelContainer


# Nodes
@onready var friend_list: VBoxContainer = $VBoxContainer/FriendList
@onready var friend_count_label: Label = $VBoxContainer/FriendCountLabel


# Reference to the Recruitment System.
@onready var recruitment_system = $"../../Systems/RecruitmentSystem"


func _ready() -> void:
	add_to_group(&"blocks_tap")
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
	var label := Label.new()

	label.text = (
		friend.data.friend_name
		+ " | Mood: " + str(friend.data.mood)
		+ " | Connection: " + str(friend.data.connection)
		+ " | +" + str(friend.data.social_battery_generation)
		+ " SB/sec"
	)

	friend_list.add_child(label)


func _on_friend_recruited(_friend: FriendNode) -> void:
	update_ui()


func _on_close_pressed() -> void:
	hide()
