extends Node2D
class_name FriendMap


const FRIEND_MAP_SCENE = preload("res://scenes/friends/friend_map_node.tscn")


const ROWS := 4
const COLUMNS := 6

const LEFT_START := Vector2(40, 54)
const RIGHT_START := Vector2(168, 54)

const COLUMN_SPACING := 16.0
const ROW_SPACING := 16.0


@export var friend_collection: FriendCollection

@onready var stats_shop: Control = $"../../UI/StatsShop"
@onready var friend_info_panel: FriendInfoPanel = $FriendInfoPanel
@onready var recruitment_system = $"../../Systems/RecruitmentSystem"
@onready var social_battery_system = $"../../Systems/SocialBatterySystem"
@onready var friend_qte_manager: FriendQTEManager = $"../../Systems/FriendQTEManager"

var selected_friend: FriendMapNode = null
var seats: Array[FriendMapNode] = []


func _ready() -> void:
	friend_info_panel.buy_requested.connect(_on_buy_friend_requested)
	print("FRIEND MAP PANEL RECT: ", friend_info_panel.get_global_rect())
	# Update the BUY button whenever Social Battery changes.
	if social_battery_system:
		social_battery_system.social_battery_changed.connect(_on_social_battery_changed)

	friend_qte_manager.alert_changed.connect(_on_alert_changed)
	friend_qte_manager.alert_ended.connect(_on_alert_ended)

	friend_info_panel.z_index = 100
	if recruitment_system:
		recruitment_system.friend_recruited.connect(_on_friend_recruited)
	spawn_friends()

	# Mouse picking follows tree order, not z_index: keep the panel after the friends so they can't steal its clicks.
	move_child(friend_info_panel, -1)

func _on_friend_recruited(friend_node: FriendNode) -> void:
	var friend_data: FriendData = friend_node.data

	SFX.play(&"purchase")
	print("Successfully recruited: ", friend_data.friend_name)

	update_friend_visual(friend_data)

	# Refresh the panel if this friend is currently selected.
	if selected_friend != null and selected_friend.data == friend_data:
		friend_info_panel.setup(friend_data)
		friend_info_panel.set_buyable(false)

func spawn_friends() -> void:
	if friend_collection == null:
		push_error("FriendCollection is not assigned to FriendMap!")
		return

	for friend_data in friend_collection.friends:
		var friend_map_node := FRIEND_MAP_SCENE.instantiate() as FriendMapNode

		add_child(friend_map_node)
		seats.append(friend_map_node)

		friend_map_node.position = get_seat_position(
			friend_data.map_position_index
		)

		friend_map_node.setup(friend_data)

		friend_map_node.friend_clicked.connect(_on_friend_clicked)

	# Ensure FriendInfoPanel is processed LAST in scene tree (top priority for inputs)
	move_child(friend_info_panel, -1)


# Any input outside the open friend info closes it: S/F shortcuts, taps and clicks.
func _input(event: InputEvent) -> void:
	if not friend_info_panel.visible:
		return

	if event.is_action_pressed(&"open_shop") or event.is_action_pressed(&"open_friends"):
		_close_info()
	elif event.is_action_pressed(&"tap"):
		var hovered := get_viewport().gui_get_hovered_control()

		if hovered == friend_info_panel or friend_info_panel.is_ancestor_of(hovered):
			return

		_close_info()

		# Buttons (S/F icons) still act on this click; anything else only dismisses.
		if not hovered is BaseButton:
			get_viewport().set_input_as_handled()


func _close_info() -> void:
	friend_info_panel.hide()
	selected_friend = null
	SFX.play(&"menu_close")


func _on_friend_clicked(friend_node: FriendMapNode) -> void:
	print("MAP RECEIVED CLICK: ", friend_node.data.friend_name)

	# An alerted friend's click answers them instead of opening the panel.
	if friend_qte_manager.has_alert(friend_node.data):
		friend_qte_manager.start_qte(friend_node.data)
		return

	# The shop covers the map, so friends behind it are not clickable.
	if stats_shop.visible:
		return

	# Ensure panel is on top of input hierarchy when opened
	move_child(friend_info_panel, -1)

	if selected_friend == friend_node:
		friend_info_panel.hide()
		selected_friend = null
		SFX.play(&"menu_close")
		return

	selected_friend = friend_node

	friend_info_panel.setup(friend_node.data)

	update_buy_button()

	friend_info_panel.show()
	SFX.play(&"menu_open")


func update_buy_button() -> void:
	if selected_friend == null:
		return

	if recruitment_system == null:
		print("ERROR: RecruitmentSystem is null")
		return

	var friend_data: FriendData = selected_friend.data

	print("========== BUY CHECK ==========")
	print("Friend: ", friend_data.friend_name)
	print("Friend cost: ", friend_data.recruitment_cost)
	print("Friend unlocked: ", friend_data.unlocked)
	print("Player SB: ", social_battery_system.get_amount())
	print("Can afford: ", social_battery_system.can_afford(friend_data.recruitment_cost))
	print("===============================")

	friend_info_panel.set_buyable(
		recruitment_system.can_recruit(friend_data)
	)


func _on_social_battery_changed() -> void:
	if selected_friend == null:
		return

	if not friend_info_panel.visible:
		return

	update_buy_button()



func _on_buy_friend_requested(friend_data: FriendData) -> void:
	if recruitment_system == null:
		push_error("RecruitmentSystem not found!")
		return

	if recruitment_system.recruitment_in_progress:
		return

	if not recruitment_system.can_recruit(friend_data):
		SFX.play(&"cant_afford")
		return

	# Start the recruitment QTE.
	recruitment_system.recruit_friend(friend_data)

	# Close the panel while the recruitment QTE is active.
	friend_info_panel.hide()
	selected_friend = null

func _on_alert_changed(friend_data: FriendData, time_left: float) -> void:
	var seat := _seat_for(friend_data)

	if seat == null:
		return

	var opening := not seat.alert_label.visible

	seat.show_alert(time_left)

	if opening:
		_restack()


func _on_alert_ended(friend_data: FriendData) -> void:
	var seat := _seat_for(friend_data)

	if seat != null:
		seat.hide_alert()
		_restack()


# Mouse picking follows tree order, so alerted seats go last (before the panel) to match their z_index. Others keep spawn order.
func _restack() -> void:
	var index := 0

	for alerted in [false, true]:
		for seat: FriendMapNode in seats:
			if seat.alert_label.visible == alerted:
				move_child(seat, index)
				index += 1

	move_child(friend_info_panel, -1)


func _seat_for(friend_data: FriendData) -> FriendMapNode:
	for child in get_children():
		if child is FriendMapNode and child.data == friend_data:
			return child

	return null


func update_friend_visual(friend_data: FriendData) -> void:
	for child in get_children():
		if child is FriendMapNode:
			if child.data == friend_data:
				child.update_appearance()
				return


func get_seat_position(index: int) -> Vector2:
	var side_size := ROWS * COLUMNS

	var start_position: Vector2
	var local_index: int

	if index < side_size:
		start_position = LEFT_START
		local_index = index
	else:
		start_position = RIGHT_START
		local_index = index - side_size

	var row := floori(local_index / float(COLUMNS))
	var column := local_index % COLUMNS

	return start_position + Vector2(
		column * COLUMN_SPACING,
		row * ROW_SPACING
	)
