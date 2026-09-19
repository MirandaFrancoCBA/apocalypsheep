extends Control
class_name LootPopup

@onready var label_title: Label = $Panel/VBoxContainer/LabelTitle
@onready var label_name: Label = $Panel/VBoxContainer/LabelItem
@onready var panel: Panel = $Panel


func _ready() -> void:
	_apply_responsive_layout()

func _apply_responsive_layout() -> void:
	await get_tree().process_frame
	var vp: Vector2 = get_viewport_rect().size
	var width: float = minf(vp.x * 0.84, 360.0)
	panel.custom_minimum_size = Vector2(width, 140.0)

func show_loot(item: Dictionary) -> void:
	if label_name == null:
		push_error("[LootPopup] No se puede mostrar loot: falta LabelItem")
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

		label_name.modulate = Constants.RARITY_COLORS.get(
			rarity,
			Color.WHITE
		)

	scale = Vector2(0.7, 0.7)
	modulate.a = 0.0

	await get_tree().process_frame
	var start_y := position.y

	var tween = create_tween()
	tween.parallel().tween_property(self , "scale", Vector2.ONE, 0.25)
	tween.parallel().tween_property(
	self ,
	"modulate:a",
	1.0,
	1.25
)
	tween.tween_interval(5.5)
	tween.parallel().tween_property(self , "modulate:a", 0.0, 1.0)
	tween.parallel().tween_property(self , "position:y", start_y - 20, 0.4)

	await tween.finished
	queue_free()

func _rarity_icon(rarity: String) -> String:
	return Constants.RARITY_ICONS.get(
		rarity,
		"⚪"
	)