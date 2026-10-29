extends Resource
class_name QTEData


enum Result {
	SUCCESS,
	FAILURE
}


enum Difficulty {
	EASY,
	MODERATE,
	HARD
}


# More friends, harder QTEs.
static func difficulty_for_friends(friends: int) -> Difficulty:
	if friends >= 6:
		return Difficulty.HARD
	if friends >= 3:
		return Difficulty.MODERATE
	return Difficulty.EASY


@export var title: String = "QTE"
@export_multiline var description: String = ""
@export var duration: float = 5.0
