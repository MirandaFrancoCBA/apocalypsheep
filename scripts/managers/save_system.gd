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
		push_warning("[SaveSystem] No existe save")

		GameManager.reset_game()

		return {}

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)

	if file == null:
		push_error("[SaveSystem] No se pudo abrir save")

		GameManager.reset_game()

		return {}

	var content = file.get_as_text()

	# save vacío
	if content.strip_edges().is_empty():
		push_error("[SaveSystem] Save vacío")

		GameManager.reset_game()

		return {}

	var data = JSON.parse_string(content)

	# json corrupto
	if typeof(data) != TYPE_DICTIONARY:
		push_error("[SaveSystem] JSON corrupto")

		GameManager.reset_game()

		return {}

	# defaults seguros
	if not data.has("player_data"):
		data["player_data"] = {}

	if not data.has("selected_zone"):
		data["selected_zone"] = {}

	GameManager.player_data = data.get("player_data", {})
	GameManager.selected_zone = data.get("selected_zone", {})

	print("[SaveSystem] Juego cargado")

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