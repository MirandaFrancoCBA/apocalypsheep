extends Control

@onready var label_result = $CenterContainer/VBoxContainer/LabelResult
@onready var button_continue = $CenterContainer/VBoxContainer/ButtonContinue

func _ready() -> void:
    print("[Result] Cargando pantalla")

    _show_result()

func _show_result() -> void:
    var result = GameManager.get_combat_result()
    var player = GameManager.get_player_data()  # 👈 FALTABA ESTO
    var inventory = player["inventory"]

    if result == "victory":
        label_result.text = "¡VICTORIA!"
    elif result == "defeat":
        label_result.text = "DERROTA..."
    else:
        label_result.text = "Resultado desconocido"

    # 👉 loot (después del resultado)
    if inventory.size() > 0:
        var last_item = inventory[inventory.size() - 1]
        label_result.text += "\nLoot: " + last_item["name"]

    # 👉 stats jugador
    label_result.text += "\nNivel: " + str(player["level"])
    label_result.text += "\nXP: " + str(player["xp"]) + "/" + str(player["xp_to_next"])

func _on_button_continue_pressed() -> void:
    print("[Result] Continuar...")

    SceneManager.go_to_zone_select()