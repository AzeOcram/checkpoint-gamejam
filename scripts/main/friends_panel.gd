extends PanelContainer


# Nodes
@onready var friend_list: VBoxContainer = $VBoxContainer/FriendList
@onready var buy_friend_button: Button = $VBoxContainer/BuyFriendButton


# Reference to the Recruitment System.
@onready var recruitment_system = $"../../Systems/RecruitmentSystem"


func _ready() -> void:
	buy_friend_button.pressed.connect(_on_buy_friend_button_pressed)
	call_deferred("update_ui")


# Attempts to recruit a friend when the button is pressed.
func _on_buy_friend_button_pressed() -> void:
	var friend: FriendNode = recruitment_system.recruit_friend()

	if friend == null:
		return

	friend_list.add_child(friend)
	update_ui()


# Updates the recruitment UI.
func update_ui() -> void:
	buy_friend_button.disabled = not recruitment_system.can_recruit()
