tool
extends HBoxContainer

export var nickname = "" setget set_nickname
export var time = "00:00" setget set_time

func set_nickname(new_value):
	nickname = new_value.substr(0, 7)
	if get_node("Name") != null:
		$Name.text = "%-7s" % nickname
	
func set_time(new_value):
	time = new_value
	if get_node("Time") != null:
		$Time.text = time
