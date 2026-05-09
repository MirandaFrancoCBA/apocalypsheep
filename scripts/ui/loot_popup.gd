extends Control
class_name LootPopup

@export var label_name: Label

func show_loot(item: Dictionary) -> void:

	if item.is_empty():
		label_name.text = "❌ No obtuviste nada"
	else:
		var rarity = item.get("rarity", "common")
		var item_name = item.get("name", "Item")

		label_name.text = _rarity_icon(rarity) + " " + item_name

		match rarity:
			"common":
				label_name.modulate = Color.WHITE

			"rare":
				label_name.modulate = Color(0.4, 0.6, 1.0)

			"epic":
				label_name.modulate = Color(0.7, 0.4, 1.0)

	var tween = create_tween()

	scale = Vector2(0.7, 0.7)
	modulate.a = 0.0

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

	tween.tween_interval(1.5)

	tween.parallel().tween_property(
		self,
		"modulate:a",
		0.0,
		0.4
	)

	tween.parallel().tween_property(
		self,
		"position:y",
		position.y - 20,
		0.4
	)

	await tween.finished

	queue_free()

func _rarity_icon(rarity: String) -> String:
	match rarity:
		"common":
			return "⚪"

		"rare":
			return "🔵"

		"epic":
			return "🟣"

		_:
			return "❓"