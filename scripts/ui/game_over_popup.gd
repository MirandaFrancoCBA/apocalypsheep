# scripts/ui/game_over_popup.gd
extends Control
class_name GameOverPopup

@onready var label_stats  = $ColorRect/Panel/MarginContainer/VBoxContainer/LabelStats
@onready var button_retry = $ColorRect/Panel/MarginContainer/VBoxContainer/ButtonRetry
@onready var button_menu  = $ColorRect/Panel/MarginContainer/VBoxContainer/ButtonMenu
@onready var label_title  = $ColorRect/Panel/MarginContainer/VBoxContainer/LabelTitle

func _ready() -> void:
	_apply_theme()

	var player = GameManager.get_player_data()
	label_stats.text = "Nivel alcanzado:  %d\nXP total:         %d" % [
		player["level"], player["xp"]
	]

	modulate.a = 0.0
	scale      = Vector2(0.85, 0.85)
	var tween  = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0,         0.4)
	tween.tween_property(self, "scale",      Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK)

	button_retry.pressed.connect(_on_retry_pressed)
	button_menu.pressed.connect(_on_menu_pressed)

func _apply_theme() -> void:
	# Overlay oscuro ya viene del ColorRect del .tscn
	# Estilizamos el panel interior
	var panel = $ColorRect/Panel
	if panel:
		var style = ThemeManager.make_panel_style(
			ThemeManager.C_SURFACE_2,
			ThemeManager.C_RED_DIM,
			2,
			ThemeManager.RADIUS
		)
		panel.add_theme_stylebox_override("panel", style)

	label_title.add_theme_color_override("font_color", ThemeManager.C_RED_BRIGHT)
	label_title.add_theme_font_size_override("font_size", ThemeManager.FONT_HUGE)

	ThemeManager.apply_label_body(label_stats)
	label_stats.add_theme_color_override("font_color", ThemeManager.C_TEXT_DIM)

	ThemeManager.apply_button_primary(button_retry)
	button_retry.custom_minimum_size = Vector2(0, 60)

	ThemeManager.apply_button_secondary(button_menu)
	button_menu.custom_minimum_size = Vector2(0, 60)

func _on_retry_pressed() -> void:
	GameManager.reset_game()
	SceneManager.go_to_zone_select()

func _on_menu_pressed() -> void:
	SceneManager.go_to_main_menu()