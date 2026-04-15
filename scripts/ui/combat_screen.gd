# scripts/ui/combat_screen.gd

extends Control

@onready var label_enemy      = $MarginContainer/VBoxContainer/LabelEnemy
@onready var label_enemy_hp   = $MarginContainer/VBoxContainer/LabelEnemyHP
@onready var label_player_hp  = $MarginContainer/VBoxContainer/LabelPlayerHP
@onready var button_attack    = $MarginContainer/VBoxContainer/ButtonAttack
@onready var label_result     = $MarginContainer/VBoxContainer/LabelResult

var player
var enemy
var combat_finished = false

func _ready() -> void:
    print("[Combat] Iniciado")

    _setup_combat()

func _setup_combat() -> void:
    player = Player.from_game_manager()
    enemy = _generate_enemy()

    label_enemy.text = "Enemigo: " + enemy.name

    _update_ui()

func _generate_enemy():
    var zone = GameManager.get_selected_zone()
    var enemies_ids = zone.get("enemies", [])

    var random_id = enemies_ids.pick_random()

    var file = FileAccess.open("res://data/enemies.json", FileAccess.READ)
    var data = JSON.parse_string(file.get_as_text())

    for e in data:
        if e["id"] == random_id:
            return Enemy.new().from_dict(e)

    return Enemy.new()

func _update_ui() -> void:
    label_player_hp.text = "Jugador HP: " + str(player.hp)
    label_enemy_hp.text  = "Enemigo HP: " + str(enemy.hp)

func _on_button_attack_pressed() -> void:
    if combat_finished:
        return

    # jugador ataca
    enemy.hp -= player.damage
    print("Jugador pega:", player.damage)

    if enemy.hp <= 0:
        _end_combat("victory")
        return

    # enemigo ataca
    player.hp -= enemy.damage
    print("Enemigo pega:", enemy.damage)

    if player.hp <= 0:
        _end_combat("defeat")
        return

    _update_ui()

func _end_combat(result: String) -> void:
    combat_finished = true

    GameManager.set_combat_result(result)

    if result == "victory":
        var loot = _generate_loot()

        var xp_gained = 20
        GameManager.add_xp(xp_gained)

        print("[XP] Ganaste:", xp_gained)
        
        if loot != null:
            GameManager.add_item_to_inventory({
                "id": loot.id,
                "name": loot.name,
                "type": loot.type
            })

            print("[Loot] Ganaste:", loot.name)

    label_result.text = "Resultado: " + result

    button_attack.disabled = true

    print("[Combat] Resultado:", result)

    await get_tree().create_timer(1.5).timeout
    SceneManager.go_to_result()

func _generate_loot():
    var file = FileAccess.open("res://data/items.json", FileAccess.READ)

    if file == null:
        push_error("No se pudo abrir items.json")
        return null

    var data = JSON.parse_string(file.get_as_text())

    if data == null or data.is_empty():
        push_error("Items vacíos")
        return null

    var random_item_data = data.pick_random()

    var item = Item.from_dict(random_item_data)

    return item