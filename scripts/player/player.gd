
extends Node2D

# Attributes
signal hp_changed
signal game_over

# Stats
var energy_per_tap: int = 1
var luck: float = 0.0
var hp: int = 3
var max_hp: int = 3

const MAX_LUCK: float = 0.9

# Consumables
var energy: int = 0
var social_battery: int = 0
var social_battery_per_second: int = 1

# Game Stats
var play_time: float = 0.0 # MINUTES
var progress_score: float = 0.0


# Main Functions
func _process(delta: float) -> void:
	play_time += delta / 60.0 # in minutes


# HP Functions
func take_damage(amount: int) -> void:
	hp = max(hp - amount, 0)
	hp_changed.emit()

	if hp == 0:
		game_over.emit()
		_handle_game_over()


func _handle_game_over() -> void:
	print("GAME OVER - Player ran out of HP!")
	get_tree().change_scene_to_file("res://scenes/main/game_over.tscn")


func heal(amount: int) -> void:
	hp = min(hp + amount, max_hp)
	hp_changed.emit()


# Stat Upgrade Functions
func upgrade_energy_per_tap(amount: int = 1) -> void:
	energy_per_tap += amount


func upgrade_luck(amount: float = 0.01) -> void:
	luck = minf(luck + amount, MAX_LUCK)


func upgrade_max_hp(amount: int = 1) -> void:
	max_hp += amount
	hp = max_hp
	hp_changed.emit()


# Getters
func get_energy_per_tap() -> int:
	return energy_per_tap


func get_luck() -> float:
	return luck


func get_hp() -> int:
	return hp


func get_max_hp() -> int:
	return max_hp


func get_energy() -> int:
	return energy


func get_play_time() -> float:
	return play_time
