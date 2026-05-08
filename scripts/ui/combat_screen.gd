extends Control

# ─────────────────────────────────────────
# EXPORTS
# ─────────────────────────────────────────
@export var label_enemy: Label
@export var label_enemy_hp: Label
@export var enemy_hp_bar: ProgressBar
@export var enemy_container: Control

@export var label_player_hp: Label
@export var player_hp_bar: ProgressBar
@export var player_container: Control

@export var label_result: Label
@export var log_container: ScrollContainer

@export var button_attack: Button
@export var button_defend: Button

@export var player_effects_container: HBoxContainer
@export var enemy_effects_container: HBoxContainer
@export var label_weapon: Label
const LevelUpPopup = preload("res://scenes/level_up_popup.tscn")
@export var xp_bar: ProgressBar
@export var label_xp: Label

# ─────────────────────────────────────────
# CONFIG
# ─────────────────────────────────────────
const MAX_LOG_LINES := 8

# ─────────────────────────────────────────
# DATA
# ─────────────────────────────────────────
var player: Player
var enemy: Enemy
var combat_finished := false
var waiting_for_input := false

var combat_system := CombatSystem.new()

# ─────────────────────────────────────────
# READY
# ─────────────────────────────────────────
func _ready() -> void:
	_validate_nodes()
	_setup_combat()

	GameManager.level_up.connect(_on_level_up)
	GameManager.player_data_changed.connect(_update_xp_ui)

func _on_level_up(new_level: int) -> void:
	add_log("🎉 LEVEL UP! Nivel " + str(new_level))

	var popup = LevelUpPopup.instantiate()
	add_child(popup)

	popup.show_level_up(new_level)


# ─────────────────────────────────────────
# VALIDACIÓN
# ─────────────────────────────────────────
func _validate_nodes() -> void:
	var nodes = [
		label_enemy, label_enemy_hp, enemy_hp_bar, enemy_container,
		label_player_hp, player_hp_bar, player_container,
		label_result, log_container, button_attack, button_defend
	]

	for n in nodes:
		if n == null:
			push_error("[CombatScreen] Nodo no asignado en inspector")
			return

# ─────────────────────────────────────────
# SETUP
# ─────────────────────────────────────────
func _setup_combat() -> void:
	player = Player.from_game_manager()
	enemy = _generate_enemy()

	player_hp_bar.min_value = 0
	player_hp_bar.max_value = player.max_hp
	player_hp_bar.value = player.hp

	enemy_hp_bar.min_value = 0
	enemy_hp_bar.max_value = enemy.max_hp
	enemy_hp_bar.value = enemy.hp

	label_enemy.text = "Enemigo: " + enemy.name

	label_result.text = ""
	add_log("⚔️ Combate contra " + enemy.name)

	_update_ui()
	_update_weapon_ui()
	_update_xp_ui()
# ─────────────────────────────────────────
# UI UPDATE
# ─────────────────────────────────────────
func _update_ui() -> void:
	player.hp = max(player.hp, 0)
	enemy.hp = max(enemy.hp, 0)

	label_player_hp.text = "HP: " + str(player.hp)
	label_enemy_hp.text  = "HP: " + str(enemy.hp)

	player_hp_bar.value = player.hp
	enemy_hp_bar.value = enemy.hp

	_update_effects_ui()
	_update_xp_ui()

func _update_xp_ui():
	var data = GameManager.get_player_data()

	xp_bar.max_value = data["xp_to_next"]
	xp_bar.value = data["xp"]

	label_xp.text = "XP: %d / %d" % [data["xp"], data["xp_to_next"]]


# ─────────────────────────────────────────
# ATAQUE
# ─────────────────────────────────────────
func _on_button_attack_pressed() -> void:
	if combat_finished:
		return

	button_attack.disabled = true
	button_defend.disabled = true

	# efectos turno
	var logs = combat_system.apply_effects(player)
	for l in logs:
		add_log(l)

	logs = combat_system.apply_effects(enemy)
	for l in logs:
		add_log(l)

	_update_ui()

	# ataque jugador
	var result = combat_system.player_attack(player, enemy)

	await _flash(enemy_container, Color.RED)
	await _shake(enemy_container)

	if result["is_crit"]:
		await _flash(enemy_container, Color.YELLOW)
		add_log("💥 CRÍTICO! " + str(result["damage"]))
	else:
		add_log("Golpeaste por " + str(result["damage"]))

	_update_ui()

	if enemy.hp <= 0:
		_end_combat("victory")
		return

	await get_tree().create_timer(0.6).timeout

	# ataque enemigo
	result = combat_system.enemy_attack(player, enemy)

	await _flash(player_container, Color.RED)
	await _shake(player_container)

	if result["is_crit"]:
		await _flash(player_container, Color.YELLOW)
		add_log("⚠️ CRÍTICO enemigo! " + str(result["damage"]))
	else:
		add_log("Enemigo golpea por " + str(result["damage"]))

	_update_ui()

	if player.hp <= 0:
		_end_combat("defeat")
		return

	button_attack.disabled = false
	button_defend.disabled = false

# ─────────────────────────────────────────
# DEFENSA
# ─────────────────────────────────────────
func _on_button_defend_pressed() -> void:
	if combat_finished:
		return

	button_attack.disabled = true
	button_defend.disabled = true

	player.start_defense()
	add_log("🛡️ Te preparás para defender")

	await get_tree().create_timer(0.5).timeout

	var result = combat_system.enemy_attack(player, enemy)

	await _flash(player_container, Color.BLUE)
	await _shake(player_container)

	if result["is_crit"]:
		add_log("⚠️ CRÍTICO enemigo! " + str(result["damage"]))
	else:
		add_log("Enemigo golpea por " + str(result["damage"]))

	_update_ui()

	if player.hp <= 0:
		_end_combat("defeat")
		return

	button_attack.disabled = false
	button_defend.disabled = false

# ─────────────────────────────────────────
# LOG
# ─────────────────────────────────────────
func add_log(text: String) -> void:
	var lines: Array = []

	if not label_result.text.is_empty():
		lines = label_result.text.split("\n")

	lines.append(text)

	while lines.size() > MAX_LOG_LINES:
		lines.remove_at(0)

	label_result.text = "\n".join(lines)

	await get_tree().process_frame

	var scrollbar = log_container.get_v_scroll_bar()
	if scrollbar:
		log_container.scroll_vertical = int(scrollbar.max_value)

# ─────────────────────────────────────────
# COMBATE
# ─────────────────────────────────────────
func _generate_enemy() -> Enemy:
	var zone = GameManager.get_selected_zone()
	var enemies_ids = zone.get("enemies", [])

	if enemies_ids.is_empty():
		push_error("Zona sin enemigos")
		return Enemy.new()

	var random_id = enemies_ids.pick_random()

	var file = FileAccess.open("res://data/enemies.json", FileAccess.READ)
	if file == null:
		push_error("No se pudo abrir enemies.json")
		return Enemy.new()

	var data = JSON.parse_string(file.get_as_text())

	for e in data:
		if e.get("id", "") == random_id:
			var new_enemy = Enemy.from_dict(e)

			if new_enemy == null:
				push_error("Enemy.from_dict devolvió null")
				return Enemy.new()

			_apply_enemy_scaling(new_enemy)

			return new_enemy

	push_error("Enemy ID no encontrado: " + str(random_id))
	return Enemy.new()

func _end_combat(result: String) -> void:
	combat_finished = true
	waiting_for_input = true

	GameManager.set_combat_result(result)

	if result == "victory":
		var xp_gained := 20
		GameManager.add_xp(xp_gained)

		add_log("✨ Ganaste " + str(xp_gained) + " XP")

		# 💥 feedback visible
		label_result.text += "\n⭐ +" + str(xp_gained) + " XP"

		if _roll_drop():
			var loot = _generate_loot()

			if loot.size() > 0:
				GameManager.add_item_to_inventory(loot)
				add_log("🎁 Obtuviste: " + loot.get("name", "Item"))
			else:
				add_log("❌ No obtuviste nada...")

	add_log("🏁 Resultado: " + result)
	add_log("👉 Tocar para continuar")

	button_attack.disabled = true
	button_defend.disabled = true
	GameManager._save_game()

# ─────────────────────────────────────────
# UI EFECTOS
# ─────────────────────────────────────────
func _update_effects_ui() -> void:
	_draw_effects(player.effects, player_effects_container)
	_draw_effects(enemy.effects, enemy_effects_container)

func _draw_effects(effects: Array, container: HBoxContainer) -> void:
	for child in container.get_children():
		child.queue_free()

	for effect in effects:
		var label = Label.new()

		var icon = _effect_icon(effect["type"])
		var duration = effect["duration"]

		label.text = icon if effect["type"] == "stun" else icon + " x" + str(duration)
		label.add_theme_font_size_override("font_size", 16)

		container.add_child(label)

func _effect_icon(type: String) -> String:
	match type:
		"bleed": return "🩸"
		"poison": return "☠️"
		"burn": return "🔥"
		"stun": return "💫"
		_: return "❓"

# ─────────────────────────────────────────
# UI ARMA
# ─────────────────────────────────────────
func _update_weapon_ui() -> void:
	var weapon = player.equipped_weapon

	if weapon == null:
		label_weapon.text = "Arma: Sin arma"
	else:
		label_weapon.text = "Arma: " + weapon.get("name", "???")

		var effect = weapon.get("effect", "")
		if effect != "":
			label_weapon.text += " (" + _effect_icon(effect) + ")"

# ─────────────────────────────────────────
# INPUT FINAL
# ─────────────────────────────────────────
func _input(event):
	if waiting_for_input and event.is_pressed():
		waiting_for_input = false
		SceneManager.go_to_result()

# ─────────────────────────────────────────
# FX
# ─────────────────────────────────────────
func _flash(node: Control, color: Color) -> void:
	var original = node.modulate
	node.modulate = color
	await get_tree().create_timer(0.1).timeout
	node.modulate = original

func _shake(node: Control) -> void:
	var original_pos = node.position

	for i in range(5):
		node.position.x += float(randi_range(-5, 5))
		node.position.y += float(randi_range(-5, 5))
		await get_tree().create_timer(0.02).timeout

	node.position = original_pos

# ─────────────────────────────────────────
# LOOT
# ─────────────────────────────────────────
func _generate_loot() -> Dictionary:
	var file = FileAccess.open("res://data/items.json", FileAccess.READ)

	if file == null:
		return {}

	var data = JSON.parse_string(file.get_as_text())

	if data == null or data.is_empty():
		return {}

	var rarity = _roll_rarity()

	var filtered_items: Array = []

	for item in data:
		if item.get("rarity", "common") == rarity:
			filtered_items.append(item)

	if filtered_items.is_empty():
		filtered_items = data

	return filtered_items.pick_random()

func _roll_rarity() -> String:
	var total_weight := 0

	for w in Constants.RARITY_WEIGHTS.values():
		total_weight += w

	var roll = randi_range(1, total_weight)
	var cumulative = 0

	for rarity in Constants.RARITY_WEIGHTS.keys():
		cumulative += Constants.RARITY_WEIGHTS[rarity]
		if roll <= cumulative:
			return rarity

	return "common"

func _roll_drop() -> bool:
	return randi_range(1, 100) <= Constants.LOOT_DROP_CHANCE

# ─────────────────────────────────────────
# SCALING
# ─────────────────────────────────────────
func _apply_enemy_scaling(target_enemy: Enemy) -> void:
	var zone = GameManager.get_selected_zone()
	var level_range = zone.get("level_range", [1, 1])

	var final_level = randi_range(level_range[0], level_range[1])

	target_enemy.max_hp += final_level * 5
	target_enemy.hp = target_enemy.max_hp
	target_enemy.damage += final_level * 2

	print("[ENEMY] Nivel:", final_level, "HP:", target_enemy.hp, "DMG:", target_enemy.damage)
