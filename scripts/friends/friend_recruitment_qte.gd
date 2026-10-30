extends FriendQTE
class_name FriendRecruitmentQTE


func start_recruitment(data: FriendData) -> void:
	friend_data = null

	var qte_data := QTEData.new()
	qte_data.title = data.recruitment_qte_title
	qte_data.description = data.recruitment_question
	qte_data.duration = data.recruitment_qte_duration

	start(qte_data)
