extends Node2D

func _ready():
	$PlayButton.grab_focus()
	if MusicController.playing == false:
		MusicController.play_song(0)

func _on_PlayButton_pressed():
	yield(get_tree().create_timer(0.4), "timeout")
	get_tree().change_scene("res://scenes/BaseLevel.tscn")

func _on_OptionButton_pressed():
	yield(get_tree().create_timer(0.4), "timeout")
	get_tree().change_scene("res://scenes/OptionsMenu.tscn")

func _on_LeaderboardButton_pressed():
	yield(get_tree().create_timer(0.4), "timeout")
	get_tree().change_scene("res://scenes/Leaderboard.tscn")

func _on_PlayButton_focus_entered():
	$PlayButton.set_modulate(Color("feffb7"))

func _on_PlayButton_focus_exited():
	$PlayButton.set_modulate(Color("ffffff"))

func _on_OptionButton_focus_entered():
	$OptionButton.set_modulate(Color("feffb7"))

func _on_OptionButton_focus_exited():
	$OptionButton.set_modulate(Color("ffffff"))

func _on_LeaderboardButton_focus_entered():
	$LeaderboardButton.set_modulate(Color("feffb7"))

func _on_LeaderboardButton_focus_exited():
	$LeaderboardButton.set_modulate(Color("ffffff"))
