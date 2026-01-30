extends Node

# Procedural Audio Generator for Cutline
# This allows the game to have sounds without external audio files.

func play_slice():
	_play_tone(1200, 0.05, 0.1) # Sharp, short 'click/cut'

func play_fail():
	_play_tone(150, 0.3, 0.4) # Deep, clean 'thump'

func _play_tone(frequency: float, duration: float, volume: float):
	var player = AudioStreamPlayer.new()
	add_child(player)
	
	var generator = AudioStreamGenerator.new()
	generator.mix_rate = 44100
	generator.buffer_length = duration
	
	player.stream = generator
	player.volume_db = linear_to_db(volume)
	player.play()
	
	var playback = player.get_stream_playback()
	var sample_hz = 44100.0
	var phase = 0.0
	var increment = frequency / sample_hz
	
	var frames_to_fill = playback.get_frames_available()
	for i in range(frames_to_fill):
		playback.push_frame(Vector2.ONE * sin(phase * TAU))
		phase = fmod(phase + increment, 1.0)
	
	await get_tree().create_timer(duration + 0.1).timeout
	player.queue_free()
