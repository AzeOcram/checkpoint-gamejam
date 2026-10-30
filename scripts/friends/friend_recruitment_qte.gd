extends FriendQTE
class_name FriendRecruitmentQTE

func start(data: QTEData) -> void:
	friend_qte_data = FriendQTEData.new()

	friend_qte_data.question = friend_data.recruitment_question
	friend_qte_data.success_label = friend_data.recruitment_success_label
	friend_qte_data.failure_label = friend_data.recruitment_failure_label
	friend_qte_data.success_feedback = friend_data.recruitment_success_feedback
	friend_qte_data.failure_feedback = friend_data.recruitment_failure_feedback

	super.start(data)
