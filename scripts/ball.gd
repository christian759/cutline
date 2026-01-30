extends Node2D

var velocity := Vector2.ZERO
var radius := 10.0
var color := Color.BLACK

# Reference to the polygon it must stay inside
var parent_polygon: PackedVector2Array

func setup(poly: PackedVector2Array, vel: Vector2, r: float):
	parent_polygon = poly
	velocity = vel
	radius = r
	queue_redraw()

func _draw():
	draw_circle(Vector2.ZERO, radius, color)
	# Add a subtle glow/pulse as requested
	draw_circle(Vector2.ZERO, radius + 2, Color(color.r, color.g, color.b, 0.3))

func _process(delta):
	var next_pos = position + velocity * delta
	
	# Simple bounce logic: if next position is outside, reverse velocity
	# In a real game, you'd want proper collision response, but for "inside a polygon"
	# we can check if the point is still inside.
	if not GeometryUtils.is_point_in_polygon(next_pos, parent_polygon):
		# Find the approximate normal of the edge we hit (simplified)
		# Or just reverse direction for now as a "chaotic" movement
		velocity = - velocity.rotated(randf_range(-0.5, 0.5))
	else:
		position = next_pos

func update_polygon(poly: PackedVector2Array):
	parent_polygon = poly
	if not GeometryUtils.is_point_in_polygon(position, parent_polygon):
		velocity = - velocity
