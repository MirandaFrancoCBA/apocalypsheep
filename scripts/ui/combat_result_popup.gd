# scripts/ui/combat_result_popup.gd
# US-UI-009 — responsive: panel se adapta al viewport real
# US-UI-010 — pantalla de resultado clara
extends Control
class_name CombatResultPopup

signal continue_pressed

@onready var label_title    = $Panel/VBoxContainer/LabelTitle
@onready var label_xp       = $Panel/VBoxContainer/LabelXP
@onready var label_loot     = $Panel/VBoxContainer/LabelLoot
@onready var button_continue = $Panel/VBoxContainer/ButtonContinue
@onready var panel          = $Panel

func _ready() -> void:
	_apply_responsive_layout()
	_apply_theme()
	if not button_continue.pressed.is_connected(_on_button_continue_pressed):
		button_continue.pressed.connect(_on_button_continue_pressed)

# ─────────────────────────────────────────
# RESPONSIVE — US-UI-009
# En lugar de offsets fijos (-175 / +175), calculamos
# en base al viewport real del dispositivo.
# ─────────────────────────────────────────
func _apply_responsive_layout() -> void:
	await get_tree().process_frame  # esperar un frame para que el viewport esté listo
	var vp     = get_viewport_rect().size
	var width  = min(vp.x * 0.88, 500.0)
	var height = min(vp.y * 0.55, 380.0)
	var half_w = width  / 2.0
	var half_h = height / 2.0

	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left   = -half_w
	panel.offset_top    = -half_h
	panel.offset_right  =  half_w
	panel.offset_bottom =  half_h

func _apply_theme() -> void:
	if panel:
		panel.add_theme_stylebox_override(
			"panel",
			ThemeManager.make_panel_style(ThemeManager.C_SURFACE_2, ThemeManager.C_AMBER_DIM, 2)
		)
	ThemeManager.apply_button_primary(button_continue)
	button_continue.custom_minimum_size = Vector2(0, 56)

func show_result(result: String, xp: int, loot: Dictionary) -> void:
	if result == "victory":
		label_title.text = "⚔️ VICTORIA"
		label_title.add_theme_color_override("font_color", ThemeManager.C_GREEN)
	else:
		label_title.text = "💀 DERROTA"
		label_title.add_theme_color_override("font_color", ThemeManager.C_RED_BRIGHT)
	label_title.add_theme_font_size_override("font_size", ThemeManager.FONT_HUGE)

	if result == "victory":
		label_xp.visible = true
		label_xp.text    = "+%d XP" % xp
		label_xp.add_theme_color_override("font_color",    ThemeManager.C_AMBER)
		label_xp.add_theme_font_size_override("font_size", ThemeManager.FONT_SUBTITLE)
	else:
		label_xp.visible = false

	if loot.is_empty():
		label_loot.text = "Sin loot esta vez"
		label_loot.add_theme_color_override("font_color", ThemeManager.C_TEXT_DIM)
	else:
		var rarity = loot.get("rarity", "common").to_lower()
		var icon   = Constants.RARITY_ICONS.get(rarity, "⚪")
		label_loot.text = icon + " " + loot.get("name", "Item")
		label_loot.add_theme_color_override("font_color",    ThemeManager.get_rarity_color(rarity))
		label_loot.add_theme_font_size_override("font_size", ThemeManager.FONT_BODY)

	# Animación de entrada
	scale      = Vector2(0.85, 0.85)
	modulate.a = 0.0
	var tween  = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale",      Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "modulate:a", 1.0,         0.25)

func _on_button_continue_pressed() -> void:
	AudioManager.play_sfx("confirm")
	continue_pressed.emit()
	queue_free()