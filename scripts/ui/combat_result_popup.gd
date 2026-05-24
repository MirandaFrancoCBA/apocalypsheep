extends Control
class_name CombatResultPopup
signal continue_pressed

@onready var label_title = $Panel/VBoxContainer/LabelTitle
@onready var label_xp = $Panel/VBoxContainer/LabelXP
@onready var label_loot = $Panel/VBoxContainer/LabelLoot
@onready var button_continue = $Panel/VBoxContainer/ButtonContinue


func show_result(
	xp: int,
	loot: Dictionary
) -> void:

	label_title.text = "🏆 VICTORIA"

	label_xp.text = "✨ XP Ganada: +" + str(xp)

	if loot.is_empty():
		label_loot.text = "❌ Sin loot"
	else:
		label_loot.text = "🎁 " + loot.get("name", "Item")

	scale = Vector2(0.8, 0.8)
	modulate.a = 0.0

	var tween = create_tween()

	tween.parallel().tween_property(
		self,
		"scale",
		Vector2.ONE,
		0.25
	)

	tween.parallel().tween_property(
		self,
		"modulate:a",
		1.0,
		0.25
	)


func _on_button_continue_pressed() -> void:
	print("BOTON APRETADO")
	continue_pressed.emit()

	queue_free()
