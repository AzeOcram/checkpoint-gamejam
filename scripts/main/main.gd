# Main must be responsible for putting together all systems.
extends Control


# Nodes
@onready var game_input = $Systems/GameInput
@onready var energy_system = $Systems/EnergySystem
@onready var social_battery_system = $Systems/SocialBatterySystem
@onready var recruitment_system = $Systems/RecruitmentSystem


func _ready() -> void:
	# Connect systems together.
	game_input.tapped.connect(energy_system._on_tapped)
	# Give RecruitmentSystem access to SocialBatterySystem.
	recruitment_system.social_battery_system = social_battery_system
