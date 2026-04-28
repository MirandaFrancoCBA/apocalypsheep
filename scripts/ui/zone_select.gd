extends Control

@onready var zones_container = $MarginContainer/VBoxContainer/VBoxZones
@onready var button_back = $MarginContainer/VBoxContainer/ButtonBack

func _ready() -> void:
	print("[ZoneSelect] Cargando zonas...")
	load_zones()

func load_zones() -> void:
	var file = FileAccess.open("res://data/zones.json", FileAccess.READ)
	
	if file == null:
		push_error("[ZoneSelect] No se pudo abrir zones.json")
		return

	var content = file.get_as_text()
	var data = JSON.parse_string(content)

	if data == null:
		push_error("[ZoneSelect] Error parseando JSON")
		return

	_clear_zones()
	create_zone_buttons(data)

func _clear_zones():
	for child in zones_container.get_children():
		child.queue_free()

func create_zone_buttons(zones: Array) -> void:
	for zone in zones:
		var button = Button.new()
		
		var range = zone.get("level_range", [1, 1])
		var text = "%s (Lv %d-%d)" % [
			zone.get("name", "Zona"),
			range[0],
			range[1]
		]

		button.text = text
		button.custom_minimum_size = Vector2(0, 60)

		button.pressed.connect(func():
			_on_zone_selected(zone)
		)

		zones_container.add_child(button)

func _on_zone_selected(zone: Dictionary) -> void:
	print("[ZoneSelect] Zona elegida:", zone.get("name", ""))

	GameManager.set_selected_zone(zone)
	SceneManager.go_to_combat()

func _on_button_back_pressed() -> void:
	print("[ZoneSelect] Volviendo al menú")
	SceneManager.go_to_main_menu()