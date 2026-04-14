# scripts/managers/save_manager.gd
extends Node

func has_save() -> bool:
    # Por ahora siempre retorna false (sin guardado aún)
    # Lo implementamos completo en la US de persistencia
    return false

func load_game() -> void:
    print("[SaveManager] (stub) load_game llamado")

func save_game() -> void:
    print("[SaveManager] (stub) save_game llamado")