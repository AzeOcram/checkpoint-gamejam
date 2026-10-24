extends PanelContainer


# Nodes
@onready var friend_list: VBoxContainer = $VBoxContainer/FriendList


# Reference to the Recruitment System.
@onready var recruitment_system = $"../../Systems/RecruitmentSystem"


func _ready() -> void:
	call_deferred("update_ui")


# Updates the recruitment UI.
func update_ui() -> void:
	# RecruitmentSystem now handles the individual
	# Buy buttons for every friend.
	#
	# This function is kept so other systems can still
	# request the panel to refresh if necessary.
	pass


func _on_close_pressed() -> void:
	hide()
