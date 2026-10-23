extends Resource
class_name FriendData

# Friend identity
@export var friend_name: String = "Friend"
@export var desc: String = "Friend"

# Recruitment
@export var recruitment_cost: int = 25

# Friend stats
@export var mood: int = 100
@export var connection: int = 100
@export var social_battery_generation: int = 1
@export var luck: int = 0

# Friend interaction
@export var mood_decrease_rate: float = 1.0
@export var connection_gain: int = 1

# Friend appearance
@export var sprite: Texture2D
@export var sprite2: Texture2D
