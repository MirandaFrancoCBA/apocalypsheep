# scripts/utils/theme_manager.gd
# ─────────────────────────────────────────
# THEME MANAGER — Sistema de diseño centralizado
# Apocalypsheep · Estética post-apocalíptica oscura
#
# USO:
#   ThemeManager.apply_button_primary(button)
#   ThemeManager.apply_panel_dark(panel)
#   ThemeManager.apply_hp_bar(bar, "player")  # o "enemy"
#   var style = ThemeManager.make_panel_style(ThemeManager.C_SURFACE)
# ─────────────────────────────────────────
extends Node

# ─────────────────────────────────────────
# PALETA DE COLORES
# ─────────────────────────────────────────

# Fondos
const C_BG          := Color(0.06, 0.05, 0.04)        # negro sucio
const C_SURFACE     := Color(0.11, 0.09, 0.08)        # superficie oscura
const C_SURFACE_2   := Color(0.16, 0.13, 0.11)        # superficie elevada
const C_BORDER      := Color(0.28, 0.22, 0.17)        # borde óxido

# Acento principal — rojo sangre
const C_RED         := Color(0.78, 0.12, 0.10)        # rojo oscuro
const C_RED_BRIGHT  := Color(0.95, 0.20, 0.15)        # rojo activo
const C_RED_DIM     := Color(0.45, 0.08, 0.07)        # rojo apagado

# Acento secundario — ámbar oxidado
const C_AMBER       := Color(0.82, 0.52, 0.12)        # ámbar
const C_AMBER_DIM   := Color(0.45, 0.28, 0.07)        # ámbar apagado

# Verde tóxico — para HP jugador, cosas buenas
const C_GREEN       := Color(0.25, 0.75, 0.22)        # verde tóxico
const C_GREEN_DIM   := Color(0.12, 0.35, 0.10)

# Textos
const C_TEXT        := Color(0.88, 0.82, 0.72)        # hueso / beige
const C_TEXT_DIM    := Color(0.52, 0.47, 0.40)        # texto secundario
const C_TEXT_BRIGHT := Color(1.00, 0.95, 0.82)        # texto destacado

# Colores de rareza — sobreescribe Constants para UI
const C_COMMON      := Color(0.75, 0.72, 0.68)
const C_RARE        := Color(0.35, 0.58, 1.00)
const C_EPIC        := Color(0.72, 0.38, 1.00)

# Efectos de estado
const C_CRIT        := Color(1.00, 0.85, 0.10)
const C_DEFENSE     := Color(0.30, 0.72, 1.00)
const C_POISON      := Color(0.45, 0.85, 0.30)
const C_BURN        := Color(1.00, 0.45, 0.10)
const C_BLEED       := Color(0.85, 0.15, 0.15)

# ─────────────────────────────────────────
# TIPOGRAFÍA — overrides de tamaño
# ─────────────────────────────────────────
const FONT_TITLE    := 28
const FONT_SUBTITLE := 20
const FONT_BODY     := 16
const FONT_SMALL    := 13
const FONT_HUGE     := 40   # game over, level up

# ─────────────────────────────────────────
# ESPACIADO
# ─────────────────────────────────────────
const MARGIN_SCREEN  := 20
const MARGIN_PANEL   := 16
const PADDING_BUTTON := 12
const SEPARATION_SM  := 8
const SEPARATION_MD  := 14
const SEPARATION_LG  := 22
const RADIUS         := 6    # border radius general
const RADIUS_SM      := 3

# ─────────────────────────────────────────
# FACTORY — StyleBoxFlat
# ─────────────────────────────────────────
func make_panel_style(
	bg: Color,
	border: Color = C_BORDER,
	border_width: int = 1,
	radius: int = RADIUS
) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color             = bg
	s.border_color         = border
	s.border_width_left    = border_width
	s.border_width_top     = border_width
	s.border_width_right   = border_width
	s.border_width_bottom  = border_width
	s.corner_radius_top_left     = radius
	s.corner_radius_top_right    = radius
	s.corner_radius_bottom_left  = radius
	s.corner_radius_bottom_right = radius
	s.content_margin_left   = MARGIN_PANEL
	s.content_margin_top    = MARGIN_PANEL
	s.content_margin_right  = MARGIN_PANEL
	s.content_margin_bottom = MARGIN_PANEL
	return s

func make_button_style(
	bg: Color,
	border: Color,
	border_width: int = 1
) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color             = bg
	s.border_color         = border
	s.border_width_left    = border_width
	s.border_width_top     = border_width
	s.border_width_right   = border_width
	s.border_width_bottom  = border_width
	s.corner_radius_top_left     = RADIUS_SM
	s.corner_radius_top_right    = RADIUS_SM
	s.corner_radius_bottom_left  = RADIUS_SM
	s.corner_radius_bottom_right = RADIUS_SM
	s.content_margin_left   = PADDING_BUTTON
	s.content_margin_top    = PADDING_BUTTON
	s.content_margin_right  = PADDING_BUTTON
	s.content_margin_bottom = PADDING_BUTTON
	return s

func make_bar_fill(color: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.corner_radius_top_left     = RADIUS_SM
	s.corner_radius_top_right    = RADIUS_SM
	s.corner_radius_bottom_left  = RADIUS_SM
	s.corner_radius_bottom_right = RADIUS_SM
	return s

func make_bar_bg() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.10, 0.08, 0.07)
	s.border_color        = C_BORDER
	s.border_width_left   = 1
	s.border_width_top    = 1
	s.border_width_right  = 1
	s.border_width_bottom = 1
	s.corner_radius_top_left     = RADIUS_SM
	s.corner_radius_top_right    = RADIUS_SM
	s.corner_radius_bottom_left  = RADIUS_SM
	s.corner_radius_bottom_right = RADIUS_SM
	return s

# ─────────────────────────────────────────
# APLICADORES — nodos individuales
# ─────────────────────────────────────────

# Botón primario (Atacar, Jugar, Continuar)
func apply_button_primary(btn: Button) -> void:
	btn.add_theme_stylebox_override("normal",   make_button_style(C_RED,      C_RED_BRIGHT, 2))
	btn.add_theme_stylebox_override("hover",    make_button_style(C_RED_BRIGHT, C_AMBER,    2))
	btn.add_theme_stylebox_override("pressed",  make_button_style(C_RED_DIM,  C_RED,        2))
	btn.add_theme_stylebox_override("disabled", make_button_style(Color(0.18, 0.14, 0.12), C_BORDER, 1))
	btn.add_theme_color_override("font_color",          C_TEXT_BRIGHT)
	btn.add_theme_color_override("font_hover_color",    C_TEXT_BRIGHT)
	btn.add_theme_color_override("font_pressed_color",  C_TEXT_DIM)
	btn.add_theme_color_override("font_disabled_color", C_TEXT_DIM)
	btn.add_theme_font_size_override("font_size", FONT_BODY)

# Botón secundario (Defender, Volver, opciones)
func apply_button_secondary(btn: Button) -> void:
	btn.add_theme_stylebox_override("normal",   make_button_style(C_SURFACE_2, C_BORDER,    1))
	btn.add_theme_stylebox_override("hover",    make_button_style(C_SURFACE_2, C_AMBER_DIM, 2))
	btn.add_theme_stylebox_override("pressed",  make_button_style(C_SURFACE,   C_AMBER,     2))
	btn.add_theme_stylebox_override("disabled", make_button_style(C_SURFACE,   C_BORDER,    1))
	btn.add_theme_color_override("font_color",          C_TEXT)
	btn.add_theme_color_override("font_hover_color",    C_AMBER)
	btn.add_theme_color_override("font_pressed_color",  C_TEXT_DIM)
	btn.add_theme_color_override("font_disabled_color", C_TEXT_DIM)
	btn.add_theme_font_size_override("font_size", FONT_BODY)

# Botón danger (Nueva Partida, Eliminar)
func apply_button_danger(btn: Button) -> void:
	btn.add_theme_stylebox_override("normal",   make_button_style(C_SURFACE,   C_RED_DIM,   1))
	btn.add_theme_stylebox_override("hover",    make_button_style(C_RED_DIM,   C_RED_BRIGHT,2))
	btn.add_theme_stylebox_override("pressed",  make_button_style(C_RED,       C_RED_BRIGHT,2))
	btn.add_theme_stylebox_override("disabled", make_button_style(C_SURFACE,   C_BORDER,    1))
	btn.add_theme_color_override("font_color",          C_RED_BRIGHT)
	btn.add_theme_color_override("font_hover_color",    C_TEXT_BRIGHT)
	btn.add_theme_color_override("font_pressed_color",  C_TEXT_DIM)
	btn.add_theme_color_override("font_disabled_color", C_TEXT_DIM)
	btn.add_theme_font_size_override("font_size", FONT_BODY)

# Panel genérico oscuro
func apply_panel_dark(panel: PanelContainer) -> void:
	panel.add_theme_stylebox_override("panel", make_panel_style(C_SURFACE, C_BORDER, 1))

# Panel elevado (popups, dialogs)
func apply_panel_elevated(panel: PanelContainer) -> void:
	panel.add_theme_stylebox_override("panel", make_panel_style(C_SURFACE_2, C_AMBER_DIM, 2))

# Label título
func apply_label_title(label: Label) -> void:
	label.add_theme_color_override("font_color", C_TEXT_BRIGHT)
	label.add_theme_font_size_override("font_size", FONT_TITLE)

# Label subtítulo
func apply_label_subtitle(label: Label) -> void:
	label.add_theme_color_override("font_color", C_TEXT)
	label.add_theme_font_size_override("font_size", FONT_SUBTITLE)

# Label cuerpo
func apply_label_body(label: Label) -> void:
	label.add_theme_color_override("font_color", C_TEXT)
	label.add_theme_font_size_override("font_size", FONT_BODY)

# Label dimmed / secundario
func apply_label_dim(label: Label) -> void:
	label.add_theme_color_override("font_color", C_TEXT_DIM)
	label.add_theme_font_size_override("font_size", FONT_SMALL)

# HP bar — type: "player" | "enemy" | "xp"
func apply_progress_bar(bar: ProgressBar, type: String = "player") -> void:
	bar.add_theme_stylebox_override("background", make_bar_bg())
	bar.show_percentage = false
	match type:
		"player":
			bar.add_theme_stylebox_override("fill", make_bar_fill(C_GREEN))
		"enemy":
			bar.add_theme_stylebox_override("fill", make_bar_fill(C_RED_BRIGHT))
		"xp":
			bar.add_theme_stylebox_override("fill", make_bar_fill(C_AMBER))
		_:
			bar.add_theme_stylebox_override("fill", make_bar_fill(C_TEXT_DIM))

# Color de rareza para labels/botones
func get_rarity_color(rarity: String) -> Color:
	match rarity.to_lower():
		"rare":  return C_RARE
		"epic":  return C_EPIC
		_:       return C_COMMON

# ─────────────────────────────────────────
# APLICADOR DE FONDO DE ESCENA
# Llama en _ready() de cada escena con get_tree().current_scene o self
# ─────────────────────────────────────────
func apply_scene_background(control: Control) -> void:
	control.add_theme_color_override("font_color", C_TEXT)
	# ColorRect de fondo — si no existe, lo creamos
	var bg_name := "__ApocBG__"
	if control.has_node(bg_name):
		return
	var bg := ColorRect.new()
	bg.name             = bg_name
	bg.color            = C_BG
	bg.mouse_filter     = Control.MOUSE_FILTER_IGNORE
	bg.layout_mode      = 1
	bg.anchors_preset   = Control.PRESET_FULL_RECT
	bg.anchor_right     = 1.0
	bg.anchor_bottom    = 1.0
	bg.z_index          = -10
	control.add_child(bg)
	control.move_child(bg, 0)
