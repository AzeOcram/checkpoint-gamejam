extends Control


# Stats Shop
#
# Lets the player open the shop and spend Energy on stat upgrades.
# All upgrade rules live in StatsSystem; this only shows them.
# Placeholder UI, the final visual design is not part of this scope.

const STATS_SHOP_ROW = preload("res://scenes/stats/stats_shop_row.tscn")

@onready var toggle_button: Button = $ToggleButton
@onready var shop_panel: PanelContainer = $ShopPanel
@onready var rows: VBoxContainer = $ShopPanel/Rows

var stats_system
var energy_system

var _rows := {}


func setup(stats_system_ref, energy_system_ref) -> void:
	stats_system = stats_system_ref
	energy_system = energy_system_ref

	stats_system.stats_changed.connect(update_ui)
	energy_system.energy_changed.connect(update_ui)

	for stat_id in stats_system.get_stat_ids():
		_add_row(stat_id)

	update_ui()


func _ready() -> void:
	toggle_button.pressed.connect(_on_toggle_pressed)


func _on_toggle_pressed() -> void:
	shop_panel.visible = not shop_panel.visible


# Press S to open or close the shop.
func _unhandled_key_input(event: InputEvent) -> void:
	if event.pressed and not event.echo and event.keycode == KEY_S:
		_on_toggle_pressed()


func _add_row(stat_id: String) -> void:
	var row = STATS_SHOP_ROW.instantiate()

	rows.add_child(row)
	row.setup(stat_id, stats_system)

	_rows[stat_id] = row


func update_ui() -> void:
	for stat_id in _rows:
		_rows[stat_id].update_ui()
