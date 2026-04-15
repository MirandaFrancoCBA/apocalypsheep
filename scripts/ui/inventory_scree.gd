#scripts/ui/inventory_screen.gd

extends Control

@onready var items_container = $MarginContainer/VBoxContainer/VBoxItems
@onready var button_back = $MarginContainer/VBoxContainer/ButtonBack

func _ready() -> void:
    print("[Inventory] Cargando inventario")

    _load_inventory()

func _load_inventory() -> void:
    var player = GameManager.get_player_data()
    var inventory = player["inventory"]

    if inventory.is_empty():
        _show_empty()
        return

    _create_items(inventory)

func _show_empty() -> void:
    var label = Label.new()
    label.text = "Inventario vacío"
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

    items_container.add_child(label)

func _create_items(items: Array) -> void:
    for item in items:
        var label = Label.new()

        var text = item.get("name", "Item") + " (" + item.get("type", "") + ")"
        label.text = text

        items_container.add_child(label)

func _on_button_back_pressed() -> void:
    SceneManager.go_to_zone_select()