extends Control

@onready var title_label = $VBoxContainer/TitleLabel
@onready var home_button = $VBoxContainer/HBoxContainer/HomeButton
@onready var replay_button = $VBoxContainer/HBoxContainer/ReplayButton

func setup(reason: String):
	title_label.text = reason
	visible = true
	
	# Fade in animation
	modulate.a = 0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
	
	# Scale animation
	scale = Vector2.ZERO
	var s_tween = create_tween()
	s_tween.tween_property(self, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_home_pressed():
	get_tree().change_scene_to_file("res://scenes/home_screen.tscn")

func _on_replay_pressed():
	# This will be handled by the game.gd signal or call
	get_tree().reload_current_scene()
