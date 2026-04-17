# scripts/ui/main_menu.gd
extends Control

# ─────────────────────────────────────────
# REFERENCIAS A NODOS DE LA UI
# El símbolo $ es un atajo para get_node()
# ─────────────────────────────────────────
@onready var button_play     = $VBoxContainer/ButtonPlay
@onready var label_title     = $VBoxContainer/LabelTitle
@onready var label_subtitle  = $VBoxContainer/LabelSubtitle

# ─────────────────────────────────────────
# _ready() se ejecuta cuando la escena carga
# ─────────────────────────────────────────
func _ready() -> void:
	print("[MainMenu] Escena cargada")
	_check_existing_save()

# ─────────────────────────────────────────
# Si ya hay una partida guardada, el botón
# dice "CONTINUAR" en lugar de "JUGAR"
# ─────────────────────────────────────────
func _check_existing_save() -> void:
	if SaveManager.has_save():
		button_play.text = "CONTINUAR"
	else:
		button_play.text = "JUGAR"

# ─────────────────────────────────────────
# Esta función la conectaste desde el editor
# Se ejecuta cuando el jugador toca "JUGAR"
# ─────────────────────────────────────────
func _on_button_play_pressed() -> void:
	print("[MainMenu] Botón presionado")

	if SaveManager.has_save():
		# cargar partida
		SaveManager.load_game()
	else:
		# nueva partida (solo una vez)
		if not GameManager.game_started:
			GameManager.reset_game()
			GameManager.game_started = true

	# SIEMPRE navegar
	SceneManager.go_to_zone_select()

	
func _on_button_inventory_pressed():
	SceneManager.go_to_inventory()
