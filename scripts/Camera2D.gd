extends Camera2D

var is_moving = false

func _process(delta):
	var pos = get_node("../Player").global_position - Vector2(0, 16)
	var x = floor(pos.x / 320) * 320
	var y = floor(pos.y / 180) * 180
	
	if self.global_position != Vector2(x, y) and is_moving == false:
		get_node("../Player").room_entered_coordinates = pos + Vector2(0, 16)
		is_moving = true
		get_tree().paused = true
		$Tween.interpolate_property(self, "global_position", self.global_position, Vector2(x, y), 0.5, Tween.TRANS_LINEAR)
		$Tween.start()
		yield($Tween, "tween_completed")
		get_tree().paused = false
		print("done")
		is_moving = false

func _on_CameraArea_body_entered(body):
	var lightbulb = body as LightBulb
	if lightbulb != null:
		print("Found: %s" % body.name)
		#if lightbulb.light_has_been_turned_on:
		#	lightbulb.light_on = true

func _on_CameraArea_body_exited(body):
	var lightbulb = body as LightBulb
	if lightbulb != null:
		#lightbulb.light_on = false
		print("Lost: %s" % body.name)
