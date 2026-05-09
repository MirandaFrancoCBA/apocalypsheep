extends Control
class_name LootPopup

@onready var label_title: Label = $Panel/VBoxContainer/LabelTitle
@onready var label_name: Label = $Panel/VBoxContainer/LabelItem


func show_loot(item: Dictionary) -> void:
	print("[LootPopup] show_loot ejecutado con:", item)

	if label_name == null:
		push_error("[LootPopup] label_name no está asignado en el inspector")
		return

	if item.is_empty():
		if label_title:
			label_title.text = "Sin loot"
		label_name.text = "❌ No obtuviste nada"
		label_name.modulate = Color.GRAY
	else:
		# ✅ normalizar rareza
		var rarity = item.get("rarity", "common").to_lower()
		var item_name = item.get("name", "Item")

		if label_title:
			label_title.text = "🎁 ¡Loot obtenido!"

		label_name.text = _rarity_icon(rarity) + " " + item_name

		match rarity:
			"common": label_name.modulate = Color.WHITE
			"rare":   label_name.modulate = Color.CORNFLOWER_BLUE
			"epic":   label_name.modulate = Color.MEDIUM_PURPLE
			_:        label_name.modulate = Color.WHITE

	scale = Vector2(0.7, 0.7)
	modulate.a = 0.0

	await get_tree().process_frame
	var start_y := position.y

	var tween = create_tween()
	tween.parallel().tween_property(self, "scale", Vector2.ONE, 0.25)
	tween.parallel().tween_property(self, "modulate:a", 2.0, 1.25)
	tween.tween_interval(5.5)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 1.0)
	tween.parallel().tween_property(self, "position:y", start_y - 20, 0.4)

	await tween.finished
	queue_free()

func _rarity_icon(rarity: String) -> String:
	match rarity:
		"common": return "⚪"
		"rare":   return "🔵"
		"epic":   return "🟣"
		_:        return "⚪"