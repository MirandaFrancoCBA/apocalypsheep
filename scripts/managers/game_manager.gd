# scripts/managers/game_manager.gd
extends Node

# ─────────────────────────────────────────
# SEÑALES
# ─────────────────────────────────────────
signal player_data_changed
signal zone_selected(zone)
signal level_up(new_level)

# ─────────────────────────────────────────
# ESTADO DEL JUGADOR
# ─────────────────────────────────────────
var player_data: Dictionary = {
	"name":      "Oveja",
	"hp":        Constants.PLAYER_DEFAULT_HP,
	"max_hp":    Constants.PLAYER_DEFAULT_HP,
	"damage":    Constants.PLAYER_DEFAULT_DAMAGE,
	"level":     Constants.PLAYER_DEFAULT_LEVEL,
	"xp":        Constants.PLAYER_DEFAULT_XP,

	# 🔥 CAMBIO CLAVE → nunca null
	"equipped_weapon": {},

	"xp_to_next": 100,
	"inventory": []
}

# ─────────────────────────────────────────
# ESTADO DE PARTIDA
# ─────────────────────────────────────────
var selected_zone: Dictionary = {}
var last_combat_result: String = ""
var game_started: bool = false

func _ready() -> void:
	print("[GameManager] Iniciado correctamente")

# ─────────────────────────────────────────
# ZONA
# ─────────────────────────────────────────
func set_selected_zone(zone: Dictionary) -> void:
	selected_zone = zone
	emit_signal("zone_selected", zone)
	print("[GameManager] Zona seleccionada:", zone.get("name", "desconocida"))

func get_selected_zone() -> Dictionary:
	return selected_zone

# ─────────────────────────────────────────
# COMBATE
# ─────────────────────────────────────────
func set_combat_result(result: String) -> void:
	last_combat_result = result

func get_combat_result() -> String:
	return last_combat_result

# ─────────────────────────────────────────
# EQUIPO
# ─────────────────────────────────────────
func equip_item(item: Dictionary) -> void:
	if item.get("type") != "weapon":
		print("[Inventory] No es un arma")
		return

	player_data["equipped_weapon"] = item
	print("[Inventory] Arma equipada:", item.get("name", ""))

func unequip_item() -> void:
	var weapon = player_data.get("equipped_weapon", {})

	if weapon.is_empty():
		print("[Inventory] No hay arma equipada")
		return

	print("[Inventory] Arma desequipada:", weapon.get("name", ""))

	# 🔥 nunca null
	player_data["equipped_weapon"] = {}

func get_equipped_weapon() -> Dictionary:
	var weapon = player_data.get("equipped_weapon", {})

	if weapon == null:
		return {}

	return weapon

# ─────────────────────────────────────────
# PLAYER
# ─────────────────────────────────────────
func get_player_data() -> Dictionary:
	return player_data

func update_player_hp(new_hp: int) -> void:
	player_data["hp"] = clamp(new_hp, 0, player_data["max_hp"])
	emit_signal("player_data_changed")

func add_xp(amount: int) -> void:
	player_data["xp"] += amount
	print("[GameManager] XP ganada:", amount, "| Total:", player_data["xp"])
	_check_level_up()
	emit_signal("player_data_changed")

func add_item_to_inventory(item: Dictionary) -> void:
	player_data["inventory"].append(item)
	emit_signal("player_data_changed")
	print("[GameManager] Item agregado:", item.get("name", ""))

# ─────────────────────────────────────────
# NIVEL
# ─────────────────────────────────────────
func _check_level_up() -> void:
	while player_data["xp"] >= player_data["xp_to_next"]:
		player_data["xp"] -= player_data["xp_to_next"]
		player_data["level"] += 1
		player_data["max_hp"] += 20
		player_data["hp"] = player_data["max_hp"]
		player_data["damage"] += 2
		player_data["xp_to_next"] = int(player_data["xp_to_next"] * 1.5)

		emit_signal("level_up", player_data["level"])
		print("[GameManager] ¡LEVEL UP! Nivel:", player_data["level"])

# ─────────────────────────────────────────
# INVENTARIO
# ─────────────────────────────────────────
func remove_item(item: Dictionary) -> void:
	var inventory = player_data["inventory"]

	if item in inventory:
		inventory.erase(item)

		if player_data.get("equipped_weapon") == item:
			player_data["equipped_weapon"] = {}
			print("[Inventory] Item equipado eliminado → desequipado")

		print("[Inventory] Item eliminado:", item.get("name", ""))
	else:
		print("[Inventory] Item no encontrado")

# ─────────────────────────────────────────
# RESET
# ─────────────────────────────────────────
func reset_game() -> void:
	player_data = {
		"name":       "Oveja",
		"hp":         Constants.PLAYER_DEFAULT_HP,
		"max_hp":     Constants.PLAYER_DEFAULT_HP,
		"damage":     Constants.PLAYER_DEFAULT_DAMAGE,
		"level":      Constants.PLAYER_DEFAULT_LEVEL,
		"xp":         Constants.PLAYER_DEFAULT_XP,

		# 🔥 consistente
		"equipped_weapon": {},

		"xp_to_next": 100,
		"inventory":  []
	}

	selected_zone = {}
	last_combat_result = ""
	game_started = false

	emit_signal("player_data_changed")
	print("[GameManager] Partida reseteada")