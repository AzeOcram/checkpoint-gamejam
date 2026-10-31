
extends Node

signal stats_changed


# Stats System
#
# Owns stat upgrades: levels, costs, caps, spending Energy and the Luck roll.
# The actual stat values are stored in Player.
# Energy is spent through EnergySystem.

# shortcut: placeholder caps and base costs, tune once balancing starts.
# Level is derived from the Player's value, so there is one source of truth.
const STATS := {
	"energy_per_tap": {
		"name": "Energy Per Tap",
		"start": 1,
		"max": 10,
		"base_cost": 10,
		"upgrade": "upgrade_energy_per_tap",
	},
	"luck": {
		"name": "Luck",
		"start": 0,
		"max": 10,
		"base_cost": 25,
		"upgrade": "upgrade_luck",
	},
	"max_hp": {
		"name": "Max HP",
		"start": 3,
		"max": 5,
		"base_cost": 50,
		"upgrade": "upgrade_max_hp",
	},
}

# Each Luck point gives this chance to skip a QTE.
const LUCK_CHANCE_PER_POINT := 0.025

# Friend and shop Luck stack; the skip chance stops here so event QTEs keep appearing.
const MAX_SKIP_CHANCE := 0.5

# Shop Luck
const MAX_SHOP_LUCK: float = 0.25
const LUCK_UPGRADE_AMOUNT: float = 0.025

var shop_luck: float = 0.0
var energy_system


func setup(energy_system_ref) -> void:
	energy_system = energy_system_ref


func get_stat_ids() -> Array:
	return STATS.keys()


func get_stat_name(stat_id: String) -> String:
	return STATS[stat_id].name


# Returns the stat's current value, stored in Player.
func get_value(stat_id: String) -> int:
	if stat_id == "luck":
		return int(round(shop_luck / LUCK_UPGRADE_AMOUNT))

	return Player.get(stat_id)


func get_level(stat_id: String) -> int:
	return get_value(stat_id) - STATS[stat_id].start


# shortcut: linear cost (base_cost * (level + 1)), swap for a curve if too cheap.
func get_cost(stat_id: String) -> int:
	return STATS[stat_id].base_cost * (get_level(stat_id) + 1)


func is_maxed(stat_id: String) -> bool:
	if stat_id == "luck":
		return shop_luck >= MAX_SHOP_LUCK

	return get_value(stat_id) >= STATS[stat_id].max


func can_upgrade(stat_id: String) -> bool:
	if energy_system == null:
		return false

	return not is_maxed(stat_id) and energy_system.can_afford(get_cost(stat_id))


# Attempts to buy one upgrade.
# Returns true if the stat was upgraded.
func upgrade(stat_id: String) -> bool:
	if energy_system == null:
		return false

	if is_maxed(stat_id):
		return false

	if not energy_system.spend(get_cost(stat_id)):
		return false

	if stat_id == "luck":
		shop_luck = minf(shop_luck + LUCK_UPGRADE_AMOUNT, MAX_SHOP_LUCK)
		Player.upgrade_luck(LUCK_UPGRADE_AMOUNT)
		Player.luck_changed.emit()
	else:
		Player.call(STATS[stat_id].upgrade)

	stats_changed.emit()
	return true


# Returns the chance (0.0 - 1.0) that a QTE is skipped.
func get_luck_chance() -> float:
	return Player.get_luck() * LUCK_CHANCE_PER_POINT


# Luck check for the QTE system. Call before showing a QTE.
# Returns true if the QTE should be skipped (treat it as SUCCESS).
# The roll can be passed in for testing.
func roll_luck_skip() -> bool:
	return randf() < minf(Player.luck, MAX_SKIP_CHANCE)


# Resets shop upgrade tracking when starting a new game.
func restart() -> void:
	shop_luck = 0.0
	stats_changed.emit()
