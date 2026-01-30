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
