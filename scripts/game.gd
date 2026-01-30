extends Node2D

@export var shape_scene: PackedScene
@onready var shape_container = $ShapeContainer
@onready var cut_line_visual = $CanvasLayer/CutLineVisual
@onready var progress_bar = $CanvasLayer/HUD/ProgressBar
@onready var score_label = $CanvasLayer/HUD/ScoreLabel
@onready var level_label = $CanvasLayer/HUD/LevelLabel

var current_shape: Node2D = null
var is_dragging := false
var drag_start := Vector2.ZERO

var initial_area := 0.0
var target_area_ratio := 0.6 # Reduce to 60%
var current_level := 1
var current_score := 0
var game_over := false

func _ready():
	start_level()

func start_level():
	# Clear old shape
	for child in shape_container.get_children():
		child.queue_free()
	
	# Create new shape
	current_shape = shape_scene.instantiate()
	shape_container.add_child(current_shape)
	
	# Level scaling
	var sides = clamp(3 + (current_level / 2), 3, 12)
	var radius = 200.0
	var poly = generate_random_polygon(sides, radius)
	
	var speed = 50.0 + (current_level * 10.0)
	var vel = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * speed
	var rot = randf_range(-0.5, 0.5) * (1.0 + current_level * 0.1)
	
	current_shape.position = get_viewport_rect().size / 2.0
	current_shape.setup(poly, vel, rot)
	
	initial_area = current_shape.get_area()
	target_area_ratio = clamp(0.6 - (current_level * 0.03), 0.2, 0.6)
	
	update_hud()
	level_label.text = "LEVEL " + str(current_level)

func generate_random_polygon(sides: int, radius: float) -> PackedVector2Array:
	var points = PackedVector2Array()
	for i in range(sides):
		var angle = deg_to_rad(i * 360.0 / sides)
		# Add some randomness to radii
		var r = radius * randf_range(0.8, 1.2)
		points.append(Vector2(cos(angle), sin(angle)) * r)
	return points

func _input(event):
	if game_over: return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				drag_start = event.position
				cut_line_visual.points = PackedVector2Array([drag_start, drag_start])
				cut_line_visual.visible = true
			else:
				if is_dragging:
					is_dragging = false
					cut_line_visual.visible = false
					perform_cut(drag_start, event.position)
					
	elif event is InputEventMouseMotion and is_dragging:
		cut_line_visual.points = PackedVector2Array([drag_start, event.position])

func perform_cut(start: Vector2, end: Vector2):
	if start.distance_to(end) < 20: return
	
	if current_shape and current_shape.apply_slice(start, end):
		check_progress()
		# Visual feedback (flash line)
		spawn_cut_fx(start, end)
	else:
		# Near miss shake
		shake_screen()

func check_progress():
	var current_area = current_shape.get_area()
	var current_ratio = current_area / initial_area
	
	update_hud()
	
	if current_ratio <= target_area_ratio:
		# Success!
		if current_ratio < target_area_ratio - 0.1:
			# Too small - FAIL logic
			fail_game("TOO SMALL!")
		else:
			# SUCCESS logic
			complete_level()
	elif current_ratio < 0.1: # Catch-all sanity fail
		fail_game("TOO SMALL!")

func update_hud():
	var current_ratio = current_shape.get_area() / initial_area
	# Progress bar: 1.0 is full size, Target is some value in between
	# We want to reach Target. If < Target, we win.
	progress_bar.value = current_ratio * 100.0
	# Mark target on bar? (Using a simple shader or child node would be better)
	
func complete_level():
	current_score += current_level * 100
	score_label.text = str(current_score)
	current_level += 1
	
	# Transition effect
	var tween = create_tween()
	tween.tween_property(current_shape, "scale", Vector2.ZERO, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.finished.connect(start_level)

func fail_game(reason: String):
	game_over = true
	print("Game Over: " + reason)
	# Collapse effect
	var tween = create_tween()
	tween.tween_property(current_shape, "modulate:a", 0.0, 0.5)
	tween.parallel().tween_property(current_shape, "scale", Vector2(0.1, 0.1), 0.5)
	
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/home_screen.tscn")

func shake_screen():
	var tween = create_tween()
	for i in 4:
		var offset = Vector2(randf_range(-5, 5), randf_range(-5, 5))
		tween.tween_property(self, "position", offset, 0.05)
	tween.tween_property(self, "position", Vector2.ZERO, 0.05)

func spawn_cut_fx(start: Vector2, end: Vector2):
	var line = Line2D.new()
	add_child(line)
	line.points = PackedVector2Array([start, end])
	line.width = 4.0
	line.default_color = Color.WHITE
	var tween = create_tween()
	tween.tween_property(line, "modulate:a", 0.0, 0.3)
	tween.finished.connect(line.queue_free)
