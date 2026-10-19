#Main must be responsible for putting together all systems
extends Control

# Nodes
@onready var game_input = $Systems/GameInput
@onready var energy_system = $Systems/EnergySystem

const FRIEND_SCENE = preload("res://scenes/friends/friend.tscn")
const FRIEND_COST: int = 25
var available_names: Array[String] = ["Alex", "Jamie", "Sam", "Taylor", "Morgan", "Riley", "Jordan", "Casey"]

# State
var social_battery: int = 100
var base_sb_generation: int = 1
var friends: Array[FriendNode] = []

@onready var social_battery_label: Label = $SocialBatteryLabel
@onready var friend_list: VBoxContainer = $FriendsPanel/VBoxContainer/FriendList
@onready var buy_friend_button: Button = $FriendsPanel/VBoxContainer/BuyFriendButton
@onready var social_battery_timer: Timer = $SocialBatteryTimer

func _ready() -> void:
	update_stats_ui()
	social_battery_timer.timeout.connect(_on_social_battery_timer_timeout)
	buy_friend_button.pressed.connect(_on_buy_friend_button_pressed)
	update_ui()

#Stats Functions
func update_stats_ui() -> void:
	energy_per_tap_label.text = "Energy Per Tap: " + str(Player.energy_per_tap)
	luck_label.text = "Luck: " + str(Player.luck)
	hp_label.text = "HP: " + str(Player.hp) + " / " + str(Player.max_hp)

func get_total_sb_generation() -> int:
	var total: int = base_sb_generation
	for friend in friends:
		total += friend.social_battery_generation
	return total

func _on_social_battery_timer_timeout() -> void:
	social_battery += get_total_sb_generation()
	update_ui()

func _on_buy_friend_button_pressed() -> void:
	if social_battery >= FRIEND_COST:
		social_battery -= FRIEND_COST
		
		# Instantiate Friend
		var friend_instance: FriendNode = FRIEND_SCENE.instantiate() as FriendNode
		
		# Pick name
		var new_name: String = "Friend " + str(friends.size() + 1)
		if available_names.size() > 0:
			new_name = available_names.pop_front() # takes the next name in line
			
		friend_instance.setup(new_name)
		
		# Add to scene tree & tracking list
		friend_list.add_child(friend_instance)
		friends.append(friend_instance)
		
		update_ui()
		
func update_ui() -> void:
	social_battery_label.text = "Social Battery: %d (+%d/s)" % [social_battery, get_total_sb_generation()]
	buy_friend_button.disabled = social_battery < FRIEND_COST
	game_input.tapped.connect(energy_system._on_tapped)
