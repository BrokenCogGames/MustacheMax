extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Player.room_entered_coordinates = $Player.global_position

func _process(delta):
	if Input.is_action_pressed("ui_cancel"):
		get_tree().change_scene("res://scenes/MainMenu.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
