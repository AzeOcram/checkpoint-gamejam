extends Control


# Stats Shop
#
# Lets the player open the shop and spend Energy on stat upgrades.
# All upgrade rules live in StatsSystem; this only shows them.
# Placeholder UI, the final visual design is not part of this scope.

@onready var toggle_button: Button = $ToggleButton
@onready var shop_panel: PanelContainer = $ShopPanel
@onready var rows: VBoxContainer = $ShopPanel/Rows

@onready var stats_system = get_node("../Systems/StatsSystem")
@onready var energy_system = get_node("../Systems/EnergySystem")

# stat_id -> {"label": Label, "button": Button}
var _rows := {}


func _ready() -> void:
	toggle_button.pressed.connect(_on_toggle_pressed)
	stats_system.stats_changed.connect(update_ui)
	energy_system.energy_changed.connect(update_ui)

	for stat_id in stats_system.get_stat_ids():
		_add_row(stat_id)

	update_ui()


func _on_toggle_pressed() -> void:
	shop_panel.visible = not shop_panel.visible


# Press S to open or close the shop.
func _unhandled_key_input(event: InputEvent) -> void:
	if event.pressed and not event.echo and event.keycode == KEY_S:
		_on_toggle_pressed()


func _add_row(stat_id: String) -> void:
	var row := HBoxContainer.new()
	var label := Label.new()
	var button := Button.new()

	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(stats_system.upgrade.bind(stat_id))

	row.add_child(label)
	row.add_child(button)
	rows.add_child(row)

	_rows[stat_id] = {"label": label, "button": button}


func update_ui() -> void:
	for stat_id in _rows:
		var label: Label = _rows[stat_id].label
		var button: Button = _rows[stat_id].button

		label.text = "%s: %d (Lv %d)" % [
			stats_system.get_stat_name(stat_id),
			stats_system.get_value(stat_id),
			stats_system.get_level(stat_id),
		]

		if stats_system.is_maxed(stat_id):
			button.text = "MAX"
		else:
			button.text = "Upgrade (%d)" % stats_system.get_cost(stat_id)

		button.disabled = not stats_system.can_upgrade(stat_id)
