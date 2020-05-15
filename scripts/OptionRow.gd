extends HBoxContainer

signal on_off_changed(enabled)
signal percentage_changed(value)

enum OptionType {
	PERCENTAGE,
	ON_OFF
}

export var option_name = "option"
export var current_value = 100
export var min_value = 0
export var max_value = 100
export(OptionType) var option_type = OptionType.PERCENTAGE
export var bool_value = false

func _ready():
	$Option.text = option_name
	if option_type == OptionType.PERCENTAGE:
		$HBoxContainer/Value.text = "%d%%" % current_value
	elif option_type == OptionType.ON_OFF:
		if bool_value:
			$HBoxContainer/Value.text = "ON"
		else:
			$HBoxContainer/Value.text = "OFF"

func _on_LeftButton_pressed():
	if option_type == OptionType.PERCENTAGE:
		if current_value - 10 >= min_value:
			current_value -= 10
			emit_signal("percentage_changed", current_value)
	elif option_type == OptionType.ON_OFF:
		bool_value = !bool_value
		emit_signal("on_off_changed", bool_value)
		
	if option_type == OptionType.PERCENTAGE:
		$HBoxContainer/Value.text = "%d%%" % current_value
	elif option_type == OptionType.ON_OFF:
		if bool_value:
			$HBoxContainer/Value.text = "ON"
		else:
			$HBoxContainer/Value.text = "OFF"

func _on_RightButton_pressed():
	if option_type == OptionType.PERCENTAGE:
		if current_value + 10 <= max_value:
			current_value += 10
			emit_signal("percentage_changed", current_value)
	elif option_type == OptionType.ON_OFF:
		bool_value = !bool_value
		emit_signal("on_off_changed", bool_value)
		
	if option_type == OptionType.PERCENTAGE:
		$HBoxContainer/Value.text = "%d%%" % current_value
	elif option_type == OptionType.ON_OFF:
		if bool_value:
			$HBoxContainer/Value.text = "ON"
		else:
			$HBoxContainer/Value.text = "OFF"
