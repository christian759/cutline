extends CanvasLayer

@onready var area_fill = $AreaBarBG/AreaFill
@onready var target_marker = $AreaBarBG/TargetMarker
@onready var current_label = $CurrentAreaLabel
@onready var target_label = $TargetAreaLabel
@onready var bar_bg = $AreaBarBG

var bar_width := 0.0
var current_ratio := 1.0
var target_ratio := 0.5

func _ready():
	bar_width = bar_bg.size.x
	# Ensure the fill is child of BG or correctly positioned
	area_fill.size.x = bar_width

func set_target(ratio: float):
	target_ratio = ratio
	# Protect against zero bar_width if not ready
	if bar_width == 0:
		await get_tree().process_frame
		bar_width = bar_bg.size.x
		
	target_marker.position.x = bar_width * target_ratio
	target_label.text = "TARGET: %d%%" % int(target_ratio * 100)

func update_current(ratio: float):
	current_ratio = clamp(ratio, 0.0, 1.0)
	
	# Smooth animation for the bar
	var tween = create_tween()
	tween.tween_property(area_fill, "size:x", bar_width * current_ratio, 0.3).set_trans(Tween.TRANS_CUBIC)
	
	current_label.text = "CURRENT: %d%%" % int(current_ratio * 100)
	
	# Feedback Cues (§6)
	_handle_feedback()

func _handle_feedback():
	var diff = abs(current_ratio - target_ratio)
	
	# Area bar pulse and color change
	if diff < 0.05:
		# Intensity increased
		var tween = create_tween()
		tween.tween_property(area_fill, "modulate", Color.RED if diff < 0.02 else Color.ORANGE, 0.2)
		
		# Subtle pulse
		var pulse_tween = create_tween()
		pulse_tween.tween_property(bar_bg, "scale", Vector2(1.02, 1.1), 0.1)
		pulse_tween.tween_property(bar_bg, "scale", Vector2(1.0, 1.0), 0.1)
	else:
		area_fill.modulate = Color.BLACK # Default fill color as per §2

func flash_marker():
	var tween = create_tween()
	target_marker.modulate = Color.WHITE
	tween.tween_property(target_marker, "modulate", Color.RED, 0.1)
	tween.tween_property(target_marker, "modulate", Color.WHITE, 0.1)
	tween.tween_property(target_marker, "modulate", Color.RED, 0.1)
