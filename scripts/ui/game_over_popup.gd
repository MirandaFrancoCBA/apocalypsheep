extends Control
class_name GameOverPopup

@onready var label_stats = $ColorRect/Panel/MarginContainer/VBoxContainer/LabelStats

@onready var button_retry = $ColorRect/Panel/MarginContainer/VBoxContainer/ButtonRetry

@onready var button_menu = $ColorRect/Panel/MarginContainer/VBoxContainer/ButtonMenu

func _ready() -> void:

	var player = GameManager.get_player_data()

	label_stats.text = \
		"Nivel alcanzado: %d\nXP: %d" % [
			player["level"],
			player["xp"]
		]

	modulate.a = 0.0
	scale = Vector2(0.8, 0.8)

	var tween = create_tween()

	tween.parallel().tween_property(
		self,
		"modulate:a",
		1.0,
		0.4
	)

	tween.parallel().tween_property(
		self,
		"scale",
		Vector2.ONE,
		0.4
	)

	button_retry.pressed.connect(_on_retry_pressed)
	button_menu.pressed.connect(_on_menu_pressed)

func _on_retry_pressed() -> void:
	GameManager.reset_game()
	SceneManager.go_to_zone_select()

func _on_menu_pressed() -> void:
	SceneManager.go_to_main_menu()
