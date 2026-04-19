# scripts/ui/combat_screen.gd
extends Control

@onready var label_enemy      = $MarginContainer/VBoxContainer/LabelEnemy
@onready var label_enemy_hp   = $MarginContainer/VBoxContainer/EnemyContainer/LabelEnemyHP
@onready var label_player_hp  = $MarginContainer/VBoxContainer/PlayerContainer/LabelPlayerHP
@onready var button_attack    = $MarginContainer/VBoxContainer/ButtonAttack
@onready var label_result     = $MarginContainer/VBoxContainer/LabelResult
@onready var player_container = $MarginContainer/VBoxContainer/PlayerContainer
@onready var enemy_container  = $MarginContainer/VBoxContainer/EnemyContainer
@onready var player_hp_bar = $MarginContainer/VBoxContainer/PlayerContainer/PlayerHPBar
@onready var enemy_hp_bar  = $MarginContainer/VBoxContainer/EnemyContainer/EnemyHPBar

var player
var enemy
var combat_finished = false

var combat_system = CombatSystem.new()

func _ready() -> void:
	print("[Combat] Iniciado")
	_setup_combat()

func _setup_combat() -> void:
	player = Player.from_game_manager()
	enemy = _generate_enemy()
	player_hp_bar.min_value = 0
	player_hp_bar.max_value = player.hp
	player_hp_bar.value = player.hp

	enemy_hp_bar.min_value = 0
	enemy_hp_bar.max_value = enemy.hp
	enemy_hp_bar.value = enemy.hp

	label_enemy.text = "Enemigo: " + enemy.name
	_update_ui()

func _generate_enemy():
	var zone = GameManager.get_selected_zone()
	var enemies_ids = zone.get("enemies", [])

	var random_id = enemies_ids.pick_random()

	var file = FileAccess.open("res://data/enemies.json", FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())

	for e in data:
		if e["id"] == random_id:
			return Enemy.new().from_dict(e)

	return Enemy.new()

func _update_ui() -> void:
	label_player_hp.text = "Jugador HP: " + str(player.hp)
	label_enemy_hp.text  = "Enemigo HP: " + str(enemy.hp)

	player.hp = max(player.hp, 0)
	enemy.hp = max(enemy.hp, 0)

	player_hp_bar.value = player.hp
	enemy_hp_bar.value = enemy.hp

func _on_button_attack_pressed() -> void:
	if combat_finished:
		return

	button_attack.disabled = true

	# 🗡️ jugador ataca
	var result = combat_system.player_attack(player, enemy)

	await _flash(enemy_container, Color.RED)
	await _shake(enemy_container)

	if result["is_crit"]:
		await _flash(enemy_container, Color.YELLOW)

	var text = "Golpeaste por " + str(result["damage"])

	if result["is_crit"]:
		text = "💥 CRÍTICO! " + str(result["damage"])

	label_result.text = text

	_update_ui()

	if enemy.hp <= 0:
		_end_combat("victory")
		return

	await get_tree().create_timer(0.6).timeout

	# 👾 enemigo ataca
	result = combat_system.enemy_attack(player, enemy)

	await _flash(player_container, Color.RED)
	await _shake(player_container)

	if result["is_crit"]:
		await _flash(player_container, Color.YELLOW)

	var enemy_text = "Enemigo golpea por " + str(result["damage"])

	if result["is_crit"]:
		enemy_text = "⚠️ CRÍTICO enemigo! " + str(result["damage"])

	label_result.text += "\n" + enemy_text

	_update_ui()

	if player.hp <= 0:
		_end_combat("defeat")
		return

	button_attack.disabled = false

func _end_combat(result: String) -> void:
	combat_finished = true

	GameManager.set_combat_result(result)

	if result == "victory":
		var loot = _generate_loot()

		var xp_gained = 20
		GameManager.add_xp(xp_gained)

		print("[XP] Ganaste:", xp_gained)
		
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

	label_result.text = "Resultado: " + result

	button_attack.disabled = true

	print("[Combat] Resultado:", result)

	await get_tree().create_timer(1.5).timeout
	SceneManager.go_to_result()

func _generate_loot():
	var file = FileAccess.open("res://data/items.json", FileAccess.READ)

	if file == null:
		push_error("No se pudo abrir items.json")
		return null

	var data = JSON.parse_string(file.get_as_text())

	if data == null or data.is_empty():
		push_error("Items vacíos")
		return null

	var random_item_data = data.pick_random()
	return Item.from_dict(random_item_data)

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