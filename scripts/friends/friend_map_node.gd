extends Control
class_name FriendMapNode


signal friend_clicked(friend_node: FriendMapNode)


@onready var texture_button: TextureButton = $TextureButton


const ALERT_COLOR := Color(1.0, 0.85, 0.2)
const ALERT_URGENT_COLOR := Color(1.0, 0.25, 0.2)
const ALERT_URGENT_SECONDS := 3.0
# Above every seat, below the friend info panel (z 100).
const ALERT_Z_INDEX := 90

var data: FriendData
var alert_label: Label


func _ready() -> void:
	texture_button.pressed.connect(_on_pressed)

	alert_label = Label.new()
	alert_label.visible = false
	alert_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	alert_label.add_theme_font_size_override(&"font_size", 8)
	alert_label.add_theme_constant_override(&"outline_size", 3)
	alert_label.add_theme_color_override(&"font_outline_color", Color.BLACK)
	add_child(alert_label)


func setup(friend_data: FriendData) -> void:
	data = friend_data

	if data == null:
		return

	texture_button.texture_normal = data.sprite
	texture_button.size = data.sprite.get_size()

	update_appearance()
	start_animation()


func update_appearance() -> void:
	if data == null:
		return

	if data.unlocked:
		texture_button.modulate = Color.WHITE
	else:
		texture_button.modulate = Color(0.35, 0.35, 0.35, 1.0)


func show_alert(time_left: float) -> void:
	var pop_in := not alert_label.visible

	alert_label.text = "! %d" % ceili(time_left)
	alert_label.add_theme_color_override(
		&"font_color",
		ALERT_URGENT_COLOR if time_left <= ALERT_URGENT_SECONDS else ALERT_COLOR
	)
	alert_label.visible = true
	z_index = ALERT_Z_INDEX
	alert_label.size = alert_label.get_minimum_size()
	alert_label.position = Vector2(
		(texture_button.size.x - alert_label.size.x) / 2.0 + texture_button.position.x,
		-alert_label.size.y
	)

	if pop_in:
		alert_label.pivot_offset = alert_label.size / 2.0
		alert_label.scale = Vector2.ZERO
		alert_label.modulate.a = 0.0
		var tween := create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tween.tween_property(alert_label, "scale", Vector2.ONE, 0.2)
		tween.tween_property(alert_label, "modulate:a", 1.0, 0.15)


func hide_alert() -> void:
	alert_label.visible = false
	z_index = 0


func start_animation() -> void:
	var showing_sprite_1 := true
	
	while true:
		await get_tree().create_timer(randf_range(1.0, 3.0)).timeout

		if data == null:
			return

		showing_sprite_1 = !showing_sprite_1

		if showing_sprite_1:
			texture_button.texture_normal = data.sprite
		else:
			texture_button.texture_normal = data.sprite2


func _on_pressed() -> void:
	print("CLICKED FRIEND: ", data.friend_name)
	friend_clicked.emit(self)
