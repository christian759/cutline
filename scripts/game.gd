extends Node2D

# No need for explicit preload if class_name is used

@export var shape_scene: PackedScene
@export var ball_scene: PackedScene
@onready var shape_container = $ShapeContainer
@onready var cut_line_visual = $CanvasLayer/CutLineVisual
@onready var hud = $CanvasLayer/HUD
@onready var score_label = $CanvasLayer/HUD/ScoreLabel
@onready var level_label = $CanvasLayer/HUD/LevelLabel

var current_shape: Node2D = null
var is_dragging := false
var drag_start := Vector2.ZERO

var initial_area := 0.0
var target_ratio := 0.5 # Success threshold
var fail_ratio := 0.45 # Too small threshold
var current_level := 1
var current_score := 0
var game_over := false

func _ready():
	if get_tree().root.has_meta("selected_level"):
		current_level = get_tree().root.get_meta("selected_level")
		get_tree().root.remove_meta("selected_level")
	start_level()

func start_level():
	# Clear old shape
	for child in shape_container.get_children():
		child.queue_free()
	
	game_over = false
	
	# Create new shape
	current_shape = shape_scene.instantiate()
	shape_container.add_child(current_shape)
	
	# Level scaling (Brutal)
	var sides = clamp(3 + int(current_level / 2.0), 3, 10)
	var radius = 220.0 - (current_level * 5.0)
	radius = max(radius, 120.0)
	
	var poly = generate_random_polygon(sides, radius)
	
	var speed = 60.0 + (current_level * 15.0)
	var vel = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * speed
	var rot = randf_range(-0.6, 0.6) * (1.0 + current_level * 0.15)
	
	current_shape.position = get_viewport_rect().size / 2.0
	current_shape.setup(poly, vel, rot)
	
	initial_area = current_shape.get_area()
	
	# Tighten tolerance as level increases
	target_ratio = 0.5 - (current_level * 0.02)
	target_ratio = max(target_ratio, 0.15)
	fail_ratio = target_ratio * 0.85 # 15% margin for error
	
	hud.set_target(target_ratio)
	hud.update_current(1.0)
	level_label.text = "LEVEL " + str(current_level)
	level_label.modulate = Color.WHITE
	
	# Spawn Balls (§4 & §7)
	if current_level >= 6:
		var ball_count = 1 + int((current_level - 1) / 5.0)
		for i in range(ball_count):
			var ball_vel = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * (80.0 + current_level * 10)
			current_shape.add_ball(ball_scene, ball_vel, 12.0)

func generate_random_polygon(sides: int, radius: float) -> PackedVector2Array:
	var points = PackedVector2Array()
	var angle_step = 360.0 / sides
	for i in range(sides):
		var angle = deg_to_rad(i * angle_step + randf_range(-angle_step * 0.2, angle_step * 0.2))
		var r = radius * randf_range(0.7, 1.3)
		points.append(Vector2(cos(angle), sin(angle)) * r)
	return points

func _input(event):
	if game_over: return
	
	# Mobile-Compatible Slicing (§2)
	if event is InputEventScreenTouch or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT):
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
					
	elif (event is InputEventScreenDrag or event is InputEventMouseMotion) and is_dragging:
		cut_line_visual.points = PackedVector2Array([drag_start, event.position])

func perform_cut(start: Vector2, end: Vector2):
	if start.distance_to(end) < 60: return # Minimum swipe length (§2)
	
	var result = current_shape.apply_slice(start, end)
	
	if result == current_shape.CutResult.SUCCESS:
		spawn_cut_fx(start, end)
		check_progress()
	elif result == current_shape.CutResult.HIT_BALL:
		fail_game("HIT BALL!")
	else:
		shake_screen(5.0)

func check_progress():
	var current_area = current_shape.get_area()
	var current_ratio = current_area / initial_area
	
	var previous_ratio = hud.current_ratio
	
	update_hud()
	
	# Crossing Target Feedback (§6)
	if previous_ratio > target_ratio and current_ratio <= target_ratio:
		hud.flash_marker()
		_apply_micro_slow_mo()
	
	if current_ratio < fail_ratio:
		fail_game("OVERSHOT!")
	elif current_ratio <= target_ratio:
		complete_level()

func update_hud():
	var current_area = current_shape.get_area()
	var current_ratio = current_area / initial_area
	hud.update_current(current_ratio)
	
	# Shape outline focus cue (§6)
	var diff = abs(current_ratio - target_ratio)
	if diff < 0.05:
		current_shape.set_outline_thickness(6.0)
	else:
		current_shape.set_outline_thickness(2.0)

func _apply_micro_slow_mo():
	var original_timescale = Engine.time_scale
	Engine.time_scale = 0.2
	await get_tree().create_timer(0.15, true, false, true).timeout
	Engine.time_scale = original_timescale
	
func calculate_stars(precision: float) -> int:
	if precision <= 0.03: return 3
	if precision <= 0.07: return 2
	return 1

func complete_level():
	game_over = true
	var current_area = current_shape.get_area()
	var current_ratio = current_area / initial_area
	var precision = abs(current_ratio - target_ratio)
	var stars = calculate_stars(precision)
	
	var star_text = ""
	for i in range(stars): star_text += "⭐"
	level_label.text = star_text
	level_label.modulate = Color.YELLOW
	
	current_score += stars * current_level * 100
	score_label.text = str(current_score)
	
	# Save progress
	Global.complete_level(current_level, stars)
	
	# Success flash
	var flash = ColorRect.new()
	flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	flash.color = Color(1, 1, 1, 0.4)
	get_tree().root.add_child(flash)
	
	var tween = create_tween()
	tween.tween_property(flash, "modulate:a", 0.0, 0.2)
	tween.finished.connect(flash.queue_free)
	
	current_level += 1
	await get_tree().create_timer(1.0).timeout
	start_level()

func fail_game(reason: String):
	game_over = true
	level_label.text = reason
	level_label.modulate = Color.RED
	
	shake_screen(15.0)
	
	# Collapse effect
	var tween = create_tween()
	tween.tween_property(current_shape, "scale", Vector2.ZERO, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(current_shape, "modulate", Color.RED, 0.4)
	
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://scenes/home_screen.tscn")

func shake_screen(intensity: float):
	var tween = create_tween()
	for i in 6:
		var offset = Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		tween.tween_property(self, "position", offset, 0.04)
	tween.tween_property(self, "position", Vector2.ZERO, 0.04)

func spawn_cut_fx(start: Vector2, end: Vector2):
	var line = Line2D.new()
	add_child(line)
	line.points = PackedVector2Array([start, end])
	line.width = 6.0
	line.default_color = Color.BLACK
	var tween = create_tween()
	tween.tween_property(line, "width", 0.0, 0.4).set_trans(Tween.TRANS_EXPO)
	tween.parallel().tween_property(line, "modulate:a", 0.0, 0.4)
	tween.finished.connect(line.queue_free)
