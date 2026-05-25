# scripts/ui/main_menu.gd
# US-UI-012  — game feel, animación, botón settings
# US-AUDIO-008 — música de menú
# US-AUDIO-009 — feedback sonoro en botones
# US-AUDIO-010 — acceso al popup de ajustes de volumen
extends Control

@onready var button_play      = $VBoxContainer/ButtonPlay
@onready var button_inventory = $VBoxContainer/ButtonInventory
@onready var button_new_game  = $VBoxContainer/ButtonNewGame
@onready var button_settings  = $VBoxContainer/ButtonSettings
@onready var label_title      = $VBoxContainer/LabelTitle
@onready var label_subtitle   = $VBoxContainer/LabelSubtitle

func _ready() -> void:
	print("[MainMenu] Escena cargada")
	_apply_theme()
	_check_existing_save()
	_animate_entrance()
	AudioManager.play_music("menu")

func _apply_theme() -> void:
	ThemeManager.apply_scene_background(self)
	label_title.add_theme_color_override("font_color",    ThemeManager.C_RED_BRIGHT)
	label_title.add_theme_font_size_override("font_size", ThemeManager.FONT_HUGE)
	ThemeManager.apply_label_dim(label_subtitle)
	label_subtitle.add_theme_font_size_override("font_size", ThemeManager.FONT_SMALL)
	ThemeManager.apply_button_primary(button_play)
	button_play.custom_minimum_size = Vector2(240, 64)
	ThemeManager.apply_button_secondary(button_inventory)
	button_inventory.custom_minimum_size = Vector2(240, 52)
	ThemeManager.apply_button_secondary(button_settings)
	button_settings.custom_minimum_size = Vector2(240, 48)
	button_settings.text = "⚙️ Ajustes"
	ThemeManager.apply_button_danger(button_new_game)
	button_new_game.custom_minimum_size = Vector2(240, 52)

func _animate_entrance() -> void:
	label_title.modulate.a      = 0.0
	label_subtitle.modulate.a   = 0.0
	button_play.modulate.a      = 0.0
	button_inventory.modulate.a = 0.0
	button_settings.modulate.a  = 0.0
	button_new_game.modulate.a  = 0.0
	label_title.scale           = Vector2(0.8, 0.8)
	var tween = create_tween()
	tween.tween_property(label_title,    "modulate:a", 1.0, 0.4)
	tween.parallel().tween_property(label_title, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK)
	tween.tween_property(label_subtitle, "modulate:a", 1.0, 0.3)
	tween.tween_interval(0.05)
	tween.tween_property(button_play,      "modulate:a", 1.0, 0.25)
	tween.tween_property(button_inventory, "modulate:a", 1.0, 0.20)
	tween.tween_property(button_settings,  "modulate:a", 1.0, 0.15)
	tween.tween_property(button_new_game,  "modulate:a", 1.0, 0.15)

func _check_existing_save() -> void:
	button_play.text = "▶ CONTINUAR" if SaveSystem.has_save() else "▶ JUGAR"

func _on_button_play_pressed() -> void:
	AudioManager.play_sfx("confirm")
	if SaveSystem.has_save():
		SaveSystem.load_game()
	else:
		if not GameManager.game_started:
			GameManager.reset_game()
		GameManager.game_started = true
	AudioManager.stop_music(0.3)
	SceneManager.go_to_zone_select()

func _on_button_inventory_pressed() -> void:
	AudioManager.play_sfx("click")
	SceneManager.go_to_inventory()

func _on_button_settings_pressed() -> void:
	AudioManager.play_sfx("click")
	var SettingsPopupScene = load("res://scenes/ui/settings_popup.tscn")
	var popup = SettingsPopupScene.instantiate()
	add_child(popup)
	popup.top_level = true
	popup.z_index   = 100

func _on_button_new_game_pressed() -> void:
	AudioManager.play_sfx("click")
	SaveSystem.delete_save()
	GameManager.reset_game()
	GameManager.game_started = true
	AudioManager.stop_music(0.3)
	SceneManager.go_to_zone_select()
