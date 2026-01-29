extends RigidBody2D

@export var initial_velocity = Vector2(400, 400)
@export var ball_color = Color(0.2, 0.6, 1.0) # Default blue

func _ready():
	# Apply initial push
	linear_velocity = initial_velocity.rotated(randf() * TAU)
	
	# Set color if there's a sprite or polygon
	if has_node("Polygon2D"):
		$Polygon2D.color = ball_color
		$Polygon2D.polygon = _generate_circle_points(15, 32)
	if has_node("Shadow"):
		$Shadow.polygon = _generate_circle_points(15, 32)

func _generate_circle_points(radius: float, count: int) -> PackedVector2Array:
	var points = PackedVector2Array()
	for i in range(count):
		var angle = deg_to_rad(i * 360.0 / count)
		points.push_back(Vector2(cos(angle), sin(angle)) * radius)
	return points

func _physics_process(_delta):
	# Keep velocity consistent to avoid losing momentum in a "minimalist" feel
	# Often in these concepts, balls don't slow down much
	if linear_velocity.length() < 300:
		linear_velocity = linear_velocity.normalized() * 400
