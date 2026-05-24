extends Control
class_name CombatResultPopup

signal continue_pressed

@onready var label_title  = $Panel/VBoxContainer/LabelTitle
@onready var label_xp     = $Panel/VBoxContainer/LabelXP
@onready var label_loot   = $Panel/VBoxContainer/LabelLoot
@onready var button_continue = $Panel/VBoxContainer/ButtonContinue

func _ready() -> void:
	if not button_continue.pressed.is_connected(_on_button_continue_pressed):
		button_continue.pressed.connect(_on_button_continue_pressed)

# ─────────────────────────────────────────
# US-COMBAT-001: recibe resultado completo
# Muestra: victoria/derrota, XP ganada, loot obtenido
# NO viene del log — tiene su propio canal visual
# ─────────────────────────────────────────
func show_result(result: String, xp: int, loot: Dictionary) -> void:
	# Victoria / Derrota
	if result == "victory":
		label_title.text    = "🏆 VICTORIA"
		label_title.modulate = Color(0.4, 1.0, 0.5)   # verde
	else:
		label_title.text    = "💀 DERROTA"
		label_title.modulate = Color(1.0, 0.3, 0.3)   # rojo

	# XP — solo visible en victoria
	if result == "victory":
		label_xp.visible = true
		label_xp.text    = "✨ XP Ganada: +" + str(xp)
	else:
		label_xp.visible = false

	# Loot
	if loot.is_empty():
		label_loot.text    = "❌ Sin loot"
		label_loot.modulate = Color.GRAY
	else:
		var rarity = loot.get("rarity", "common").to_lower()
		var icon   = Constants.RARITY_ICONS.get(rarity, "⚪")
		label_loot.text    = icon + " " + loot.get("name", "Item")
		label_loot.modulate = Constants.RARITY_COLORS.get(rarity, Color.WHITE)

	# Animación de entrada
	scale      = Vector2(0.8, 0.8)
	modulate.a = 0.0
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale",      Vector2.ONE, 0.25)
	tween.tween_property(self, "modulate:a", 1.0,         0.25)

func _on_button_continue_pressed() -> void:
	continue_pressed.emit()
	queue_free()