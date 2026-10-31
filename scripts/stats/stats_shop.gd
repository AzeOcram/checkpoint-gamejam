extends Control


# Stats Shop
#
# Displays stat upgrades and lets the player spend Energy.
# All upgrade rules live in StatsSystem; this only shows them.

@onready var heart_texture: Texture2D = preload("res://assets/ui/icons/HP heart.png")
@onready var grey_heart_texture: Texture2D = preload("res://assets/ui/icons/Grey Heart.png")

@onready var close_button: TextureButton = $CloseButton

const CLOSE_NORMAL_SCALE := Vector2(1.0, 1.0)
const CLOSE_HOVER_SCALE := Vector2(1.15, 1.15)


# Energy
@onready var energy_label: Label = $EnergyStat/HBoxContainer/Label
@onready var energy_cost_label: Label = $EnergyStat/HBoxContainer/CostLabel
@onready var energy_upgrade_button: TextureButton = $EnergyStat/HBoxContainer/TextureButton


# Luck
@onready var luck_label: Label = $LuckStat/HBoxContainer/Label
@onready var luck_cost_label: Label = $LuckStat/HBoxContainer/CostLabel
@onready var luck_upgrade_button: TextureButton = $LuckStat/HBoxContainer/TextureButton


# HP
@onready var heart1: TextureRect = $HPStat/HBoxContainer/Heart1
@onready var heart2: TextureRect = $HPStat/HBoxContainer/Heart2
@onready var heart3: TextureRect = $HPStat/HBoxContainer/Heart3
@onready var heart4: TextureRect = $HPStat/HBoxContainer/Heart4
@onready var heart5: TextureRect = $HPStat/HBoxContainer/Heart5

@onready var hp_cost_label: Label = $HPStat/HBoxContainer/CostLabel
@onready var hp_upgrade_button: TextureButton = $HPStat/HBoxContainer/TextureButton


var stats_system
var energy_system


func _ready() -> void:
	add_to_group(&"blocks_tap")
	close_button.set_meta(&"sfx_press", &"menu_close")
	for button in [energy_upgrade_button, luck_upgrade_button, hp_upgrade_button]:
		button.set_meta(&"sfx_press", &"")
		button.set_meta(&"sfx_blocked", &"cant_afford")
	close_button.pressed.connect(_on_close_pressed)
	close_button.mouse_entered.connect(_on_close_hover)
	close_button.mouse_exited.connect(_on_close_unhover)

	energy_upgrade_button.pressed.connect(_on_energy_upgrade_pressed)
	luck_upgrade_button.pressed.connect(_on_luck_upgrade_pressed)
	hp_upgrade_button.pressed.connect(_on_hp_upgrade_pressed)

	Player.hp_changed.connect(update_ui)
	Player.luck_changed.connect(update_luck)

	# Make sure cost labels are visible.
	energy_cost_label.visible = true
	luck_cost_label.visible = true
	hp_cost_label.visible = true


func _on_close_hover() -> void:
	var tween := create_tween()
	tween.tween_property(close_button, "scale", CLOSE_HOVER_SCALE, 0.02)


func _on_close_unhover() -> void:
	var tween := create_tween()
	tween.tween_property(close_button, "scale", CLOSE_NORMAL_SCALE, 0.02)

func setup(stats_system_ref, energy_system_ref) -> void:
	stats_system = stats_system_ref
	energy_system = energy_system_ref

	stats_system.stats_changed.connect(update_ui)
	energy_system.energy_changed.connect(update_ui)

	update_ui()


func update_ui() -> void:
	update_energy()
	update_luck()
	update_hp()


func update_energy() -> void:
	var value: int = stats_system.get_value("energy_per_tap")
	var level: int = stats_system.get_level("energy_per_tap")
	var cost = stats_system.get_cost("energy_per_tap")

	print("ENERGY COST: ", cost, " | TYPE: ", typeof(cost))

	energy_label.text = "%d (Lv %d)  " % [
		value,
		level,
	]

	if stats_system.is_maxed("energy_per_tap"):
		energy_cost_label.text = "MAX"
	else:
		energy_cost_label.text = str(cost)

	energy_upgrade_button.disabled = not stats_system.can_upgrade("energy_per_tap")


func update_luck() -> void:
	var value: float = Player.luck * 100.0
	var level: int = stats_system.get_level("luck")
	var cost = stats_system.get_cost("luck")

	print("LUCK COST: ", cost, " | TYPE: ", typeof(cost))

	luck_label.text = str(value) + "% (Lv " + str(level) + ")"

	if stats_system.is_maxed("luck"):
		luck_cost_label.text = "MAX"
	else:
		luck_cost_label.text = str(cost)

	luck_upgrade_button.disabled = not stats_system.can_upgrade("luck")

func update_hp() -> void:
	var current_hp: int = Player.hp
	var max_hp: int = stats_system.get_value("max_hp")
	var cost = stats_system.get_cost("max_hp")

	print("HP COST: ", cost, " | TYPE: ", typeof(cost))

	var hearts: Array[TextureRect] = [
		heart1,
		heart2,
		heart3,
		heart4,
		heart5,
	]

	for i in range(hearts.size()):
		if i < max_hp:
			hearts[i].visible = true

			if i < current_hp:
				hearts[i].texture = heart_texture
			else:
				hearts[i].texture = grey_heart_texture
		else:
			hearts[i].visible = false

	if stats_system.is_maxed("max_hp"):
		hp_cost_label.text = "MAX"
	else:
		hp_cost_label.text = str(cost)

	hp_upgrade_button.disabled = not stats_system.can_upgrade("max_hp")


func _on_energy_upgrade_pressed() -> void:
	print("ENERGY BUTTON PRESSED")
	_upgrade("energy_per_tap")


func _on_luck_upgrade_pressed() -> void:
	print("LUCK BUTTON PRESSED")
	_upgrade("luck")


func _on_hp_upgrade_pressed() -> void:
	print("HP BUTTON PRESSED")
	_upgrade("max_hp")


func _upgrade(stat_id: String) -> void:
	SFX.play(&"purchase" if stats_system.upgrade(stat_id) else &"cant_afford")


func _on_close_pressed() -> void:
	hide()
