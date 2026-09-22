# scripts/managers/game_manager.gd
extends Node

# ─────────────────────────────────────────
# SEÑALES
# ─────────────────────────────────────────
signal player_data_changed
signal zone_selected(zone)
signal level_up(new_level, hp_gain, damage_gain)
signal game_saved

const KEEP_ON_DEATH := [
	# futuro:
	# "gold",
	# "perks"
]
# ─────────────────────────────────────────
# ESTADO DEL JUGADOR
# ─────────────────────────────────────────
var player_data: Dictionary = create_default_player_data()

# ─────────────────────────────────────────
# ESTADO DE PARTIDA
# ─────────────────────────────────────────
var selected_zone: Dictionary = {}
var last_combat_result: String = ""
var last_combat_loot: Dictionary = {}
var game_started: bool = false


func _ready() -> void:
	print("[GameManager] Iniciado")
	_load_game()

# ─────────────────────────────────────────
# ZONA
# ─────────────────────────────────────────
func set_selected_zone(zone: Dictionary) -> void:
	selected_zone = zone
	emit_signal("zone_selected", zone)
	print("[GameManager] Zona seleccionada: %s" % zone.get("name", "desconocida"))

func get_selected_zone() -> Dictionary:
	return selected_zone

# ─────────────────────────────────────────
# COMBATE
# ─────────────────────────────────────────
func set_combat_result(result: String) -> void:
	last_combat_result = result

func get_combat_result() -> String:
	return last_combat_result

func set_combat_loot(loot: Dictionary) -> void:
	last_combat_loot = loot.duplicate(true)

func get_combat_loot() -> Dictionary:
	return last_combat_loot.duplicate(true)

# ─────────────────────────────────────────
# EQUIPO
# ─────────────────────────────────────────
func equip_item(item: Dictionary) -> void:
	if item.get("type") != "weapon":
		push_warning("[GameManager] No se puede equipar item: type=%s" % item.get("type", "desconocido"))
		return

	player_data["equipped_weapon"] = item
	print("[GameManager] Arma equipada: %s" % item.get("name", "desconocida"))
	emit_signal("player_data_changed")
	_save_game()

func unequip_item() -> void:
	var weapon = player_data.get("equipped_weapon", {})

	if weapon.is_empty():
		return

	print("[GameManager] Arma desequipada: %s" % weapon.get("name", "desconocida"))
	player_data["equipped_weapon"] = {}
	_save_game()
	emit_signal("player_data_changed")

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

func is_player_dead() -> bool:
	return player_data["hp"] <= 0

func kill_player() -> void:
	player_data["hp"] = 0
	print("[GameManager] Jugador muerto")
	_save_game()
	emit_signal("player_data_changed")

func revive_player(hp_amount: int = 1) -> void:
	player_data["hp"] = max(hp_amount, 1)
	print("[GameManager] Jugador revivido: hp=%d" % player_data["hp"])
	_save_game()
	emit_signal("player_data_changed")

func update_player_hp(new_hp: int) -> void:
	player_data["hp"] = clamp(new_hp, 0, player_data["max_hp"])
	emit_signal("player_data_changed")

func add_xp(amount: int) -> void:
	player_data["xp"] = maxi(
		int(player_data["xp"]) + amount,
		0
	)

	var xp_to_next: int = maxi(
		int(player_data["xp_to_next"]),
		1
	)

	while player_data["xp"] >= xp_to_next:
		player_data["xp"] -= xp_to_next
		_level_up()

		xp_to_next = maxi(
			int(player_data["xp_to_next"]),
			1
		)

	_save_game()
	emit_signal("player_data_changed")

func add_item_to_inventory(item: Dictionary) -> bool:
	var inventory = player_data["inventory"]

	if inventory.size() >= Constants.INVENTORY_MAX_SIZE:
		print("[GameManager] Inventario lleno: %d/%d" % [inventory.size(), Constants.INVENTORY_MAX_SIZE])
		return false

	inventory.append(item)
	_save_game()
	emit_signal("player_data_changed")
	print("[GameManager] Item agregado: %s" % item.get("name", "desconocido"))
	return true

# ─────────────────────────────────────────
# INVENTARIO
# ─────────────────────────────────────────
func remove_item(item: Dictionary) -> void:
	var inventory = player_data["inventory"]

	if item in inventory:
		inventory.erase(item)

		if player_data.get("equipped_weapon") == item:
			player_data["equipped_weapon"] = {}
			print("[GameManager] Item equipado eliminado y desequipado: %s" % item.get("name", "desconocido"))
		else:
			print("[GameManager] Item eliminado: %s" % item.get("name", "desconocido"))
	else:
		push_warning("[GameManager] No se pudo eliminar item: no está en inventario")

	_save_game()
	emit_signal("player_data_changed")

func create_default_player_data() -> Dictionary:
	return {
		"name": "Oveja",
		"hp": Constants.PLAYER_DEFAULT_HP,
		"max_hp": Constants.PLAYER_DEFAULT_HP,
		"damage": Constants.PLAYER_DEFAULT_DAMAGE,
		"level": Constants.PLAYER_DEFAULT_LEVEL,
		"xp": Constants.PLAYER_DEFAULT_XP,
		"equipped_weapon": {},
		"xp_to_next": calculate_xp_to_next(Constants.PLAYER_DEFAULT_LEVEL),
		"inventory": []
	}

# ─────────────────────────────────────────
# RESET
# ─────────────────────────────────────────
func reset_game() -> void:
	player_data = create_default_player_data()
	selected_zone = {}
	last_combat_result = ""
	last_combat_loot = {}
	game_started = false
	emit_signal("player_data_changed")
	print("[GameManager] Partida reseteada")
	_save_game()

# ─────────────────────────────────────────
# NIVEL
# ─────────────────────────────────────────
func calculate_xp_to_next(level: int) -> int:
	return int(
		Constants.XP_BASE
		* pow(level, Constants.XP_EXPONENT)
	)

func _level_up() -> void:
	var old_max_hp = player_data["max_hp"]
	var old_damage = player_data["damage"]
	player_data["level"] += 1
	player_data["max_hp"] += 10
	player_data["damage"] += 2
	player_data["hp"] = player_data["max_hp"]
	var hp_gain = player_data["max_hp"] - old_max_hp
	var damage_gain = player_data["damage"] - old_damage
	player_data["xp_to_next"] = calculate_xp_to_next(player_data["level"])

	emit_signal(
		"level_up",
		player_data["level"],
		hp_gain,
		damage_gain
	)

	print("[GameManager] Level up: nivel=%d hp_gain=%d damage_gain=%d" % [
		player_data["level"], hp_gain, damage_gain
	])

func _load_game() -> void:
	var data = SaveSystem.load_game()

	if data.is_empty():
		print("[GameManager] Save inexistente o inválido; usando partida nueva")
		reset_game()
		return

	var loaded_player = data.get("player_data", {})

	if typeof(loaded_player) != TYPE_DICTIONARY:
		push_error("[GameManager] Save inválido: player_data no es Dictionary; usando defaults")
		reset_game()
		return

	var defaults := create_default_player_data()
	player_data = defaults.duplicate(true)

	for key in defaults.keys():
		if loaded_player.has(key):
			player_data[key] = loaded_player[key]

	player_data["hp"] = clamp(
		int(player_data["hp"]),
		0,
		int(player_data["max_hp"])
	)

	player_data["xp"] = maxi(int(player_data["xp"]), 0)
	player_data["level"] = maxi(int(player_data["level"]), 1)

	if typeof(player_data["inventory"]) != TYPE_ARRAY:
		push_warning("[GameManager] Save inválido: inventory no es Array; usando []")
		player_data["inventory"] = []

	if typeof(player_data["equipped_weapon"]) != TYPE_DICTIONARY:
		push_warning("[GameManager] Save inválido: equipped_weapon no es Dictionary; usando {}")
		player_data["equipped_weapon"] = {}

	selected_zone = data.get("selected_zone", {})

	if typeof(selected_zone) != TYPE_DICTIONARY:
		push_warning("[GameManager] Save inválido: selected_zone no es Dictionary; usando {}")
		selected_zone = {}

	print("[GameManager] Partida cargada: nivel=%d hp=%d/%d xp=%d/%d inventario=%d" % [
		player_data["level"],
		player_data["hp"],
		player_data["max_hp"],
		player_data["xp"],
		player_data["xp_to_next"],
		player_data["inventory"].size()
	])

	emit_signal("player_data_changed")

func _save_game() -> void:
	var data = {
		"player_data": player_data
	}

	SaveSystem.save_game(data)
	emit_signal("game_saved")