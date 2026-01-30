extends Node2D

var velocity := Vector2.ZERO
var rotation_speed := 0.0
var screen_size: Vector2
var depth := 1.0 # 0.0 is far, 1.0 is near

@onready var line_2d: Line2D = $Line2D
@onready var polygon_2d: Polygon2D = $Polygon2D

var base_scale := 1.0
var pulse_speed := 0.0
var pulse_timer := 0.0
var initial_pos := Vector2.ZERO

func _ready():
	screen_size = get_viewport_rect().size
	depth = randf_range(0.2, 1.0) # Diverse depths
	initial_pos = position
	
	# Further objects move slower
	var speed_mult = lerp(0.2, 1.0, depth)
	velocity = Vector2(
		randf_range(-60, 60),
		randf_range(-60, 60)
	) * speed_mult
	rotation_speed = randf_range(-0.5, 0.5) * speed_mult
	
	setup_random_shape()
	
	# Scale based on depth
	base_scale = randf_range(0.6, 1.0) * lerp(0.5, 1.2, depth)
	scale = Vector2.ONE * base_scale
	
	# Opacity based on depth
	modulate.a = lerp(0.1, 0.6, depth)
	
	pulse_speed = randf_range(1.0, 3.0)
	pulse_timer = randf_range(0, TAU)

func setup_random_shape():
	var sides = [3, 4, 5, 6, 8, 32].pick_random()
	var radius = randf_range(30, 60)
	var points = PackedVector2Array()
	
	for i in range(sides):
		var angle = deg_to_rad(i * 360.0 / sides)
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	
	var line_points = points.duplicate()
	line_points.append(points[0])
	
	line_2d.points = line_points
	polygon_2d.polygon = points
	
	if randf() > 0.4:
		polygon_2d.color = Color(0.9, 0.9, 0.9, 1.0)
	else:
		polygon_2d.color = Color(1, 1, 1, 0)

func _process(delta):
	# Movement (Internal drift)
	initial_pos += velocity * delta
	rotation += rotation_speed * delta

	# Screen wrap logic (better for background layers)
	if initial_pos.x < -100: initial_pos.x = screen_size.x + 100
	elif initial_pos.x > screen_size.x + 100: initial_pos.x = -100
	if initial_pos.y < -100: initial_pos.y = screen_size.y + 100
	elif initial_pos.y > screen_size.y + 100: initial_pos.y = -100

	# Parallax effect: Shift based on mouse position
	var mouse_offset = (get_global_mouse_position() - screen_size / 2.0)
	var parallax_shift = mouse_offset * (depth - 1.0) * 0.05
	position = initial_pos + parallax_shift

	# Pulse Polish
	pulse_timer += delta * pulse_speed
	var pulse = 1.0 + sin(pulse_timer) * 0.02
	scale = Vector2.ONE * base_scale * pulse
	
	if randf() < 0.01:
		velocity += Vector2(randf_range(-2, 2), randf_range(-2, 2))
