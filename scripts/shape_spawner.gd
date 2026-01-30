extends Node2D

@export var shape_scene: PackedScene
@export var shape_count := 20

func _ready():
	# Use a slight delay to ensure the scene tree is ready
	call_deferred("spawn_shapes")

func spawn_shapes():
	for i in shape_count:
		spawn_shape()

func spawn_shape():
	if not shape_scene:
		return
		
	var shape = shape_scene.instantiate()
	var screen_size = get_viewport_rect().size
	shape.position = Vector2(
		randf_range(50, screen_size.x - 50),
		randf_range(50, screen_size.y - 50)
	)
	
	# The parent is HomeScreen, which has a "Shapes" container
	var shapes_container = get_parent().get_node_or_null("Shapes")
	if shapes_container:
		shapes_container.add_child(shape)
	else:
		get_parent().add_child(shape)
