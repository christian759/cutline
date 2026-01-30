extends Control

@onready var grid_container = $ScrollContainer/GridContainer
@onready var level_button_scene = preload("res://scenes/level_button.tscn")

func _ready():
	# Load progress
	Global.load_game()
	
	# Generate level buttons
	for i in range(1, 21): # Show 20 levels for now
		var btn = level_button_scene.instantiate()
		grid_container.add_child(btn)
		
		var is_unlocked = i <= Global.unlocked_levels
		var stars = Global.level_stars.get(str(i), 0)
		
		btn.setup(i, is_unlocked, stars)
		if is_unlocked:
			btn.pressed.connect(_on_level_selected.bind(i))

func _on_level_selected(level: int):
	# Set current level in a global or pass to game scene
	# For now, we can just change scene and let game know
	get_tree().root.set_meta("selected_level", level)
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/home_screen.tscn")
