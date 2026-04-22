extends Control

# ─────────────────────────────────────────
# EXPORTS (asignados desde el editor)
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

var combat_system := CombatSystem.new()

# ─────────────────────────────────────────
# READY
# ─────────────────────────────────────────
func _ready() -> void:
	_validate_nodes()
	_setup_combat()

# ─────────────────────────────────────────
# VALIDACIÓN
# ─────────────────────────────────────────
func _validate_nodes() -> void:
	var nodes = [
		label_enemy, label_enemy_hp, enemy_hp_bar, enemy_container,
		label_player_hp, player_hp_bar, player_container,
		label_result, log_container, button_attack
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

# ─────────────────────────────────────────
# BOTÓN
# ─────────────────────────────────────────
func _on_button_attack_pressed() -> void:
	if combat_finished:
		return

	button_attack.disabled = true
	# aplicar efectos antes del turno
	var logs = combat_system.apply_effects(player)
	for l in logs:
		add_log(l)

	logs = combat_system.apply_effects(enemy)
	for l in logs:
		add_log(l)

	_update_ui()
	# ATAQUE JUGADOR
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

	# ATAQUE ENEMIGO
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

# ─────────────────────────────────────────
# LOG (PRO + AUTO SCROLL + LIMIT)
# ─────────────────────────────────────────
func add_log(text: String) -> void:
	var lines = []
	if not label_result.text.is_empty():
		lines = label_result.text.split("\n")
	
	lines.append(text)
	
	if lines.size() > MAX_LOG_LINES:
		lines.remove_at(0)
		
	label_result.text = "\n".join(lines)
	
	# FORZAMOS la actualización del layout
	label_result.custom_minimum_size.y = 0 # Reseteamos para que recalcule
	
	# Esperamos dos frames para asegurar que el ScrollContainer vea el nuevo tamaño
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Ajustamos el scroll al final
	log_container.scroll_vertical = int(log_container.get_v_scroll_bar().max_value)

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
	var data = JSON.parse_string(file.get_as_text())

	for e in data:
		if e["id"] == random_id:
			return Enemy.from_dict(e)
	return Enemy.new()

func _end_combat(result: String) -> void:
	combat_finished = true

	GameManager.set_combat_result(result)

	if result == "victory":
		var xp_gained = 20
		GameManager.add_xp(xp_gained)
		add_log("✨ Ganaste " + str(xp_gained) + " XP")

	add_log("🏁 Resultado: " + result)

	button_attack.disabled = true

	await get_tree().create_timer(1.5).timeout
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
