extends RigidBody2D

@export var initial_velocity = Vector2(400, 400)
@export var ball_color = Color(0.2, 0.6, 1.0) # Default blue

func _ready():
	# Apply initial push
	linear_velocity = initial_velocity.rotated(randf() * TAU)
	
	# Set color if there's a sprite or polygon
	if has_node("Color"):
		$Color.color = ball_color
	
	# Ensure high bounciness (this should usually be in PhysicsMaterial)
	# but we can also tweak things here if needed.
	pass

func _physics_process(_delta):
	# Keep velocity consistent to avoid losing momentum in a "minimalist" feel
	# Often in these concepts, balls don't slow down much
	if linear_velocity.length() < 300:
		linear_velocity = linear_velocity.normalized() * 400
