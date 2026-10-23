extends HBoxContainer


@onready var stat_label: Label = $StatLabel
@onready var upgrade_button: Button = $UpgradeButton

var stat_id: String
var stats_system


func setup(id: String, system) -> void:
	stat_id = id
	stats_system = system

	upgrade_button.pressed.connect(_on_upgrade_pressed)

	update_ui()


func _on_upgrade_pressed() -> void:
	stats_system.upgrade(stat_id)


func update_ui() -> void:
	var stat_value = stats_system.get_value(stat_id)
	var stat_name = stats_system.get_stat_name(stat_id)

	if stat_id == "max_hp":
		stat_name = "HP"
		stat_value = Player.hp

		stat_label.text = "%s: %d/%d (Lv %d)" % [
			stat_name,
			stat_value,
			stats_system.get_value(stat_id),
			stats_system.get_level(stat_id),
		]
	else:
		stat_label.text = "%s: %d (Lv %d)" % [
			stat_name,
			stat_value,
			stats_system.get_level(stat_id),
		]

	if stats_system.is_maxed(stat_id):
		upgrade_button.text = "MAX"
	else:
		upgrade_button.text = "Upgrade (%d)" % stats_system.get_cost(stat_id)

	upgrade_button.disabled = not stats_system.can_upgrade(stat_id)
