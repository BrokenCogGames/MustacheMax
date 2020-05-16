extends CanvasLayer

func _on_Timer_timeout():
	$Label.text = str(Engine.get_frames_per_second())
