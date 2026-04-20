extends Control

# ─────────────────────────────────────────
# EXPORTS (asignás desde el editor)
# ─────────────────────────────────────────
@export var player_container: Control
@export var enemy_container: Control

@export var label_player_hp: Label
@export var player_hp_bar: ProgressBar

@export var label_enemy: Label
@export var label_enemy_hp: Label
@export var enemy_hp_bar: ProgressBar

@export var button_attack: Button
@export var label_result: Label

# ─────────────────────────────────────────
# ESTADO
# ─────────────────────────────────────────
var player: Player
var enemy: Enemy
var combat_finished := false

var combat_system := CombatSystem.new()

# ─────────────────────────────────────────
# READY
# ─────────────────────────────────────────
func _ready() -> void:
	print("[Combat] Iniciado")

	_validate_nodes()
	_setup_combat()

# ─────────────────────────────────────────
# VALIDACIÓN (anti errores silenciosos)
# ─────────────────────────────────────────
func _validate_nodes() -> void:
	var nodes = [
		player_container, enemy_container,
		label_player_hp, player_hp_bar,
		label_enemy, label_enemy_hp, enemy_hp_bar,
		button_attack, label_result
	]

	for n in nodes:
		if n == null:
			push_error("[CombatScreen] Nodo no asignado en inspector")

# ─────────────────────────────────────────
# SETUP
# ─────────────────────────────────────────
func _setup_combat() -> void:
	player = Player.from_game_manager()
	enemy = _generate_enemy()

	# HP Bars
	player_hp_bar.min_value = 0
	player_hp_bar.max_value = player.max_hp
	player_hp_bar.value = player.hp

	enemy_hp_bar.min_value = 0
	enemy_hp_bar.max_value = enemy.hp
	enemy_hp_bar.value = enemy.hp

	label_enemy.text = "Enemigo: " + enemy.name

	_update_ui()

# ─────────────────────────────────────────
# UI
# ─────────────────────────────────────────
func _update_ui() -> void:
	player.hp = max(player.hp, 0)
	enemy.hp = max(enemy.hp, 0)

	label_player_hp.text = "HP: " + str(player.hp)
	label_enemy_hp.text  = "HP: " + str(enemy.hp)

	player_hp_bar.value = player.hp
	enemy_hp_bar.value  = enemy.hp

# ─────────────────────────────────────────
# INPUT
# ─────────────────────────────────────────
func _on_button_attack_pressed() -> void:
	if combat_finished:
		return

	button_attack.disabled = true

	await _player_turn()

	if not enemy.is_alive():
		_end_combat("victory")
		return

	await get_tree().create_timer(0.6).timeout

	await _enemy_turn()

	if player.hp <= 0:
		_end_combat("defeat")
		return

	button_attack.disabled = false

# ─────────────────────────────────────────
# TURNOS (Clean separation)
# ─────────────────────────────────────────
func _player_turn() -> void:
	var result = combat_system.player_attack(player, enemy)

	await _flash(enemy_container, Color.RED)
	await _shake(enemy_container)

	if result["is_crit"]:
		await _flash(enemy_container, Color.YELLOW)

	_set_result_text(result, true)

	_update_ui()

func _enemy_turn() -> void:
	var result = combat_system.enemy_attack(player, enemy)

	await _flash(player_container, Color.RED)
	await _shake(player_container)

	if result["is_crit"]:
		await _flash(player_container, Color.YELLOW)

	_set_result_text(result, false)

	_update_ui()

# ─────────────────────────────────────────
# TEXTO RESULTADO
# ─────────────────────────────────────────
func _set_result_text(result: Dictionary, is_player: bool) -> void:
	var text := ""

	if is_player:
		text = "Golpeaste por " + str(result["damage"])
		if result["is_crit"]:
			text = "💥 CRÍTICO! " + str(result["damage"])
	else:
		text = "Enemigo golpea por " + str(result["damage"])
		if result["is_crit"]:
			text = "⚠️ CRÍTICO enemigo! " + str(result["damage"])

	label_result.text += "\n" + text

# ─────────────────────────────────────────
# FIN DE COMBATE
# ─────────────────────────────────────────
func _end_combat(result: String) -> void:
	combat_finished = true
	button_attack.disabled = true

	GameManager.set_combat_result(result)

	if result == "victory":
		_handle_victory()

	label_result.text += "\nResultado: " + result

	print("[Combat] Resultado:", result)

	await get_tree().create_timer(1.5).timeout
	SceneManager.go_to_result()

# ─────────────────────────────────────────
# VICTORIA
# ─────────────────────────────────────────
func _handle_victory() -> void:
	var xp_gained = 20
	GameManager.add_xp(xp_gained)
	print("[XP] Ganaste:", xp_gained)

	var loot = _generate_loot()

	if loot != null:
		GameManager.add_item_to_inventory({
			"id": loot.id,
			"name": loot.name,
			"type": loot.type,
			"damage": loot.damage,
			"heal": loot.heal,
			"rarity": loot.rarity
		})

		print("[Loot] Ganaste:", loot.name)

# ─────────────────────────────────────────
# DATA
# ─────────────────────────────────────────
func _generate_enemy() -> Enemy:
	var zone = GameManager.get_selected_zone()
	var enemies_ids = zone.get("enemies", [])

	if enemies_ids.is_empty():
		push_error("Zona sin enemigos")
		return Enemy.new()

	var random_id = enemies_ids.pick_random()

	var file = FileAccess.open("res://data/enemies.json", FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())

	for e in data:
		if e["id"] == random_id:
			return Enemy.new().from_dict(e)

	return Enemy.new()

func _generate_loot():
	var file = FileAccess.open("res://data/items.json", FileAccess.READ)

	if file == null:
		push_error("No se pudo abrir items.json")
		return null

	var data = JSON.parse_string(file.get_as_text())

	if data == null or data.is_empty():
		push_error("Items vacíos")
		return null

	return Item.from_dict(data.pick_random())

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
		node.position.x += randi_range(-5, 5)
		node.position.y += randi_range(-5, 5)
		await get_tree().create_timer(0.02).timeout

	node.position = original_pos
