# scripts/ui/zone_select.gd
extends Control

# Referencia al contenedor donde vamos a crear botones
@onready var zones_container = $MarginContainer/VBoxContainer/VBoxZones


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

	create_zone_buttons(data)

func create_zone_buttons(zones: Array) -> void:
	for zone in zones:
		var button = Button.new()
		
		button.text = zone["name"]
		button.custom_minimum_size = Vector2(0, 60)

		# Conectar señal dinámicamente
		button.pressed.connect(func():
			_on_zone_selected(zone)
		)

		zones_container.add_child(button)

func _on_zone_selected(zone: Dictionary) -> void:
	print("[ZoneSelect] Zona elegida: ", zone["name"])

	GameManager.set_selected_zone(zone)

	# Ir a combate (aunque no exista aún)
	SceneManager.go_to_combat()
