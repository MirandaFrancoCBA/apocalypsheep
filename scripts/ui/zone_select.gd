# scripts/ui/zone_select.gd
extends Control

@onready var zones_container = $MarginContainer/VBoxContainer/VBoxZones
@onready var button_back     = $MarginContainer/VBoxContainer/ButtonBack
@onready var label_title     = $MarginContainer/VBoxContainer/LabelTitle

func _ready() -> void:
	print("[ZoneSelect] Cargando zonas...")
	_apply_theme()
	load_zones()

# ─────────────────────────────────────────
# TEMA
# ─────────────────────────────────────────
func _apply_theme() -> void:
	ThemeManager.apply_scene_background(self)
	ThemeManager.apply_label_title(label_title)
	label_title.text = "[ SELECCIONAR ZONAS ]"
	ThemeManager.apply_button_secondary(button_back)

# ─────────────────────────────────────────
# ZONAS
# ─────────────────────────────────────────
func load_zones() -> void:
	var file = FileAccess.open("res://data/zones.json", FileAccess.READ)
	if file == null:
		push_error("[ZoneSelect] No se pudo abrir zones.json")
		return
	var data = JSON.parse_string(file.get_as_text())
	if data == null:
		push_error("[ZoneSelect] Error parseando JSON")
		return
	_clear_zones()
	create_zone_buttons(data)

func _clear_zones() -> void:
	for child in zones_container.get_children():
		child.queue_free()

func _can_enter_combat() -> bool:
	var player = GameManager.get_player_data()
	if player["hp"] <= 0:
		return false
	if player["max_hp"] <= 0:
		return false
	return true

func create_zone_buttons(zones: Array) -> void:
	var player_level = GameManager.get_player_data().get("level", 1)

	for zone in zones:

		var btn = Button.new()

		var level_range = zone.get("level_range", [1, 1])
		var zone_min = level_range[0]
		var zone_max = level_range[1]

		var icon = zone.get("icon", "📍")
		var description = zone.get("description", "")

		var difficulty_tag := ""

		if player_level < zone_min:
			difficulty_tag = "\n⚠ PELIGROSO"

		elif player_level > zone_max + 2:
			difficulty_tag = "\n✓ FÁCIL"

		btn.text = "%s %s\n%s\nLv %d-%d%s" % [
			icon,
			zone.get("name", "Zona"),
			description,
			zone_min,
			zone_max,
			difficulty_tag
		]

		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT

		btn.custom_minimum_size = Vector2(0, 120)

		if player_level < zone_min:
			ThemeManager.apply_button_danger(btn)

		elif player_level > zone_max + 2:
			ThemeManager.apply_button_secondary(btn)

		else:
			ThemeManager.apply_button_primary(btn)

		btn.pressed.connect(func(): _on_zone_selected(zone))

		zones_container.add_child(btn)

	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, ThemeManager.SEPARATION_LG)
	zones_container.add_child(spacer)

func _on_zone_selected(zone: Dictionary) -> void:
	if not _can_enter_combat():
		print("[ZoneSelect] No se puede entrar al combate")
		return
	print("[ZoneSelect] Zona elegida:", zone.get("name", ""))
	GameManager.set_selected_zone(zone)
	SceneManager.go_to_combat()

func _on_button_back_pressed() -> void:
	SceneManager.go_to_main_menu()