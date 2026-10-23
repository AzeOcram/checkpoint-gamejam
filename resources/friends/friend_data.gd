extends Resource
class_name FriendData

# Friend identity
@export var friend_name: String = "Friend"

# Recruitment
@export var recruitment_cost: int = 25

# Friend stats
@export var mood: int = 100
@export var connection: int = 100
@export var social_battery_generation: int = 1

# Mood Decrease rate
@export var mood_decrease_rate: float = 1.0

# Friend appearance
@export var sprite: Texture2D

# Future:
# - Sprite
# - Other friend-specific stats
