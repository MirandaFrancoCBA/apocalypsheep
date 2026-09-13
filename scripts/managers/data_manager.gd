# scripts/managers/data_manager.gd
# ─────────────────────────────────────────
# DATA MANAGER
# Centraliza la lectura de todos los JSON.
# Cache en memoria — los archivos se leen una sola vez.
#
# USO:
#   DataManager.get_enemies()   → Array de dicts
#   DataManager.get_items()     → Array de dicts
#   DataManager.get_zones()     → Array de dicts
#   DataManager.get_enemy_by_id("raider") → Dictionary o {}
#   DataManager.get_items_by_rarity("rare") → Array
# ─────────────────────────────────────────
extends Node

const PATH_ENEMIES := "res://data/enemies.json"
const PATH_ITEMS   := "res://data/items.json"
const PATH_ZONES   := "res://data/zones.json"

var _enemies: Array = []
var _items:   Array = []
var _zones:   Array = []

# ─────────────────────────────────────────
# READY — precarga y valida todo al iniciar
# ─────────────────────────────────────────
func _ready() -> void:
	_enemies = _load_json(PATH_ENEMIES, "enemy")
	_items = _load_json(PATH_ITEMS, "item")
	_zones = _load_json(PATH_ZONES, "zone")

	print("[DataManager] Cargado — enemies:%d  items:%d  zones:%d" % [
		_enemies.size(),
		_items.size(),
		_zones.size()
	])


# ─────────────────────────────────────────
# GETTERS — devuelven copia para evitar
# mutaciones accidentales del cache
# ─────────────────────────────────────────
func get_enemies() -> Array:
	return _enemies.duplicate()

func get_items() -> Array:
	return _items.duplicate()

func get_zones() -> Array:
	return _zones.duplicate()

func get_enemy_by_id(id: String) -> Dictionary:
	for e in _enemies:
		if e.get("id", "") == id:
			return e.duplicate()
	push_warning("[DataManager] Enemy no encontrado: " + id)
	return {}

func get_item_by_id(id: String) -> Dictionary:
	for item in _items:
		if item.get("id", "") == id:
			return item.duplicate()
	push_warning("[DataManager] Item no encontrado: " + id)
	return {}

func get_items_by_rarity(rarity: String) -> Array:
	var result: Array = []
	for item in _items:
		if item.get("rarity", "common") == rarity:
			result.append(item.duplicate())
	return result

func get_zone_by_id(id: String) -> Dictionary:
	for z in _zones:
		if z.get("id", "") == id:
			return z.duplicate()
	push_warning("[DataManager] Zone no encontrada: " + id)
	return {}

func get_enemies_for_zone(zone: Dictionary) -> Array:
	var ids     = zone.get("enemies", [])
	var result: Array = []
	for id in ids:
		var e = get_enemy_by_id(id)
		if not e.is_empty():
			result.append(e)
	return result

# ─────────────────────────────────────────
# INTERNO
# ─────────────────────────────────────────
func _load_json(path: String, data_type: String) -> Array:
	if not FileAccess.file_exists(path):
		push_error("[DataManager] Archivo no encontrado: " + path)
		return []

	var file := FileAccess.open(path, FileAccess.READ)

	if file == null:
		push_error("[DataManager] No se pudo abrir: " + path)
		return []

	var parsed = JSON.parse_string(file.get_as_text())

	if typeof(parsed) != TYPE_ARRAY:
		push_error("[DataManager] JSON inválido en: " + path)
		return []

	var valid_entries: Array = []

	for index in range(parsed.size()):
		var entry = parsed[index]

		if typeof(entry) != TYPE_DICTIONARY:
			push_warning(
				"[DataManager] Entrada inválida en %s, índice %d: se esperaba Dictionary"
				% [path, index]
			)
			continue

		var is_valid := false

		match data_type:
			"enemy":
				is_valid = _is_valid_enemy(entry)

			"item":
				is_valid = _is_valid_item(entry)

			"zone":
				is_valid = _is_valid_zone(entry)

			_:
				push_error(
					"[DataManager] Tipo de datos desconocido: " + data_type
				)
				return []

		if is_valid:
			valid_entries.append(entry)
		else:
			var entry_id: String = str(entry.get("id", "<sin id>"))

			push_warning(
				"[DataManager] %s inválido descartado en %s, índice %d, id: %s"
				% [data_type, path, index, entry_id]
			)

	return valid_entries


func _is_valid_enemy(enemy: Dictionary) -> bool:
	if not _has_valid_string(enemy, "id"):
		return false

	if not _has_valid_string(enemy, "name"):
		return false

	if not _is_positive_number(enemy.get("hp")):
		return false

	if not _is_non_negative_number(enemy.get("damage")):
		return false

	if not _is_non_negative_number(enemy.get("xp")):
		return false

	if typeof(enemy.get("effect", "")) != TYPE_STRING:
		return false

	return true


func _is_valid_item(item: Dictionary) -> bool:
	if not _has_valid_string(item, "id"):
		return false

	if not _has_valid_string(item, "name"):
		return false

	if not _has_valid_string(item, "type"):
		return false

	if not _has_valid_string(item, "rarity"):
		return false

	var item_type: String = item["type"]

	match item_type:
		"weapon":
			if not _is_non_negative_number(item.get("damage")):
				return false

			if typeof(item.get("effect", "")) != TYPE_STRING:
				return false

		"consumable":
			if not _is_positive_number(item.get("heal")):
				return false

		_:
			return false

	return true


func _is_valid_zone(zone: Dictionary) -> bool:
	if not _has_valid_string(zone, "id"):
		return false

	if not _has_valid_string(zone, "name"):
		return false

	var enemies = zone.get("enemies")

	if typeof(enemies) != TYPE_ARRAY or enemies.is_empty():
		return false

	for enemy_id in enemies:
		if typeof(enemy_id) != TYPE_STRING:
			return false

		if enemy_id.strip_edges().is_empty():
			return false

	var level_range = zone.get("level_range")

	if typeof(level_range) != TYPE_ARRAY:
		return false

	if level_range.size() != 2:
		return false

	if not _is_positive_number(level_range[0]):
		return false

	if not _is_positive_number(level_range[1]):
		return false

	if float(level_range[0]) > float(level_range[1]):
		return false

	return true


func _has_valid_string(data: Dictionary, key: String) -> bool:
	if not data.has(key):
		return false

	var value = data[key]

	if typeof(value) != TYPE_STRING:
		return false

	return not value.strip_edges().is_empty()


func _is_positive_number(value: Variant) -> bool:
	if typeof(value) != TYPE_INT and typeof(value) != TYPE_FLOAT:
		return false

	return float(value) > 0.0


func _is_non_negative_number(value: Variant) -> bool:
	if typeof(value) != TYPE_INT and typeof(value) != TYPE_FLOAT:
		return false

	return float(value) >= 0.0