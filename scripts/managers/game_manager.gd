# scripts/managers/game_manager.gd
extends Node

# ─────────────────────────────────────────
# SEÑALES (eventos que otros nodos escuchan)
# ─────────────────────────────────────────
signal player_data_changed   # Se dispara cuando cambian los stats del jugador
signal zone_selected(zone)   # Se dispara cuando el jugador elige una zona
signal level_up(new_level)

# ─────────────────────────────────────────
# ESTADO DEL JUGADOR
# Este diccionario viaja entre todas las escenas
# ─────────────────────────────────────────
var player_data: Dictionary = {
    "name":      "Oveja",
    "hp":        Constants.PLAYER_DEFAULT_HP,
    "max_hp":    Constants.PLAYER_DEFAULT_HP,
    "damage":    Constants.PLAYER_DEFAULT_DAMAGE,
    "level":     Constants.PLAYER_DEFAULT_LEVEL,
    "xp":        Constants.PLAYER_DEFAULT_XP,
    "xp_to_next": 100,
    "inventory": []
}

# ─────────────────────────────────────────
# ESTADO DE LA PARTIDA
# ─────────────────────────────────────────
var selected_zone: Dictionary = {}   # Zona elegida por el jugador
var last_combat_result: String = ""  # "victory" o "defeat"
var game_started: bool = false       # ¿Ya hay una partida activa?

# ─────────────────────────────────────────
# INICIALIZACIÓN
# ─────────────────────────────────────────
func _ready() -> void:
    print("[GameManager] Iniciado correctamente")

# ─────────────────────────────────────────
# ZONA
# ─────────────────────────────────────────

# Guardar qué zona eligió el jugador
func set_selected_zone(zone: Dictionary) -> void:
    selected_zone = zone
    emit_signal("zone_selected", zone)
    print("[GameManager] Zona seleccionada: ", zone.get("name", "desconocida"))

# Obtener la zona actual
func get_selected_zone() -> Dictionary:
    return selected_zone

# ─────────────────────────────────────────
# RESULTADO DE COMBATE
# ─────────────────────────────────────────
func set_combat_result(result: String) -> void:
    # result debe ser "victory" o "defeat"
    last_combat_result = result

func get_combat_result() -> String:
    return last_combat_result

# ─────────────────────────────────────────
# PLAYER — getters y setters
# ─────────────────────────────────────────
func get_player_data() -> Dictionary:
    return player_data

func update_player_hp(new_hp: int) -> void:
    player_data["hp"] = clamp(new_hp, 0, player_data["max_hp"])
    emit_signal("player_data_changed")

func add_xp(amount: int) -> void:
    player_data["xp"] += amount
    print("[GameManager] XP ganada: ", amount, " | Total: ", player_data["xp"])
    _check_level_up()
    emit_signal("player_data_changed")

func add_item_to_inventory(item: Dictionary) -> void:
    player_data["inventory"].append(item)
    emit_signal("player_data_changed")
    print("[GameManager] Item agregado: ", item.get("name", "desconocido"))

# ─────────────────────────────────────────
# NIVEL
# ─────────────────────────────────────────
func _check_level_up() -> void:
    while player_data["xp"] >= player_data["xp_to_next"]:
        player_data["xp"]       -= player_data["xp_to_next"]
        player_data["level"]    += 1
        player_data["max_hp"]   += 20
        player_data["hp"]        = player_data["max_hp"]  # cura al subir de nivel
        player_data["damage"]   += 2
        player_data["xp_to_next"] = int(player_data["xp_to_next"] * 1.5)
        emit_signal("level_up", player_data["level"])
        print("[GameManager] ¡LEVEL UP! Nivel: ", player_data["level"])

# ─────────────────────────────────────────
# RESET (nueva partida)
# ─────────────────────────────────────────
func reset_game() -> void:
    player_data = {
        "name":       "Oveja",
        "hp":         Constants.PLAYER_DEFAULT_HP,
        "max_hp":     Constants.PLAYER_DEFAULT_HP,
        "damage":     Constants.PLAYER_DEFAULT_DAMAGE,
        "level":      Constants.PLAYER_DEFAULT_LEVEL,
        "xp":         Constants.PLAYER_DEFAULT_XP,
        "xp_to_next": 100,
        "inventory":  []
    }
    selected_zone      = {}
    last_combat_result = ""
    game_started       = false
    emit_signal("player_data_changed")
    print("[GameManager] Partida reseteada")