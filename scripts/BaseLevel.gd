extends Node2D

export var total_light_bulbs = 3 

# Called when the node enters the scene tree for the first time.
func _ready():
	$LightbulbsFound.lights_total = total_light_bulbs
	$LightbulbsFound.lights_found = 0
	$Player.room_entered_coordinates = $Player.global_position
	$SpeedRunTimer.start()

func _process(delta):
	if Input.is_action_pressed("ui_cancel"):
		get_tree().change_scene("res://scenes/MainMenu.tscn")
