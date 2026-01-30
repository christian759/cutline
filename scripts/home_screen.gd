extends Node2D

@onready var shapes_container = $Shapes
@onready var ui_container = $UI/VBoxContainer
@onready var play_button = $UI/VBoxContainer/PlayButton
@onready var settings_button = $UI/VBoxContainer/SettingsButton

var idle_timer := 0.0
var is_slow_mo := false
var ui_initial_pos := Vector2.ZERO

func _ready():
	ui_initial_pos = ui_container.position
	
	# UI setup
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	
	# Connect hover signals for buttons
	play_button.mouse_entered.connect(_on_button_hover.bind(play_button))
	play_button.mouse_exited.connect(_on_button_unhover.bind(play_button))
	settings_button.mouse_entered.connect(_on_button_hover.bind(settings_button))
	settings_button.mouse_exited.connect(_on_button_unhover.bind(settings_button))

func _process(delta):
	# UI Float effect
	var time = Time.get_ticks_msec() / 1000.0
	ui_container.position.y = ui_initial_pos.y + sin(time * 0.5) * 10.0
	
	# Idle slow-mo logic
	var mouse_velocity = Input.get_last_mouse_velocity().length()
	if mouse_velocity < 10:
		idle_timer += delta
	else:
		if idle_timer > 5.0 and is_slow_mo:
			_set_slow_mo(false)
		idle_timer = 0.0
	
	if idle_timer > 5.0 and not is_slow_mo:
		_set_slow_mo(true)

func _on_button_hover(btn: Button):
	var tween = create_tween()
	tween.tween_property(btn, "scale", Vector2(1.1, 1.1), 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(btn, "modulate:a", 1.0, 0.2)

func _on_button_unhover(btn: Button):
	var tween = create_tween()
	tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(btn, "modulate:a", 0.6 if btn == settings_button else 0.8, 0.3)

func _set_slow_mo(enabled: bool):
	is_slow_mo = enabled
	var target_time_scale = 0.3 if enabled else 1.0
	var tween = create_tween()
	tween.tween_property(Engine, "time_scale", target_time_scale, 2.0).set_trans(Tween.TRANS_SINE)

func _on_play_pressed():
	# Transition to game
	print("Play pressed!")
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_settings_pressed():
	get_tree().change_scene_to_file("res://scenes/settings_screen.tscn")
