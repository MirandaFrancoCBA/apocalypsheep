extends Control
class_name CombatResultPopup

@onready var label_title = $ColorRect/Panel/VBoxContainer/LabelTitle
@onready var label_xp = $ColorRect/Panel/VBoxContainer/LabelXP
@onready var label_loot = $ColorRect/Panel/VBoxContainer/LabelLoot

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