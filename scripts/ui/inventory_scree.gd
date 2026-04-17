# scripts/ui/inventory_screen.gd

extends Control

@onready var items_container = $MarginContainer/VBoxContainer/VBoxItems
@onready var button_back = $MarginContainer/VBoxContainer/ButtonBack
@onready var label_detail = $MarginContainer/VBoxContainer/LabelDetail
@onready var button_equip = $MarginContainer/VBoxContainer/ButtonEquip
@onready var label_equipped = $MarginContainer/VBoxContainer/LabelEquipped
@onready var button_unequip = $MarginContainer/VBoxContainer/ButtonUnequip
@onready var button_delete = $MarginContainer/VBoxContainer/ButtonDelete
@onready var confirm_delete_dialog = $ConfirmDeleteDialog

var selected_item: Dictionary = {}

func _ready() -> void:
	print("[Inventory] Cargando inventario")
	_load_inventory()
	_update_equipped_label()
	_update_unequip_button()

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

		if item == GameManager.get_equipped_weapon():
			text += " ✔"

		button.text = text

		button.custom_minimum_size = Vector2(0, 50)

		button.pressed.connect(func():
			_on_item_selected(item)
		)

		items_container.add_child(button)

func _on_item_selected(item: Dictionary) -> void:
	selected_item = item

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

	label_detail.text = text

	print(text)

func _on_button_back_pressed() -> void:
	SceneManager.go_to_zone_select()

func _on_button_equip_pressed() -> void:
	if selected_item.is_empty():
		print("[Inventory] Ningún item seleccionado")
		return

	GameManager.equip_item(selected_item)
	_update_equipped_label()
	_update_unequip_button()
	_refresh_inventory()

func _on_button_unequip_pressed() -> void:
	GameManager.unequip_item()
	_update_equipped_label()
	_update_unequip_button()
	_refresh_inventory()

func _clear_items() -> void:
	for child in items_container.get_children():
		child.queue_free()


func _refresh_inventory() -> void:
	_clear_items()
	_load_inventory()

func _update_unequip_button() -> void:
	var weapon = GameManager.get_equipped_weapon()

	button_unequip.disabled = weapon == null

func _update_equipped_label() -> void:
	var weapon = GameManager.get_equipped_weapon()

	if weapon == null:
		label_equipped.text = "Arma equipada: Ninguna"
	else:
		label_equipped.text = "Arma equipada: " + weapon.get("name", "")
	




func _on_button_delete_pressed() -> void:
	if selected_item.is_empty():
		print("[Inventory] Ningún item seleccionado")
		return

	confirm_delete_dialog.popup_centered()


func _on_confirm_delete_dialog_confirmed() -> void:
	GameManager.remove_item(selected_item)

	selected_item = {}

	_refresh_inventory()
	_update_equipped_label()
	_update_unequip_button()

	label_detail.text = "Item eliminado"
