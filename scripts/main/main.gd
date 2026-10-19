extends Control

#Nodes
@onready var energy_per_tap_label = $UI/StatsPanel/VBoxContainer/EnergyPerTapLabel
@onready var luck_label = $UI/StatsPanel/VBoxContainer/LuckLabel
@onready var hp_label = $UI/StatsPanel/VBoxContainer/HpLabel
@onready var energy_label: Label = $EnergyLabel
@onready var energy_button: Button = $EnergyButton

var energy: int = 0


func _ready() -> void:
	energy_button.pressed.connect(_on_energy_button_pressed)
	update_energy_ui()
	update_stats_ui()

#Energy Functions
func _on_energy_button_pressed() -> void:
	energy += Player.energy_per_tap
	update_energy_ui()

func update_energy_ui() -> void:
	energy_label.text = "Energy: " + str(energy)

#Stats Functions
func update_stats_ui() -> void:
	energy_per_tap_label.text = "Energy Per Tap: " + str(Player.energy_per_tap)
	luck_label.text = "Luck: " + str(Player.luck)
	hp_label.text = "HP: " + str(Player.hp) + " / " + str(Player.max_hp)
