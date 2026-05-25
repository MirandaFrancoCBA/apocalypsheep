# scripts/ui/combat_history_popup.gd
# ─────────────────────────────────────────
# COMBAT HISTORY POPUP — US-UI-014
# Modal limpio para el historial de combate.
# No interfiere con el combate principal.
# Se instancia desde combat_screen.gd al presionar 📜
#
# USO en combat_screen.gd:
#   var popup = CombatHistoryPopup.instantiate()
#   add_child(popup)
#   popup.set_log(label_result.text)
# ─────────────────────────────────────────
extends Control
class_name CombatHistoryPopup

@onready var panel        = $Panel
@onready var label_header = $Panel/Margin/VBox/LabelHeader
@onready var scroll       = $Panel/Margin/VBox/ScrollContainer
@onready var label_log    = $Panel/Margin/VBox/ScrollContainer/LabelLog
@onready var button_close = $Panel/Margin/VBox/ButtonClose
@onready var bg_dim       = $BgDim

func _ready() -> void:
	_apply_responsive_layout()
	_apply_theme()
	button_close.pressed.connect(_on_close)
	# Cerrar también al tocar el fondo oscuro
	bg_dim.gui_input.connect(_on_bg_input)
	_animate_in()

func _apply_responsive_layout() -> void:
	await get_tree().process_frame
	var vp   = get_viewport_rect().size
	var w    = min(vp.x * 0.90, 540.0)
	var h    = min(vp.y * 0.72, 600.0)
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left   = -(w / 2.0)
	panel.offset_top    = -(h / 2.0)
	panel.offset_right  =  (w / 2.0)
	panel.offset_bottom =  (h / 2.0)

func _apply_theme() -> void:
	if panel:
		panel.add_theme_stylebox_override(
			"panel",
			ThemeManager.make_panel_style(ThemeManager.C_SURFACE_2, ThemeManager.C_AMBER_DIM, 2, ThemeManager.RADIUS)
		)
	ThemeManager.apply_label_title(label_header)
	label_header.text = "📜 Historial de combate"

	label_log.add_theme_color_override("default_color",        ThemeManager.C_TEXT_DIM)
	label_log.add_theme_font_size_override("normal_font_size", ThemeManager.FONT_SMALL)

	ThemeManager.apply_button_secondary(button_close)
	button_close.custom_minimum_size = Vector2(0, 52)
	button_close.text = "✖ Cerrar"

## Recibe el texto del log acumulado del combate
func set_log(log_text: String) -> void:
	label_log.text = log_text
	await get_tree().process_frame
	# Scroll al final automáticamente
	scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value)

func _on_bg_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_on_close()

func _on_close() -> void:
	AudioManager.play_sfx("click")
	_animate_out()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			_on_close()

func _animate_in() -> void:
	modulate.a  = 0.0
	panel.scale = Vector2(0.92, 0.92)
	var tween   = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self,  "modulate:a", 1.0,         0.2)
	tween.tween_property(panel, "scale",      Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK)

func _animate_out() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.15)
	await tween.finished
	queue_free()
