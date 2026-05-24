# scripts/ui/combat_result_popup.gd
extends Control
class_name CombatResultPopup

signal continue_pressed

@onready var label_title     = $Panel/VBoxContainer/LabelTitle
@onready var label_xp        = $Panel/VBoxContainer/LabelXP
@onready var label_loot      = $Panel/VBoxContainer/LabelLoot
@onready var button_continue = $Panel/VBoxContainer/ButtonContinue

func _ready() -> void:
	_apply_theme()
	if not button_continue.pressed.is_connected(_on_button_continue_pressed):
		button_continue.pressed.connect(_on_button_continue_pressed)

func _apply_theme() -> void:
	var panel = $Panel
	if panel:
		panel.add_theme_stylebox_override(
			"panel",
			ThemeManager.make_panel_style(ThemeManager.C_SURFACE_2, ThemeManager.C_AMBER_DIM, 2)
		)
	ThemeManager.apply_button_primary(button_continue)
	button_continue.custom_minimum_size = Vector2(0, 56)

func show_result(result: String, xp: int, loot: Dictionary) -> void:
	if result == "victory":
		label_title.text = "VICTORIA"
		label_title.add_theme_color_override("font_color", ThemeManager.C_GREEN)
	else:
		label_title.text = "DERROTA"
		label_title.add_theme_color_override("font_color", ThemeManager.C_RED_BRIGHT)
	label_title.add_theme_font_size_override("font_size", ThemeManager.FONT_HUGE)

	if result == "victory":
		label_xp.visible = true
		label_xp.text    = "+%d XP" % xp
		label_xp.add_theme_color_override("font_color", ThemeManager.C_AMBER)
		label_xp.add_theme_font_size_override("font_size", ThemeManager.FONT_SUBTITLE)
	else:
		label_xp.visible = false

	if loot.is_empty():
		label_loot.text = "sin loot"
		label_loot.add_theme_color_override("font_color", ThemeManager.C_TEXT_DIM)
	else:
		var rarity = loot.get("rarity", "common").to_lower()
		var icon   = Constants.RARITY_ICONS.get(rarity, "⚪")
		label_loot.text = icon + "  " + loot.get("name", "Item")
		label_loot.add_theme_color_override("font_color", ThemeManager.get_rarity_color(rarity))
	label_loot.add_theme_font_size_override("font_size", ThemeManager.FONT_BODY)

	scale      = Vector2(0.85, 0.85)
	modulate.a = 0.0
	var tween  = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale",      Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "modulate:a", 1.0,         0.25)

func _on_button_continue_pressed() -> void:
	continue_pressed.emit()
	queue_free()