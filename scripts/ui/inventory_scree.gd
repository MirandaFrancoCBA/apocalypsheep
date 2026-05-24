# scripts/ui/inventory_scree.gd
# ─────────────────────────────────────────
# INVENTORY SCREEN
# US-UI-003, 004, 005, 007, 011 — ThemeManager completo
# US-AUDIO-009 — feedback sonoro en botones
# ─────────────────────────────────────────
extends Control

@onready var items_container    = $MarginContainer/VBoxContainer/VBoxItems
@onready var button_back        = $MarginContainer/VBoxContainer/ButtonBack
@onready var label_detail       = $MarginContainer/VBoxContainer/LabelDetail
@onready var button_equip       = $MarginContainer/VBoxContainer/ButtonEquip
@onready var label_equipped     = $MarginContainer/VBoxContainer/LabelEquipped
@onready var button_unequip     = $MarginContainer/VBoxContainer/ButtonUnequip
@onready var button_delete      = $MarginContainer/VBoxContainer/ButtonDelete
@onready var confirm_delete_dialog = $ConfirmDeleteDialog
@onready var label_stats        = $MarginContainer/VBoxContainer/LabelStats
@onready var xp_bar             = $MarginContainer/VBoxContainer/XPBar
@onready var button_use         = $MarginContainer/VBoxContainer/ButtonUse
@onready var label_title        = $MarginContainer/VBoxContainer/LabelTitle

var selected_item: Dictionary = {}

func _ready() -> void:
	_apply_theme()

	var player    = GameManager.get_player_data()
	var inventory = player["inventory"]
	label_equipped.text = "Arma equipada: Ninguna\nEspacio: %d/%d" % [
		inventory.size(),
		Constants.INVENTORY_MAX_SIZE
	]

	GameManager.player_data_changed.connect(_update_stats)
	print("[Inventory] Cargando inventario")
	_load_inventory()
	_update_equipped_label()
	_update_unequip_button()
	_update_stats()
	_update_use_button()
	_animate_entrance()

# ─────────────────────────────────────────
# TEMA — US-UI-003 / 004 / 007 / 011
# ─────────────────────────────────────────
func _apply_theme() -> void:
	ThemeManager.apply_scene_background(self)

	# Título
	if label_title:
		label_title.add_theme_color_override("font_color", ThemeManager.C_TEXT_BRIGHT)
		label_title.add_theme_font_size_override("font_size", ThemeManager.FONT_TITLE)
		label_title.text = "📦 INVENTARIO"
		label_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# Stats — panel elevado
	if label_stats:
		var style = ThemeManager.make_panel_style(
			ThemeManager.C_SURFACE_2,
			ThemeManager.C_BORDER,
			1,
			ThemeManager.RADIUS
		)
		label_stats.add_theme_stylebox_override("normal", style)
		ThemeManager.apply_label_body(label_stats)

	# XP bar
	if xp_bar:
		ThemeManager.apply_progress_bar(xp_bar, "xp")
		xp_bar.custom_minimum_size = Vector2(0, 12)

	# Arma equipada
	if label_equipped:
		ThemeManager.apply_label_dim(label_equipped)

	# Detalle — panel sutil
	if label_detail:
		var style_detail = ThemeManager.make_panel_style(
			ThemeManager.C_SURFACE,
			ThemeManager.C_BORDER,
			1,
			ThemeManager.RADIUS_SM
		)
		label_detail.add_theme_stylebox_override("normal", style_detail)
		label_detail.add_theme_color_override("font_color", ThemeManager.C_TEXT)
		label_detail.add_theme_font_size_override("font_size", ThemeManager.FONT_BODY)

	# Botones de acción
	ThemeManager.apply_button_primary(button_equip)
	button_equip.custom_minimum_size   = Vector2(0, 52)

	ThemeManager.apply_button_secondary(button_unequip)
	button_unequip.custom_minimum_size = Vector2(0, 52)

	ThemeManager.apply_button_secondary(button_use)
	button_use.custom_minimum_size     = Vector2(0, 52)

	ThemeManager.apply_button_danger(button_delete)
	button_delete.custom_minimum_size  = Vector2(0, 52)

	ThemeManager.apply_button_secondary(button_back)
	button_back.custom_minimum_size    = Vector2(0, 48)

# ─────────────────────────────────────────
# ANIMACIÓN DE ENTRADA
# ─────────────────────────────────────────
func _animate_entrance() -> void:
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.25)

# ─────────────────────────────────────────
# LOAD
# ─────────────────────────────────────────
func _load_inventory() -> void:
	var player    = GameManager.get_player_data()
	var inventory = player["inventory"]
	if inventory.is_empty():
		_show_empty()
		return
	_create_items(inventory)

func _show_empty() -> void:
	var label = Label.new()
	label.text = "Inventario vacío"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", ThemeManager.C_TEXT_DIM)
	label.add_theme_font_size_override("font_size", ThemeManager.FONT_BODY)
	items_container.add_child(label)

# ─────────────────────────────────────────
# LISTA DE ITEMS — US-UI-005 / 006
# ─────────────────────────────────────────
func _create_items(items: Array) -> void:
	for item in items:
		var button = Button.new()
		var rarity = item.get("rarity", "common").to_lower()
		var is_equipped = (item == GameManager.get_equipped_weapon())

		# Estilo base del botón
		var bg_color = ThemeManager.C_SURFACE_2
		var border_color = ThemeManager.get_rarity_color(rarity)
		var border_width = 2 if is_equipped else 1

		var style_normal  = ThemeManager.make_button_style(bg_color, border_color, border_width)
		var style_hover   = ThemeManager.make_button_style(ThemeManager.C_SURFACE, border_color, 2)
		var style_pressed = ThemeManager.make_button_style(ThemeManager.C_SURFACE, border_color, 2)

		button.add_theme_stylebox_override("normal",  style_normal)
		button.add_theme_stylebox_override("hover",   style_hover)
		button.add_theme_stylebox_override("pressed", style_pressed)
		button.add_theme_color_override("font_color",       ThemeManager.get_rarity_color(rarity))
		button.add_theme_color_override("font_hover_color", ThemeManager.C_TEXT_BRIGHT)
		button.add_theme_font_size_override("font_size",    ThemeManager.FONT_BODY)

		var text = _format_item(item)
		if is_equipped:
			text += " ✔"
		button.text = text
		button.custom_minimum_size = Vector2(0, 52)

		button.pressed.connect(func():
			AudioManager.play_sfx("click")
			_on_item_selected(item)
		)
		items_container.add_child(button)

# ─────────────────────────────────────────
# FORMATO ITEMS
# ─────────────────────────────────────────
func _format_item(item: Dictionary) -> String:
	var rarity = item.get("rarity", "common").to_lower()
	var icon   = Constants.RARITY_ICONS.get(rarity, "⚪")
	var text   = icon + " " + item.get("name", "Item")
	if item.get("type") == "weapon":
		text += "  ⚔️ " + str(item.get("damage", 0))
		var effect = item.get("effect", "")
		if effect != "":
			text += "  " + _effect_to_text(effect)
	if item.has("heal"):
		text += "  ❤️ +" + str(item["heal"])
	return text

func _effect_to_text(effect: String) -> String:
	match effect:
		"bleed":   return "🩸"
		"poison":  return "☠️"
		"burn":    return "🔥"
		"stun":    return "💫"
		_:         return effect

# ─────────────────────────────────────────
# SELECCIÓN
# ─────────────────────────────────────────
func _on_item_selected(item: Dictionary) -> void:
	selected_item = item
	print("[Inventory] Item seleccionado:", item)
	_show_item_detail(item)
	_update_use_button()

# ─────────────────────────────────────────
# DETALLE ITEM — US-UI-005
# ─────────────────────────────────────────
func _show_item_detail(item: Dictionary) -> void:
	var rarity = item.get("rarity", "common").to_lower()
	var icon   = Constants.RARITY_ICONS.get(rarity, "⚪")
	var color  = ThemeManager.get_rarity_color(rarity)

	var text = ""
	text += icon + " " + item.get("name", "") + "\n"
	text += "Rareza: " + item.get("rarity", "common") + "\n"
	if item.has("damage"):
		text += "⚔️ Daño: " + str(item["damage"]) + "\n"
	if item.has("effect"):
		text += "Efecto: " + _effect_to_text(item["effect"]) + " " + item["effect"] + "\n"
	if item.has("heal"):
		text += "❤️ Curación: " + str(item["heal"]) + "\n"
	if item.has("description"):
		text += "\n" + item["description"]

	label_detail.text = text
	label_detail.add_theme_color_override("font_color", color)

# ─────────────────────────────────────────
# BOTONES — US-AUDIO-009
# ─────────────────────────────────────────
func _on_button_back_pressed() -> void:
	AudioManager.play_sfx("click")
	SceneManager.go_to_zone_select()

func _on_button_equip_pressed() -> void:
	if selected_item.is_empty():
		return
	AudioManager.play_sfx("click")
	GameManager.equip_item(selected_item)
	_update_equipped_label()
	_update_unequip_button()
	_refresh_inventory()

func _on_button_unequip_pressed() -> void:
	AudioManager.play_sfx("click")
	GameManager.unequip_item()
	_update_equipped_label()
	_update_unequip_button()
	_refresh_inventory()

func _on_button_delete_pressed() -> void:
	if selected_item.is_empty():
		return
	AudioManager.play_sfx("click")
	confirm_delete_dialog.popup_centered()

func _on_confirm_delete_dialog_confirmed() -> void:
	GameManager.remove_item(selected_item)
	selected_item = {}
	_refresh_inventory()
	_update_equipped_label()
	_update_unequip_button()
	label_detail.text = "Item eliminado"
	label_detail.add_theme_color_override("font_color", ThemeManager.C_TEXT_DIM)

# ─────────────────────────────────────────
# HELPERS
# ─────────────────────────────────────────
func _clear_items() -> void:
	for child in items_container.get_children():
		child.queue_free()

func _refresh_inventory() -> void:
	_clear_items()
	_load_inventory()

func _update_unequip_button() -> void:
	var weapon = GameManager.get_equipped_weapon()
	button_unequip.disabled = weapon.is_empty()

func _update_equipped_label() -> void:
	var weapon   = GameManager.get_equipped_weapon()
	var player   = GameManager.get_player_data()
	var inv_size = player["inventory"].size()
	if weapon.is_empty():
		label_equipped.text = "Arma equipada: Ninguna\nEspacio: %d/%d" % [inv_size, Constants.INVENTORY_MAX_SIZE]
	else:
		var rarity = weapon.get("rarity", "common").to_lower()
		var icon   = Constants.RARITY_ICONS.get(rarity, "⚪")
		label_equipped.text = "Equipada: %s %s\nEspacio: %d/%d" % [
			icon, weapon.get("name", ""), inv_size, Constants.INVENTORY_MAX_SIZE
		]
		label_equipped.add_theme_color_override("font_color", ThemeManager.get_rarity_color(rarity))

func _update_stats() -> void:
	var player = GameManager.get_player_data()

	var weapon       = GameManager.get_equipped_weapon()
	var total_damage = player["damage"]
	if weapon != null:
		total_damage += weapon.get("damage", 0)

	var text = ""
	text += "❤️ HP: %d / %d\n" % [player["hp"], player["max_hp"]]
	text += "⚔️ Daño: %d\n"    % total_damage
	text += "🎖 Nivel: %d\n"   % player["level"]
	text += "✨ XP: %d / %d"   % [player["xp"], player["xp_to_next"]]
	label_stats.text = text

	xp_bar.max_value = player["xp_to_next"]
	xp_bar.value     = player["xp"]

# ─────────────────────────────────────────
# USAR CONSUMIBLE — US-AUDIO-009
# ─────────────────────────────────────────
func _on_button_use_pressed() -> void:
	if selected_item.is_empty():
		return
	if not selected_item.has("heal"):
		return

	var player = GameManager.get_player_data()
	if player["hp"] <= 0:
		label_detail.text = "💀 No puedes usar objetos muerto"
		label_detail.add_theme_color_override("font_color", ThemeManager.C_RED_BRIGHT)
		return
	if player["hp"] >= player["max_hp"]:
		label_detail.text = "❤️ HP ya está al máximo"
		label_detail.add_theme_color_override("font_color", ThemeManager.C_AMBER)
		return

	var heal_amount = selected_item.get("heal", 0)
	var old_hp      = player["hp"]
	player["hp"]    = min(player["hp"] + heal_amount, player["max_hp"])
	var real_heal   = player["hp"] - old_hp

	AudioManager.play_sfx("heal")
	GameManager.remove_item(selected_item)

	label_detail.text = "❤️ Recuperaste %d HP\n✨ Item consumido" % real_heal
	label_detail.add_theme_color_override("font_color", ThemeManager.C_GREEN)

	selected_item = {}
	_refresh_inventory()
	_update_stats()
	_update_use_button()
	GameManager._save_game()

# ─────────────────────────────────────────
# UI BOTÓN USE
# ─────────────────────────────────────────
func _update_use_button() -> void:
	button_use.visible = (
		not selected_item.is_empty()
		and selected_item.has("heal")
	)