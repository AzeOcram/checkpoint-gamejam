extends Resource
class_name QTEData


enum Result {
	SUCCESS,
	FAILURE
}


@export_category("Basic Information")

@export var title: String = "QTE"
@export_multiline var description: String = ""
@export var duration: float = 5.0


@export_category("Visual Resources")

@export var background_texture: Texture2D
@export var character_texture: Texture2D
@export var supporting_textures: Array[Texture2D] = []
