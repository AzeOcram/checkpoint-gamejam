
@tool
extends Resource
class_name FriendData

# Friend identity
@export var friend_name: String = "Friend"
@export var desc: String = "Friend"

# Recruitment
@export var recruitment_cost: int = 25
@export var unlocked: bool = false

# Friend stats
@export var mood: int = 100
@export var connection: int = 0
@export var social_battery_generation: int = 1
@export var luck: int = 0

# Friend interaction
@export var mood_decrease_rate: float = 1.0
@export var connection_gain: int = 1
@export var friend_qte_timer_min: float = 5.0
@export var friend_qte_timer_max: float = 10.0

# Friend appearance
@export var sprite: Texture2D
@export var sprite2: Texture2D

# Map
@export var map_position_index: int = 0

# QTE
# Recruitment QTE
@export var recruitment_qte_title: String = "Let's Talk"
@export_multiline var recruitment_qte_description: String = "Will you help me?"
@export var recruitment_qte_duration: float = 5.0

# Friend QTE
@export_multiline var friend_qte_success_text: String = "Let's talk!"
@export_multiline var friend_qte_failure_text: String = "No!"
