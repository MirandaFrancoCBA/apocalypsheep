# scripts/ui/inventory_screen.gd

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
		var button = Button.new()

		var text = item.get("name", "Item") + " (" + item.get("type", "") + ")"
		button.text = text

		button.custom_minimum_size = Vector2(0, 50)

		# conectar click
		button.pressed.connect(func():
			_on_item_selected(item)
		)

		items_container.add_child(button)

func _on_item_selected(item: Dictionary) -> void:
	print("[Inventory] Item seleccionado:", item)
	_show_item_detail(item)

func _show_item_detail(item: Dictionary) -> void:
	var text = ""

	text += "Nombre: " + item.get("name", "") + "\n"
	text += "Tipo: " + item.get("type", "") + "\n"

	if item.has("damage"):
		text += "Daño: " + str(item["damage"]) + "\n"

	if item.has("heal"):
		text += "Curación: " + str(item["heal"]) + "\n"

	if item.has("rarity"):
		text += "Rareza: " + item["rarity"] + "\n"

	print(text)

func _on_button_back_pressed() -> void:
	SceneManager.go_to_zone_select()