extends Control

func _ready():
	# Simple fade in/out splash
	modulate.a = 0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1.0)
	tween.tween_interval(1.5)
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	tween.finished.connect(_on_finished)

func _on_finished():
	get_tree().change_scene_to_file("res://scenes/home_screen.tscn")
