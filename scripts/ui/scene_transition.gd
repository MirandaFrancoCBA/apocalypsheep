extends CanvasLayer

@onready var rect: ColorRect = $ColorRect

func _ready() -> void:
	rect.visible = false

func fade_out() -> void:

	rect.visible = true
	rect.modulate.a = 0.0

	var tween = create_tween()

	tween.tween_property(
		rect,
		"modulate:a",
		1.0,
		0.25
	)

	await tween.finished

func fade_in() -> void:

	rect.modulate.a = 1.0

	var tween = create_tween()

	tween.tween_property(
		rect,
		"modulate:a",
		0.0,
		0.25
	)

	await tween.finished

	rect.visible = false