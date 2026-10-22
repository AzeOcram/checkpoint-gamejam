# Main must be responsible for putting together all systems.
extends Control


# Nodes
@onready var game_input = $Systems/GameInput
@onready var energy_system = $Systems/EnergySystem
@onready var social_battery_system = $Systems/SocialBatterySystem
@onready var recruitment_system = $Systems/RecruitmentSystem
@onready var stats_system = $Systems/StatsSystem
@onready var stats_shop = $UI/StatsShop


func _ready() -> void:
	# Connect systems together.
	stats_system.setup(energy_system)
	stats_shop.setup(stats_system, energy_system)
	
	game_input.tapped.connect(energy_system._on_tapped)
	# Give RecruitmentSystem access to SocialBatterySystem.
	recruitment_system.social_battery_system = social_battery_system
