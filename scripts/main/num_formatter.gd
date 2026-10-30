extends RefCounted
class_name NumberFormatter


static func format_number(value: float) -> String:
	var abs_value := absf(value)
	var formatted_value := value
	var suffix := ""

	if abs_value >= 1_000_000_000:
		formatted_value = value / 1_000_000_000.0
		suffix = "B"
	elif abs_value >= 1_000_000:
		formatted_value = value / 1_000_000.0
		suffix = "M"
	elif abs_value >= 1_000:
		formatted_value = value / 1_000.0
		suffix = "K"

	if suffix.is_empty():
		return str(int(value))

	return ("%0.1f" % formatted_value).trim_suffix(".0") + suffix
