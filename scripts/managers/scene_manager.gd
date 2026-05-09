# scripts/managers/scene_manager.gd
extends Node

# ─────────────────────────────────────────
# SEÑAL — avisamos cuando cambia la escena
# ─────────────────────────────────────────
signal scene_changed(scene_name)

# ─────────────────────────────────────────
# NAVEGACIÓN PRINCIPAL
# Recibe una ruta constante de Constants
# ─────────────────────────────────────────
func go_to(scene_path: String) -> void:

	if scene_path == "":
		push_error("[SceneManager] Ruta de escena vacía")
		return

	print("[SceneManager] Navegando a: ", scene_path)

	# 🎬 fade out
	await SceneTransition.fade_out()

	# 🔄 cambio escena
	var error = get_tree().change_scene_to_file(scene_path)

	if error != OK:
		push_error("[SceneManager] Error al cambiar escena: " + scene_path)

		# intentar volver visualmente
		await SceneTransition.fade_in()
		return

	# ⏳ esperar frame
	await get_tree().process_frame

	# 🎬 fade in
	await SceneTransition.fade_in()

	# 📢 señal
	var scene_name = scene_path.get_file().replace(".tscn", "")
	emit_signal("scene_changed", scene_name)

# ─────────────────────────────────────────
# ATAJOS — métodos descriptivos por pantalla
# Así en el código decís go_to_combat() y queda claro
# ─────────────────────────────────────────
func go_to_main_menu() -> void:
	go_to(Constants.SCENE_MAIN_MENU)

func go_to_zone_select() -> void:
	go_to(Constants.SCENE_ZONE_SELECT)

func go_to_combat() -> void:
	go_to(Constants.SCENE_COMBAT)

func go_to_result() -> void:
	go_to(Constants.SCENE_RESULT)

func go_to_inventory():
	go_to(Constants.SCENE_INVENTORY)