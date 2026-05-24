# scripts/ui/level_up_popup.gd
extends Control

@onready var label = $CenterContainer/Panel/Label

func show_level_up(level: int, hp_gain: int, damage_gain: int) -> void:
	label.text = "LEVEL UP\nNivel %d\n+%d HP   +%d Daño" % [level, hp_gain, damage_gain]
	label.add_theme_color_override("font_color", ThemeManager.C_AMBER)
	label.add_theme_font_size_override("font_size", ThemeManager.FONT_SUBTITLE)

	# Panel interior
	var panel = $CenterContainer/Panel
	if panel:
		panel.add_theme_stylebox_override(
			"panel",
			ThemeManager.make_panel_style(ThemeManager.C_SURFACE_2, ThemeManager.C_AMBER, 2)
		)

	modulate.a = 0.0
	scale      = Vector2(2.0, 2.0)

	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0,           0.3)
	tween.parallel().tween_property(self, "scale", Vector2(1.1, 1.1), 0.3).set_trans(Tween.TRANS_BACK)
	await tween.finished

	var tween2 = create_tween()
	tween2.tween_property(self, "scale", Vector2.ONE, 0.2)
	await get_tree().create_timer(2.5).timeout

	var tween3 = create_tween()
	tween3.tween_property(self, "modulate:a", 0.0, 0.4)
	await tween3.finished
	queue_free()