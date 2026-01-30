extends Node

class_name GeometryUtils

## Slices a polygon into two using a line defined by two points.
## Returns an array of PackedVector2Arrays (results of the split).
static func slice_polygon(polygon: PackedVector2Array, line_start: Vector2, line_end: Vector2) -> Array[PackedVector2Array]:
	var result: Array[PackedVector2Array] = []
	
	if polygon.size() < 3:
		return result
		
	# Create a very large bounding polygon for each side of the line
	# This is a simplified "half-plane" approach
	var dir = (line_end - line_start).normalized()
	var normal = Vector2(-dir.y, dir.x) * 10000.0 # Large enough to cover screen
	
	# Polygon A (one side)
	var poly_a = PackedVector2Array([
		line_start - dir * 10000.0,
		line_end + dir * 10000.0,
		line_end + dir * 10000.0 + normal,
		line_start - dir * 10000.0 + normal
	])
	
	# Polygon B (other side)
	var poly_b = PackedVector2Array([
		line_start - dir * 10000.0,
		line_end + dir * 10000.0,
		line_end + dir * 10000.0 - normal,
		line_start - dir * 10000.0 - normal
	])
	
	var intersect_a = Geometry2D.intersect_polygons(polygon, poly_a)
	var intersect_b = Geometry2D.intersect_polygons(polygon, poly_b)
	
	for p in intersect_a:
		result.append(p)
	for p in intersect_b:
		result.append(p)
		
	return result

static func get_total_area(polygon: PackedVector2Array) -> float:
	var area = 0.0
	var n = polygon.size()
	if n < 3:
		return 0.0
	
	for i in range(n):
		var p1 = polygon[i]
		var p2 = polygon[(i + 1) % n]
		area += p1.x * p2.y - p2.x * p1.y
		
	return abs(area) * 0.5

## Returns true if a segment between 'p1' and 'p2' intersects a circle at 'center' with 'radius'.
static func segment_intersects_circle(p1: Vector2, p2: Vector2, center: Vector2, radius: float) -> bool:
	var d = p2 - p1
	var f = p1 - center
	
	var a = d.dot(d)
	var b = 2.0 * f.dot(d)
	var c = f.dot(f) - radius * radius
	
	var discriminant = b * b - 4.0 * a * c
	if discriminant < 0:
		return false
	
	discriminant = sqrt(discriminant)
	var t1 = (-b - discriminant) / (2.0 * a)
	var t2 = (-b + discriminant) / (2.0 * a)
	
	if t1 >= 0 and t1 <= 1:
		return true
	if t2 >= 0 and t2 <= 1:
		return true
		
	return false

## Returns true if a point is inside a polygon.
static func is_point_in_polygon(point: Vector2, polygon: PackedVector2Array) -> bool:
	return Geometry2D.is_point_in_polygon(point, polygon)
