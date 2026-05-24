# scripts/ui/result_screen.gd
extends Control

@onready var label_title    = $CenterContainer/VBoxContainer/LabelTitle
@onready var label_result   = $CenterContainer/VBoxContainer/LabelResult
@onready var button_continue = $CenterContainer/VBoxContainer/ButtonContinue

func _ready() -> void:
	_apply_theme()
	_show_result()

func _apply_theme() -> void:
	ThemeManager.apply_scene_background(self)
	ThemeManager.apply_label_title(label_title)
	ThemeManager.apply_label_body(label_result)
	ThemeManager.apply_button_primary(button_continue)
	button_continue.custom_minimum_size = Vector2(240, 60)

func _show_result() -> void:
	var result    = GameManager.get_combat_result()
	var player    = GameManager.get_player_data()
	var inventory = player["inventory"]

	if result == "victory":
		label_title.text = "VICTORIA"
		label_title.add_theme_color_override("font_color", ThemeManager.C_GREEN)
	elif result == "defeat":
		label_title.text = "DERROTA"
		label_title.add_theme_color_override("font_color", ThemeManager.C_RED_BRIGHT)
	else:
		label_title.text = "?"
		label_title.add_theme_color_override("font_color", ThemeManager.C_TEXT_DIM)

	var lines := PackedStringArray()
	if inventory.size() > 0:
		var last_item = inventory[inventory.size() - 1]
		var rarity    = last_item.get("rarity", "common")
		var icon      = Constants.RARITY_ICONS.get(rarity, "⚪")
		lines.append("Loot:   " + icon + "  " + last_item["name"])
	lines.append("Nivel:  " + str(player["level"]))
	lines.append("XP:     %d / %d" % [player["xp"], player["xp_to_next"]])

	label_result.text = "\n".join(lines)

func _on_button_continue_pressed() -> void:
	SceneManager.go_to_zone_select()