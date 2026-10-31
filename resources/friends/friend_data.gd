
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
@export var luck: float = 0
var luck_bonus_claimed: bool = false

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

# Recruitment QTE - Unique to each friend
@export_group("Recruitment QTE")
@export var duration: float = 10.0
@export_multiline var recruitment_question: String = "Will you help me?"
@export var recruitment_success_label: String = "Yes!"
@export var recruitment_failure_label: String = "No!"
@export_multiline var recruitment_success_feedback: String = "I'm glad!"
@export_multiline var recruitment_failure_feedback: String = "Oh..."

# Friend QTEs - Shared resources
@export_group("Friend QTEs")
@export var friend_qtes: Array[FriendQTEData] = [
	preload("res://resources/friend_qna/test.tres")
]
