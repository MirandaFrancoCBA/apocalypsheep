extends Label

var float_distance := 80.0
var duration := 0.8

func setup(
	damage: int,
	is_critical: bool = false
) -> void:

	text = str(damage)

	if is_critical:
		modulate = Color.YELLOW
		scale = Vector2(1.5, 1.5)
		text = "💥 " + text
	else:
		modulate = Color.WHITE

	animate()

func animate() -> void:

	var tween = create_tween()

	var _start_pos = position
	var end_pos = position + Vector2(0, -float_distance)

	tween.set_parallel(true)

	tween.tween_property(
		self,
		"position",
		end_pos,
		duration
	)

	tween.tween_property(
		self,
		"modulate:a",
		0.0,
		duration
	)

	await tween.finished

	queue_free()