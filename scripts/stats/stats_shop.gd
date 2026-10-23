extends Control


# Stats Shop
#
# Displays stat upgrades and lets the player spend Energy.
# All upgrade rules live in StatsSystem; this only shows them.
# Placeholder UI, the final visual design is not part of this scope.

const STATS_SHOP_ROW = preload("res://scenes/stats/stats_shop_row.tscn")

@onready var rows: VBoxContainer = $ShopPanel/VBoxContainer/Rows
@onready var close_button: Button = $ShopPanel/VBoxContainer/CloseButton

var stats_system
var energy_system

var _rows := {}


func _ready() -> void:
	close_button.pressed.connect(_on_close_pressed)
	Player.hp_changed.connect(update_ui)


func setup(stats_system_ref, energy_system_ref) -> void:
	stats_system = stats_system_ref
	energy_system = energy_system_ref

	stats_system.stats_changed.connect(update_ui)
	energy_system.energy_changed.connect(update_ui)

	for stat_id in stats_system.get_stat_ids():
		_add_row(stat_id)

	update_ui()


func _add_row(stat_id: String) -> void:
	var row = STATS_SHOP_ROW.instantiate()

	rows.add_child(row)
	row.setup(stat_id, stats_system)

	_rows[stat_id] = row


func update_ui() -> void:
	for stat_id in _rows:
		_rows[stat_id].update_ui()


func _on_close_pressed() -> void:
	get_parent().hide()
