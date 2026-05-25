# scripts/utils/responsive_helper.gd
# ─────────────────────────────────────────
# RESPONSIVE HELPER — US-UI-009
# Centraliza toda la lógica de adaptación a pantalla.
#
# PROBLEMA en mobile:
#   Los popups con offsets fijos (ej: offset_left = -200)
#   se ven bien en 600x900 pero se cortan en pantallas
#   más chicas (480px de ancho) o se ven enanos en tablets.
#
# SOLUCIÓN:
#   Calcular offsets en base al viewport real.
#   Llamar a estos helpers desde _ready() de cada popup.
#
# USO:
#   ResponsiveHelper.center_panel(panel, 0.85, 0.65)
#   # → panel ocupa 85% ancho y 65% alto del viewport
# ─────────────────────────────────────────
extends Node

# ─────────────────────────────────────────
# API PRINCIPAL
# ─────────────────────────────────────────

## Centra y redimensiona un Control basado en porcentaje del viewport.
## width_pct y height_pct van de 0.0 a 1.0
## max_width/max_height en px — evita que en tablets quede demasiado grande
func center_panel(
	panel: Control,
	width_pct:   float = 0.85,
	height_pct:  float = 0.70,
	max_width:   float = 520.0,
	max_height:  float = 680.0
) -> void:
	var vp       = panel.get_viewport_rect().size
	var w        = min(vp.x * width_pct,  max_width)
	var h        = min(vp.y * height_pct, max_height)
	var half_w   = w / 2.0
	var half_h   = h / 2.0

	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left   = -half_w
	panel.offset_top    = -half_h
	panel.offset_right  =  half_w
	panel.offset_bottom =  half_h

## Garantiza que un popup no salga de la pantalla.
## Llamar después de posicionar el popup.
func clamp_to_viewport(node: Control) -> void:
	var vp   = node.get_viewport_rect().size
	var rect = node.get_rect()
	node.position.x = clamp(node.position.x, 0, vp.x - rect.size.x)
	node.position.y = clamp(node.position.y, 0, vp.y - rect.size.y)

## Devuelve true si el viewport es "estrecho" (< 500px ancho).
## Útil para mostrar menos info o layouts alternativos.
func is_narrow() -> bool:
	var vp = get_viewport().get_visible_rect().size
	return vp.x < 500.0

## Factor de escala relativo al diseño base 600x900.
## Usar para escalar font sizes en pantallas muy distintas.
func scale_factor() -> float:
	var vp = get_viewport().get_visible_rect().size
	return clamp(vp.x / 600.0, 0.7, 1.3)