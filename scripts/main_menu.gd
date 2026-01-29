extends Control

@onready var polygon_container = $PolygonContainer
@onready var title_label = $UI/TitleLabel
@onready var play_button = $UI/PlayButton

func _ready():
	# Animation for UI entrance
	title_label.modulate.a = 0
	play_button.modulate.a = 0
	
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(title_label, "modulate:a", 1.0, 1.5)
	tween.tween_property(title_label, "position:y", title_label.position.y, 1.5).from(title_label.position.y - 50)
	tween.tween_property(play_button, "modulate:a", 1.0, 1.5).set_delay(0.5)
	tween.tween_property(play_button, "position:y", play_button.position.y, 1.5).from(play_button.position.y + 50).set_delay(0.5)

func _process(delta):
	# Slowly rotate the polygon container
	polygon_container.rotation += 0.2 * delta
