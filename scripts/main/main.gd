extends Control

#Nodes
@onready var energy_per_tap_label = $UI/StatsPanel/VBoxContainer/EnergyPerTapLabel
@onready var luck_label = $UI/StatsPanel/VBoxContainer/LuckLabel
@onready var hp_label = $UI/StatsPanel/VBoxContainer/HpLabel


func _ready() -> void:
	update_stats_ui()

#Stats Functions
func update_stats_ui() -> void:
	energy_per_tap_label.text = "Energy Per Tap: " + str(Player.energy_per_tap)
	luck_label.text = "Luck: " + str(Player.luck)
	hp_label.text = "HP: " + str(Player.hp) + " / " + str(Player.max_hp)
