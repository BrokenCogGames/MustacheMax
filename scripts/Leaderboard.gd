extends Node2D

func _ready():
	$BackButton.grab_focus()

func _on_BackButton_pressed():
	yield(get_tree().create_timer(0.4), "timeout")
	get_tree().change_scene("res://scenes/MainMenu.tscn")

func _on_BackButton_focus_entered():
	$BackButton.set_modulate(Color("feffb7"))
