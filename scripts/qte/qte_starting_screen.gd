extends Control
class_name QTEStartingScreen


# Intro shown before every QTE: the QTE's title and description on a panel
# built only from the classroom tiles, then a 3-2-1 countdown.
#
#   var screen := QTEStartingScreen.new_screen()
#   add_child(screen)
#   await screen.play(qte_data)

const SCENE_PATH := "res://scenes/qte/qte_starting_screen.tscn"

const COUNTDOWN_FROM := 3
const STEP_SECONDS := 0.7

# Columns / rows are in 8px tiles (viewport is 40 x 22.5 tiles).
const PANEL := Rect2i(6, 3, 28, 16)
const DIVIDER_ROW := 5

const FLOOR := Vector2i(12, 13)
const PAPER := Vector2i(9, 8)
const DIVIDER := Vector2i(9, 11)
const TOP_LEFT := Vector2i(7, 0)
const TOP := Vector2i(8, 0)
const TOP_RIGHT := Vector2i(10, 0)
const LEFT := Vector2i(7, 2)
const RIGHT := Vector2i(10, 2)
const BOTTOM_LEFT := Vector2i(7, 5)
const BOTTOM := Vector2i(8, 5)
const BOTTOM_RIGHT := Vector2i(10, 5)

# Floor sits under the panel so the frame tiles' transparent pixels show floor.
@onready var floor_layer: TileMapLayer = $Floor
@onready var tiles: TileMapLayer = $Tiles
@onready var title_label: Label = $TitleLabel
@onready var description_label: Label = $DescriptionLabel
@onready var countdown_label: Label = $CountdownLabel


static func new_screen() -> QTEStartingScreen:
	# load() not preload(): the scene references this script, so preload would be cyclic.
	return load(SCENE_PATH).instantiate()


func _ready() -> void:
	_paint_tiles()
	modulate.a = 0.0


# Returns once the countdown has finished and the screen has faded out.
func play(data: QTEData) -> void:
	title_label.text = data.title
	description_label.text = data.description
	countdown_label.text = ""

	var fade_in := create_tween()
	fade_in.tween_property(self, "modulate:a", 1.0, 0.25)
	await fade_in.finished

	for number in range(COUNTDOWN_FROM, 0, -1):
		countdown_label.text = str(number)
		countdown_label.pivot_offset = countdown_label.size / 2.0
		countdown_label.scale = Vector2(1.6, 1.6)
		var pop := create_tween()
		pop.tween_property(countdown_label, "scale", Vector2.ONE, STEP_SECONDS * 0.6) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		await get_tree().create_timer(STEP_SECONDS).timeout

	var fade_out := create_tween()
	fade_out.tween_property(self, "modulate:a", 0.0, 0.2)
	await fade_out.finished
	queue_free()


func _paint_tiles() -> void:
	var screen_tiles := Vector2i(ceili(size.x / 8.0), ceili(size.y / 8.0))
	for x in screen_tiles.x:
		for y in screen_tiles.y:
			floor_layer.set_cell(Vector2i(x, y), 0, FLOOR)

	var left := PANEL.position.x
	var top := PANEL.position.y
	var right := PANEL.end.x - 1
	var bottom := PANEL.end.y - 1

	for x in range(left, right + 1):
		for y in range(top, bottom + 1):
			_paint(Vector2i(x, y), PAPER)

	for x in range(left + 1, right):
		_paint(Vector2i(x, top), TOP)
		_paint(Vector2i(x, bottom), BOTTOM)
		_paint(Vector2i(x, top + DIVIDER_ROW), DIVIDER)
	for y in range(top + 1, bottom):
		_paint(Vector2i(left, y), LEFT)
		_paint(Vector2i(right, y), RIGHT)

	_paint(Vector2i(left, top), TOP_LEFT)
	_paint(Vector2i(right, top), TOP_RIGHT)
	_paint(Vector2i(left, bottom), BOTTOM_LEFT)
	_paint(Vector2i(right, bottom), BOTTOM_RIGHT)


func _paint(cell: Vector2i, atlas_coords: Vector2i) -> void:
	tiles.set_cell(cell, 0, atlas_coords)
