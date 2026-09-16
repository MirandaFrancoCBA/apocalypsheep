extends Node

const SAVE_PATH := "user://savegame.json"

# ─────────────────────────────────────────
# SAVE
# ─────────────────────────────────────────
func save_game(data: Dictionary) -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)

	if file == null:
		push_error("[SaveSystem] No se pudo abrir save para escritura: %s" % SAVE_PATH)
		return

	var json = JSON.stringify(data, "\t")
	file.store_string(json)

	print("[SaveSystem] Juego guardado")

# ─────────────────────────────────────────
# LOAD
# ─────────────────────────────────────────
func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		print("[SaveSystem] Sin save previo; se usará una partida nueva")
		return {}

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)

	if file == null:
		push_error("[SaveSystem] No se pudo abrir save para lectura: %s" % SAVE_PATH)
		return {}

	var content = file.get_as_text()

	if content.strip_edges().is_empty():
		push_error("[SaveSystem] Save vacío: %s" % SAVE_PATH)
		return {}

	var data = JSON.parse_string(content)

	if typeof(data) != TYPE_DICTIONARY:
		push_error("[SaveSystem] Save corrupto: raíz JSON no es Dictionary (%s)" % SAVE_PATH)
		return {}

	if not data.has("player_data"):
		data["player_data"] = {}

	if not data.has("selected_zone"):
		data["selected_zone"] = {}

	print("[SaveSystem] Juego cargado")
	return data

# ─────────────────────────────────────────
# DELETE SAVE
# ─────────────────────────────────────────
func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var error := DirAccess.remove_absolute(SAVE_PATH)
		if error != OK:
			push_error("[SaveSystem] No se pudo eliminar save: %s error=%d" % [SAVE_PATH, error])
			return
		print("[SaveSystem] Save eliminado")

# ─────────────────────────────────────────
# CHECK SAVE
# ─────────────────────────────────────────
func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)