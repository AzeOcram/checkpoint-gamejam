extends Node2D

#Attributes
var energy_per_tap: int = 1
var luck: int = 0
var hp: int = 3
var max_hp: int = 3

#Main Functions

#HP Functions
func take_damage(amount: int) -> void:
	hp = max(hp - amount, 0)

func heal(amount: int) -> void:
	hp = min(hp + amount, max_hp)


#Setters
func upgrade_energy_per_tap(amount: int = 1) -> void:
	energy_per_tap += amount

func upgrade_luck(amount: int = 1) -> void:
	luck += amount

func upgrade_max_hp(amount: int = 1) -> void:
	max_hp += amount
	hp += amount

#Getters
func get_energy_per_tap() -> int:
	return energy_per_tap

func get_luck() -> int:
	return luck

func get_hp() -> int:
	return hp

func get_max_hp() -> int:
	return max_hp
