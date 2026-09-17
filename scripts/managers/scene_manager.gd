# scripts/managers/scene_manager.gd
extends Node

signal scene_changed(scene_name)

func go_to(scene_path: String) -> void:
	if scene_path.is_empty():
		push_error("[SceneManager] Navegación cancelada: ruta de escena vacía")
		return

	if not ResourceLoader.exists(scene_path):
		push_error("[SceneManager] Navegación cancelada: escena inexistente path='%s'" % scene_path)
		return

	print("[SceneManager] Navegando a: %s" % scene_path)
	var error := get_tree().change_scene_to_file(scene_path)

	if error != OK:
		push_error("[SceneManager] Falló cambio de escena: path='%s' error=%d" % [scene_path, error])
		return

	await get_tree().process_frame
	var scene_name := scene_path.get_file().replace(".tscn", "")
	emit_signal("scene_changed", scene_name)

func go_to_main_menu() -> void:
	go_to(Constants.SCENE_MAIN_MENU)

func go_to_zone_select() -> void:
	go_to(Constants.SCENE_ZONE_SELECT)

func go_to_combat() -> void:
	go_to(Constants.SCENE_COMBAT)

func go_to_result() -> void:
	go_to(Constants.SCENE_RESULT)

func go_to_inventory() -> void:
	go_to(Constants.SCENE_INVENTORY)