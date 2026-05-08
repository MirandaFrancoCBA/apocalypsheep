extends Control

@onready var label = $CenterContainer/Panel/Label

func show_level_up(
	level: int,
	hp_gain: int,
	damage_gain: int
):
	label.text = (
	"🎉 LEVEL UP!\n\n" +
	"Nivel " + str(level) + "\n" +
	"+%d HP\n" % hp_gain +
	"+%d Daño" % damage_gain
)

	modulate.a = 0
	scale = Vector2(2.0, 2.0)

	# fade + zoom
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3)
	tween.parallel().tween_property(self, "scale", Vector2(1.2, 1.2), 0.3)

	await tween.finished

	# pequeño rebote
	var tween2 = create_tween()
	tween2.tween_property(self, "scale", Vector2(1, 1), 0.2)

	await get_tree().create_timer(3.0).timeout

	queue_free()