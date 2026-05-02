extends Node
    
const SAVE_PATH := "user://savegame.json"

# ─────────────────────────────────────────
# SAVE
# ─────────────────────────────────────────
func save_game(data: Dictionary) -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)

	if file == null:
		push_error("[SaveSystem] Error abriendo archivo para guardar")
		return

	var json = JSON.stringify(data, "\t")
	file.store_string(json)

	print("[SaveSystem] Juego guardado correctamente")

# ─────────────────────────────────────────
# LOAD
# ─────────────────────────────────────────
func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		print("[SaveSystem] No existe save → nueva partida")
		return {}

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)

	if file == null:
		push_error("[SaveSystem] Error abriendo archivo de carga")
		return {}

	var content = file.get_as_text()
	var data = JSON.parse_string(content)

	if data == null:
		push_error("[SaveSystem] Error parseando JSON")
		return {}

	print("[SaveSystem] Juego cargado correctamente")
	return data

# ─────────────────────────────────────────
# DELETE SAVE
# ─────────────────────────────────────────
func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
		print("[SaveSystem] Save eliminado")

# ─────────────────────────────────────────
# CHECK SAVE
# ─────────────────────────────────────────
func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)