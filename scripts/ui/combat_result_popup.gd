extends Control
class_name CombatResultPopup

@onready var label_title: Label = $Panel/VBoxContainer/LabelTitle
@onready var label_xp: Label = $Panel/VBoxContainer/LabelXP
@onready var label_loot: Label = $Panel/VBoxContainer/LabelLoot
@onready var label_continue: Label = $Panel/VBoxContainer/LabelContinue

func show_result(
	result: String,
	xp: int,
	loot: Dictionary
) -> void:

	# ─────────────────────────
	# TITLE
	# ─────────────────────────
	if result == "victory":
		label_title.text = "🏆 VICTORIA"
		label_title.modulate = Color.GOLD
	else:
		label_title.text = "💀 DERROTA"
		label_title.modulate = Color.RED

	# ─────────────────────────
	# XP
	# ─────────────────────────
	label_xp.text = "⭐ XP: +" + str(xp)

	# ─────────────────────────
	# LOOT
	# ─────────────────────────
	if loot.is_empty():
		label_loot.text = "❌ Sin loot"
		label_loot.modulate = Color.GRAY
	else:
		var rarity = loot.get("rarity", "common")
		var item_name = loot.get("name", "Item")

		label_loot.text = _rarity_icon(rarity) + " " + item_name

		match rarity:
			"common":
				label_loot.modulate = Color.WHITE

			"rare":
				label_loot.modulate = Color(0.4, 0.6, 1.0)

			"epic":
				label_loot.modulate = Color(0.7, 0.4, 1.0)

	# ─────────────────────────
	# ANIM
	# ─────────────────────────
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