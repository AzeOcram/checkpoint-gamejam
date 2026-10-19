#Main must be responsible for putting together all systems
extends Control

# Nodes
@onready var game_input = $Systems/GameInput
@onready var energy_system = $Systems/EnergySystem


func _ready() -> void:
	game_input.tapped.connect(energy_system._on_tapped)
