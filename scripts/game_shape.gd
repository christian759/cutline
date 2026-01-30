extends Node2D

# No need for explicit preload if class_name is used

var velocity := Vector2.ZERO
var rotation_speed := 0.0
var screen_size: Vector2

@onready var polygon_2d: Polygon2D = $Polygon2D
@onready var line_2d: Line2D = $Line2D

var current_polygon: PackedVector2Array
var balls: Array[Node2D] = []

enum CutResult {SUCCESS, MISS, HIT_BALL}

func setup(poly: PackedVector2Array, vel: Vector2, rot: float):
	current_polygon = poly
	velocity = vel
	rotation_speed = rot
	screen_size = get_viewport_rect().size
	update_visuals()

func update_visuals():
	polygon_2d.polygon = current_polygon
	var l_points = current_polygon.duplicate()
	l_points.append(current_polygon[0])
	line_2d.points = l_points

func get_area() -> float:
	return GeometryUtils.get_total_area(current_polygon)

func set_outline_thickness(thickness: float):
	line_2d.width = thickness

func _process(delta):
	position += velocity * delta
	rotation += rotation_speed * delta
	
	# Bounce logic (§8)
	var margin = 150.0 # Approximate radius to keep mostly on screen
	if position.x < margin:
		position.x = margin
		velocity.x = abs(velocity.x)
	elif position.x > screen_size.x - margin:
		position.x = screen_size.x - margin
		velocity.x = - abs(velocity.x)
		
	if position.y < margin:
		position.y = margin
		velocity.y = abs(velocity.y)
	elif position.y > screen_size.y - margin:
		position.y = screen_size.y - margin
		velocity.y = - abs(velocity.y)

func apply_slice(line_start: Vector2, line_end: Vector2) -> CutResult:
	var local_start = to_local(line_start)
	var local_end = to_local(line_end)
	
	# Check for ball collisions first (§5 & §6)
	for ball in balls:
		if GeometryUtils.segment_intersects_circle(local_start, local_end, ball.position, ball.radius):
			return CutResult.HIT_BALL
			
	var fragments = GeometryUtils.slice_polygon(current_polygon, local_start, local_end)
	
	if fragments.size() < 2:
		return CutResult.MISS # No cut happened
		
	# Find the largest fragment
	var largest_frag = fragments[0]
	var max_area = GeometryUtils.get_total_area(largest_frag)
	
	for i in range(1, fragments.size()):
		var area = GeometryUtils.get_total_area(fragments[i])
		if area > max_area:
			max_area = area
			largest_frag = fragments[i]
			
	current_polygon = largest_frag
	
	# Update all balls with the new boundary (§4)
	for ball in balls:
		ball.update_polygon(current_polygon)
		
	update_visuals()
	return CutResult.SUCCESS

func add_ball(ball_scene: PackedScene, vel: Vector2, radius: float):
	var ball = ball_scene.instantiate()
	add_child(ball)
	ball.setup(current_polygon, vel, radius)
	# Start at a random point inside
	ball.position = get_random_point_in_polygon()
	balls.append(ball)

func get_random_point_in_polygon() -> Vector2:
	# Use the centroid of the polygon for a safe starting point
	var center = Vector2.ZERO
	if current_polygon.is_empty(): return center
	for p in current_polygon:
		center += p
	return center / current_polygon.size()
