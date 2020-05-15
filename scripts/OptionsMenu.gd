extends Node2D

enum GameOption {
	MUSIC_VOLUME,
	FX_VOLUME,
	SPEEDRUN_TIMER_ENABLE,
	NONE
}

var current_option = GameOption.NONE

func _ready():
	$Menu/VBoxContainer/MusicVolumeOption.grab_focus()

func _process(delta):
	if Input.is_action_just_pressed("ui_left"):
		if current_option == GameOption.MUSIC_VOLUME:
			$Menu/VBoxContainer/MusicVolumeOption._on_LeftButton_pressed()
		elif current_option == GameOption.FX_VOLUME:
			$Menu/VBoxContainer/FXVolumeOption._on_LeftButton_pressed()
		elif current_option == GameOption.SPEEDRUN_TIMER_ENABLE:
			$Menu/VBoxContainer/SpeedRunTimerOption._on_LeftButton_pressed()
	elif Input.is_action_just_pressed("ui_right"):
		if current_option == GameOption.MUSIC_VOLUME:
			$Menu/VBoxContainer/MusicVolumeOption._on_RightButton_pressed()
		elif current_option == GameOption.FX_VOLUME:
			$Menu/VBoxContainer/FXVolumeOption._on_RightButton_pressed()
		elif current_option == GameOption.SPEEDRUN_TIMER_ENABLE:
			$Menu/VBoxContainer/SpeedRunTimerOption._on_RightButton_pressed()

func _on_BackButton_pressed():
	yield(get_tree().create_timer(0.4), "timeout")
	get_tree().change_scene("res://scenes/MainMenu.tscn")

func _on_MusicVolumeOption_percentage_changed(value):
	print("Changed music volume to: %d%%" % value)

func _on_FXVolumeOption_percentage_changed(value):
	print("Changed fx volume to: %d%%" % value)

func _on_SpeedRunTimerOption_on_off_changed(enabled):
	print("Changed speedrun state to: %s" % enabled)

func _on_MusicVolumeOption_focus_entered():
	current_option = GameOption.MUSIC_VOLUME
	$Menu/VBoxContainer/MusicVolumeOption.set_modulate(Color("f0ec70"))

func _on_MusicVolumeOption_focus_exited():
	$Menu/VBoxContainer/MusicVolumeOption.set_modulate(Color("ffffff"))

func _on_FXVolumeOption_focus_entered():
	current_option = GameOption.FX_VOLUME
	$Menu/VBoxContainer/FXVolumeOption.set_modulate(Color("f0ec70"))

func _on_FXVolumeOption_focus_exited():
	$Menu/VBoxContainer/FXVolumeOption.set_modulate(Color("ffffff"))

func _on_SpeedRunTimerOption_focus_entered():
	current_option = GameOption.SPEEDRUN_TIMER_ENABLE
	$Menu/VBoxContainer/SpeedRunTimerOption.set_modulate(Color("f0ec70"))

func _on_SpeedRunTimerOption_focus_exited():
	$Menu/VBoxContainer/SpeedRunTimerOption.set_modulate(Color("ffffff"))

func _on_BackButton_focus_entered():
	current_option = GameOption.NONE
	$BackButton.set_modulate(Color("feffb7"))

func _on_BackButton_focus_exited():
	$BackButton.set_modulate(Color("ffffff"))
