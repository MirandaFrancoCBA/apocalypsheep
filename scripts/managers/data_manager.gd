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
# READY — precarga todo al iniciar
# ─────────────────────────────────────────
func _ready() -> void:
	_enemies = _load_json(PATH_ENEMIES)
	_items   = _load_json(PATH_ITEMS)
	_zones   = _load_json(PATH_ZONES)
	print("[DataManager] Cargado — enemies:%d  items:%d  zones:%d" % [
		_enemies.size(), _items.size(), _zones.size()
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
func _load_json(path: String) -> Array:
	if not FileAccess.file_exists(path):
		push_error("[DataManager] Archivo no encontrado: " + path)
		return []
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("[DataManager] No se pudo abrir: " + path)
		return []
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_ARRAY:
		push_error("[DataManager] JSON inválido en: " + path)
		return []
	return parsed