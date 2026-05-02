# scripts/ui/main_menu.gd
extends Control

@onready var button_play = $VBoxContainer/ButtonPlay

func _ready() -> void:
	print("[MainMenu] Escena cargada")
	_check_existing_save()

func _check_existing_save() -> void:
	if SaveSystem.has_save():
		button_play.text = "CONTINUAR"
	else:
		button_play.text = "JUGAR"

func _on_button_play_pressed() -> void:
	print("[MainMenu] Botón presionado")

	if SaveSystem.has_save():
		SaveSystem.load_game()
	else:
		if not GameManager.game_started:
			GameManager.reset_game()
			GameManager.game_started = true

	SceneManager.go_to_zone_select()

func _on_button_inventory_pressed():
	SceneManager.go_to_inventory()