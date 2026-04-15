extends Control

@onready var label_result = $CenterContainer/VBoxContainer/LabelResult
@onready var button_continue = $CenterContainer/VBoxContainer/ButtonContinue

func _ready() -> void:
    print("[Result] Cargando pantalla")

    _show_result()

func _show_result() -> void:
    var result = GameManager.get_combat_result()

    if result == "victory":
        label_result.text = "¡VICTORIA!"
    elif result == "defeat":
        label_result.text = "DERROTA..."
    else:
        label_result.text = "Resultado desconocido"

func _on_button_continue_pressed() -> void:
    print("[Result] Continuar...")

    SceneManager.go_to_zone_select()