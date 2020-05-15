extends Control

# Load the music player node
onready var _player = $AudioStreamPlayer

const DEFAULT_VOL_OFFSET = 1

var playing: bool = false
var songs = ["res://audio/8bit.ogg"]
var music_volume = 100
var fx_volume = 100

func play():
	playing = true
	_player.play()

func get_music_volume():
	return music_volume

func set_music_voume(volume: int):
	music_volume = volume
	var volume_f = linear2db(float(volume) / 100.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), volume_f)

func get_fx_volume():
	return fx_volume

func set_fx_voume(volume: int):
	fx_volume = volume
	var volume_f = linear2db(float(volume) / 100.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("FX"), volume_f)

func play_song(song_index: int):
	if song_index < len(songs):
		play_track(songs[song_index])

# Calling this function will load the given track, and play it
func play_track(track_url : String):
	var track = load(track_url)
	_player.stream = track
	self.play()

# Calling this function will stop the music
func stop():
	playing = false
	_player.stop()
