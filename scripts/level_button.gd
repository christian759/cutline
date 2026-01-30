extends Button

@onready var level_label = $LevelLabel
@onready var star_container = $StarContainer
@onready var lock_icon = $LockIcon

func setup(level: int, is_unlocked: bool, stars: int):
	level_label.text = str(level)
	disabled = not is_unlocked
	
	if not is_unlocked:
		level_label.visible = false
		lock_icon.visible = true
		modulate.a = 0.5
	else:
		level_label.visible = true
		lock_icon.visible = false
		modulate.a = 1.0
		
		# Show stars
		for i in range(star_container.get_child_count()):
			star_container.get_child(i).visible = i < stars

func _on_mouse_entered():
	if not disabled:
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1).set_trans(Tween.TRANS_CUBIC)

func _on_mouse_exited():
	if not disabled:
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_CUBIC)
