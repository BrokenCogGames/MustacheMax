tool
extends CanvasLayer

export var lights_found = 0 setget set_lights_found
export var lights_total = 3 setget set_lights_total

func set_lights_found(new_value):
	lights_found = new_value
	update()
	
func set_lights_total(new_value):
	lights_total = new_value
	update()

func update():
	print("set")
	if get_node("UI/Label") != null:
		$UI/Label.text = "%d/%d" % [lights_found, lights_total]

func found_new_light():
	set_lights_found(lights_found + 1)
	if lights_found >= lights_total:
		GameController.win()
