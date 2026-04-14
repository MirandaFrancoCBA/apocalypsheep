# scripts/core/combat_system.gd
extends Node

class_name CombatSystem

func start_combat() -> void:
    print("=== INICIO COMBATE ===")

    var player = Player.new().from_game_manager()
    var enemy = _generate_enemy()

    print("Jugador HP:", player.hp)
    print("Enemigo:", enemy.name, "HP:", enemy.hp)

    var result = _simulate_combat(player, enemy)

    GameManager.set_combat_result(result)

    print("Resultado:", result)

func _generate_enemy() -> Enemy:
    var zone = GameManager.get_selected_zone()

    var enemies_ids = zone.get("enemies", [])

    if enemies_ids.is_empty():
        push_error("Zona sin enemigos")
        return Enemy.new()

    var random_id = enemies_ids.pick_random()

    var all_enemies = _load_enemies()

    for e in all_enemies:
        if e["id"] == random_id:
            return Enemy.new().from_dict(e)

    push_error("Enemy no encontrado")
    return Enemy.new()

func _load_enemies() -> Array:
    var file = FileAccess.open("res://data/enemies.json", FileAccess.READ)

    if file == null:
        push_error("No se pudo abrir enemies.json")
        return []

    var data = JSON.parse_string(file.get_as_text())

    return data if data != null else []

func _simulate_combat(player: Player, enemy: Enemy) -> String:
    while player.hp > 0 and enemy.hp > 0:
        
        # jugador ataca
        enemy.hp -= player.damage
        print("Jugador pega:", player.damage)

        if enemy.hp <= 0:
            return "victory"

        # enemigo ataca
        player.hp -= enemy.damage
        print("Enemigo pega:", enemy.damage)

    return "defeat"