extends Node2D

var velocity := Vector2.ZERO
var rotation_speed := 0.0
var screen_size: Vector2

@onready var polygon_2d: Polygon2D = $Polygon2D
@onready var line_2d: Line2D = $Line2D

var current_polygon: PackedVector2Array

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

func _process(delta):
	position += velocity * delta
	rotation += rotation_speed * delta
	
	# Wrap logic
	if position.x < -100: position.x = screen_size.x + 100
	elif position.x > screen_size.x + 100: position.x = -100
	if position.y < -100: position.y = screen_size.y + 100
	elif position.y > screen_size.y + 100: position.y = -100

func apply_slice(line_start: Vector2, line_end: Vector2) -> bool:
	# Convert world line to local coordinates
	var local_start = to_local(line_start)
	var local_end = to_local(line_end)
	
	var fragments = GeometryUtils.slice_polygon(current_polygon, local_start, local_end)
	
	if fragments.size() < 2:
		return false # No cut happened
		
	# Find the largest fragment
	var largest_frag = fragments[0]
	var max_area = GeometryUtils.get_total_area(largest_frag)
	
	for i in range(1, fragments.size()):
		var area = GeometryUtils.get_total_area(fragments[i])
		if area > max_area:
			max_area = area
			largest_frag = fragments[i]
			
	current_polygon = largest_frag
	update_visuals()
	return true
