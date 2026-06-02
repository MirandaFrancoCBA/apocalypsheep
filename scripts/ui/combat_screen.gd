# scripts/ui/combat_screen.gd
# ─────────────────────────────────────────
# COMBAT SCREEN
# Cambios vs versión anterior:
#   US-AUDIO-003 — SFX al defender
#   US-AUDIO-004 — SFX de efectos de estado (bleed/poison/burn/stun)
#   US-AUDIO-007 — música de combate al entrar/salir
#   US-AUDIO-009 — feedback sonoro en botones Atacar / Defender / Historial
#   US-UI-013    — historial con botón que indica estado visual claro
# ─────────────────────────────────────────
extends Control

# ─────────────────────────────────────────
# EXPORTS
# ─────────────────────────────────────────
@export var label_enemy:              Label
@export var label_enemy_hp:           Label
@export var enemy_hp_bar:             ProgressBar
@export var enemy_container:          Control
@export var death_overlay:            ColorRect
@export var label_player_hp:          Label
@export var player_hp_bar:            ProgressBar
@export var player_container:         Control
@export var label_result:             RichTextLabel
@export var button_attack:            Button
@export var button_defend:            Button
@export var player_effects_container: HBoxContainer
@export var enemy_effects_container:  HBoxContainer
@export var label_weapon:             Label
@export var xp_bar:                   ProgressBar
@export var label_xp:                 Label
@export var label_saving:             Label
@onready var history_button       = $MarginContainer/VBoxContainer/HistoryButton

const LevelUpPopup          = preload("res://scenes/level_up_popup.tscn")
const DamageNumberScene     = preload("res://scenes/ui/damage_number.tscn")
const CombatResultPopupScene= preload("res://scenes/ui/combat_result_popup.tscn")
const GameOverPopupScene    = preload("res://scenes/ui/game_over_popup.tscn")
const CombatHistoryPopupScene = preload("res://scenes/ui/combat_history_popup.tscn")	

# ─────────────────────────────────────────
# CONFIG
# ─────────────────────────────────────────
const MAX_LOG_LINES := 40

# ─────────────────────────────────────────
# DATA
# ─────────────────────────────────────────
var player:            Player
var enemy:             Enemy
var combat_finished := false
var _input_locked   := false
var _popup_open     := false
var _active_tweens: Array = []
var combat_system   := CombatSystem.new()

# ─────────────────────────────────────────
# READY
# ─────────────────────────────────────────
func _ready() -> void:
	_validate_nodes()
	if GameManager.is_player_dead():
		SceneManager.go_to_main_menu()
		return

	_apply_theme()
	_setup_combat()

	GameManager.level_up.connect(_on_level_up)
	GameManager.player_data_changed.connect(_update_xp_ui)
	GameManager.game_saved.connect(show_save_feedback)
	history_button.pressed.connect(_on_history_button_pressed)

	# US-AUDIO-007 — música de combate
	AudioManager.play_music("combat")

# ─────────────────────────────────────────
# TEMA
# ─────────────────────────────────────────
func _apply_theme() -> void:
	ThemeManager.apply_scene_background(self)

	ThemeManager.apply_progress_bar(player_hp_bar, "player")
	ThemeManager.apply_progress_bar(enemy_hp_bar,  "enemy")
	ThemeManager.apply_progress_bar(xp_bar,        "xp")

	player_hp_bar.custom_minimum_size = Vector2(0, 18)
	enemy_hp_bar.custom_minimum_size  = Vector2(0, 18)
	xp_bar.custom_minimum_size        = Vector2(0, 10)

	ThemeManager.apply_label_title(label_enemy)
	label_enemy.add_theme_color_override("font_color", ThemeManager.C_RED_BRIGHT)
	ThemeManager.apply_label_body(label_enemy_hp)
	ThemeManager.apply_label_body(label_player_hp)
	ThemeManager.apply_label_dim(label_xp)
	ThemeManager.apply_label_dim(label_weapon)

	if label_saving:
		label_saving.add_theme_color_override("font_color",    ThemeManager.C_AMBER)
		label_saving.add_theme_font_size_override("font_size", ThemeManager.FONT_SMALL)

	ThemeManager.apply_button_primary(button_attack)
	button_attack.custom_minimum_size = Vector2(0, 72)

	ThemeManager.apply_button_secondary(button_defend)
	button_defend.custom_minimum_size = Vector2(0, 72)

	# Historial — botón con indicador de estado
	ThemeManager.apply_button_secondary(history_button)
	history_button.custom_minimum_size = Vector2(0, 44)

	label_result.add_theme_color_override("default_color",   ThemeManager.C_TEXT_DIM)
	label_result.add_theme_font_size_override("normal_font_size", ThemeManager.FONT_SMALL)

# ─────────────────────────────────────────
# VALIDACIÓN
# ─────────────────────────────────────────
func _validate_nodes() -> void:
	var nodes = [
		label_enemy, label_enemy_hp, enemy_hp_bar, enemy_container,
		label_player_hp, player_hp_bar, player_container,
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
	enemy  = _generate_enemy()

	player_hp_bar.min_value = 0
	player_hp_bar.max_value = player.max_hp
	player_hp_bar.value     = player.hp

	enemy_hp_bar.min_value = 0
	enemy_hp_bar.max_value = enemy.max_hp
	enemy_hp_bar.value     = enemy.hp

	label_enemy.text  = enemy.name
	label_result.text = ""

	add_combat_log("⚔️ Combate contra " + enemy.name)
	_update_ui()
	_update_weapon_ui()
	_update_xp_ui()
	await _enemy_intro_animation()

# ─────────────────────────────────────────
# UI UPDATE
# ─────────────────────────────────────────
func _update_ui() -> void:
	player.hp = max(player.hp, 0)
	enemy.hp  = max(enemy.hp,  0)
	GameManager.update_player_hp(player.hp)
	label_player_hp.text = "HP %d / %d" % [player.hp, player.max_hp]
	label_enemy_hp.text  = "HP %d / %d" % [enemy.hp, enemy.max_hp]
	player_hp_bar.value  = player.hp
	enemy_hp_bar.value   = enemy.hp
	_update_effects_ui()
	_update_xp_ui()

func _update_xp_ui() -> void:
	var data      = GameManager.get_player_data()
	xp_bar.max_value = data["xp_to_next"]
	xp_bar.value     = data["xp"]
	label_xp.text    = "XP %d / %d  Lv %d" % [data["xp"], data["xp_to_next"], data["level"]]

# ─────────────────────────────────────────
# INPUT LOCK
# ─────────────────────────────────────────
func _lock_input() -> void:
	_input_locked          = true
	button_attack.disabled = true
	button_defend.disabled = true

func _unlock_input() -> void:
	if combat_finished or _popup_open:
		return
	_input_locked          = false
	button_attack.disabled = false
	button_defend.disabled = false

# ─────────────────────────────────────────
# ATAQUE — US-AUDIO-001 / 002
# ─────────────────────────────────────────
func _on_button_attack_pressed() -> void:
	if combat_finished or _input_locked or GameManager.is_player_dead():
		return
	_lock_input()

	# Efectos de estado turno inicio
	var logs = combat_system.apply_effects(player)
	for l in logs:
		add_combat_log(l)
		# US-AUDIO-004 — reproducir SFX del efecto que se aplicó
		_play_effect_log_sfx(l)

	logs = combat_system.apply_effects(enemy)
	for l in logs:
		add_combat_log(l)
		_play_effect_log_sfx(l)

	_update_ui()
	await _combat_pause(0.15)

	var result = combat_system.player_attack(player, enemy)

	if result["skipped"]:
		add_combat_log("💫 Estás aturdido")
		await _combat_pause(0.35)
	else:
		add_combat_log("⚔️ " + str(result["damage"]) + " de daño")

	_show_damage_number(
		enemy_container,
		result["damage"],
		result["is_crit"]
	)

	await _combat_pause(0.08)
	await _flash(enemy_container, Color.RED)
	await _shake(enemy_container)
	await _combat_pause(0.12)

	if result["is_crit"]:
		AudioManager.play_sfx("crit")
		await _flash(enemy_container, Color.YELLOW)
		add_combat_log("💥 CRÍTICO " + str(result["damage"]))
	else:
		AudioManager.play_sfx("hit")

	_update_ui()

	if enemy.hp <= 0:
		await _end_combat("victory")
		return

	await get_tree().create_timer(0.6).timeout
	await _combat_pause(0.25)

	result = combat_system.enemy_attack(player, enemy)
	add_combat_log("💢 Recibís " + str(result["damage"]))

	match result.get("effect", ""):

		"bleed":
			add_combat_log("🩸 Te provoca sangrado")

		"poison":
			add_combat_log("☠️ Te envenena")

		"burn":
			add_combat_log("🔥 Te incendia")

		"stun":
			add_combat_log("💫 Te aturde")
	_show_damage_number(player_container, result["damage"], result["is_crit"])
	await _flash(player_container, Color.RED)
	await _shake(player_container)
	await _combat_pause(0.12)

	if result["is_crit"]:
		await _flash(player_container, Color.YELLOW)
		add_combat_log("⚠️ CRÍTICO enemigo " + str(result["damage"]))

	_update_ui()

	if player.hp <= 0:
		await _end_combat("defeat")
		return

	_unlock_input()

# ─────────────────────────────────────────
# DEFENSA — US-AUDIO-003
# ─────────────────────────────────────────
func _on_button_defend_pressed() -> void:
	if combat_finished or _input_locked or GameManager.is_player_dead():
		return

	_lock_input()

	player.start_defense()
	AudioManager.play_sfx("defend")

	_show_status_text(
		player_container,
		"🛡 DEFEND",
		ThemeManager.C_DEFENSE
	)

	await _flash(
		player_container,
		ThemeManager.C_DEFENSE
	)

	player_container.modulate = Color(0.7, 0.9, 1.0)

	await get_tree().create_timer(0.15).timeout

	player_container.modulate = Color.WHITE

	await _combat_pause(0.15)

	add_combat_log("🛡 Defendiendo")

	await get_tree().create_timer(0.5).timeout

	var result = combat_system.enemy_attack(player, enemy)

	if result["skipped"]:

		add_combat_log("💫 El enemigo está aturdido")

		await _combat_pause(0.35)

	else:

		add_combat_log(
			"💢 Recibís " + str(result["damage"])
		)

		_show_damage_number(
			player_container,
			result["damage"],
			result["is_crit"]
		)

		await _flash(player_container, Color.RED)

		await _shake(player_container)

		await _combat_pause(0.12)

		if result["is_crit"]:

			await _flash(player_container, Color.YELLOW)

			add_combat_log(
				"⚠️ CRÍTICO enemigo " + str(result["damage"])
			)

	_update_ui()

	if player.hp <= 0:
		await _end_combat("defeat")
		return

	_unlock_input()

# ─────────────────────────────────────────
# HELPER — SFX de efectos por texto de log — US-AUDIO-004
# ─────────────────────────────────────────
func _play_effect_log_sfx(log_text: String) -> void:
	# El CombatSystem devuelve logs con emojis/palabras clave
	# Detectamos qué efecto fue y reproducimos el SFX correspondiente
	if "🩸" in log_text or "bleed" in log_text.to_lower():
		AudioManager.play_sfx("bleed")
	elif "☠️" in log_text or "poison" in log_text.to_lower() or "veneno" in log_text.to_lower():
		AudioManager.play_sfx("poison")
	elif "🔥" in log_text or "burn" in log_text.to_lower() or "fuego" in log_text.to_lower():
		AudioManager.play_sfx("burn")
	elif "💫" in log_text or "stun" in log_text.to_lower() or "aturdi" in log_text.to_lower():
		AudioManager.play_sfx("stun")

# ─────────────────────────────────────────
# LOG
# ─────────────────────────────────────────
func add_combat_log(text: String) -> void:
	var lines: Array = []
	if not label_result.text.is_empty():
		lines = label_result.text.split("\n")
	lines.append(text)
	while lines.size() > MAX_LOG_LINES:
		lines.remove_at(0)
	label_result.text = "\n".join(lines)
	await get_tree().process_frame
	label_result.scroll_to_line(label_result.get_line_count())

func add_log(text: String) -> void:
	add_combat_log(text)

# ─────────────────────────────────────────
# FIN DE COMBATE — US-AUDIO-007 stop música
# ─────────────────────────────────────────
func _end_combat(result: String) -> void:
	if combat_finished:
		return
	combat_finished = true
	_lock_input()
	GameManager.set_combat_result(result)

	if result == "defeat":
		GameManager.kill_player()
		await _death_feedback()
		AudioManager.stop_music(0.3)     # ← fade out antes de game over
		_show_game_over()
		AudioManager.play_sfx("game_over")
		return

	var xp_gained := enemy.xp
	var loot      := {}
	GameManager.add_xp(xp_gained)

	if _roll_drop():
		loot = _generate_loot()
		if loot.size() > 0:
			GameManager.add_item_to_inventory(loot)
			# US-AUDIO-005 — distinción por rareza
			AudioManager.play_loot_sfx(loot.get("rarity", "common"))

	await _combat_pause(0.35)

	if _popup_open:
		return
	_popup_open = true
	_show_combat_result_popup(result, xp_gained, loot)
	GameManager._save_game()

# ─────────────────────────────────────────
# POPUP RESULTADO
# ─────────────────────────────────────────
func _show_combat_result_popup(result: String, xp: int, loot: Dictionary) -> void:
	var popup = CombatResultPopupScene.instantiate()
	add_child(popup)
	popup.top_level   = false
	popup.z_index     = 1000
	popup.mouse_filter = Control.MOUSE_FILTER_STOP
	popup.show_result(result, xp, loot)
	popup.continue_pressed.connect(_on_popup_continue)

func _on_popup_continue() -> void:
	_popup_open = false
	AudioManager.stop_music(0.4)   # ← fade out al salir
	SceneManager.go_to_result()

# ─────────────────────────────────────────
# GAME OVER
# ─────────────────────────────────────────
func _show_game_over() -> void:
	if _popup_open:
		return
	_popup_open = true
	var popup = GameOverPopupScene.instantiate()
	get_tree().current_scene.add_child(popup)
	popup.top_level = true
	popup.z_index   = 100

# ─────────────────────────────────────────
# LEVEL UP — US-AUDIO-006
# ─────────────────────────────────────────
func _on_level_up(new_level: int, hp_gain: int, damage_gain: int) -> void:
	add_combat_log("🎉 LEVEL UP! Nivel " + str(new_level))
	AudioManager.play_sfx("levelup")
	var popup = LevelUpPopup.instantiate()
	add_child(popup)
	popup.show_level_up(new_level, hp_gain, damage_gain)

# ─────────────────────────────────────────
# EFECTOS UI
# ─────────────────────────────────────────
func _update_effects_ui() -> void:
	_draw_effects(player.effects, player_effects_container)
	_draw_effects(enemy.effects,  enemy_effects_container)

func _draw_effects(effects: Array, container: HBoxContainer) -> void:
	for child in container.get_children():
		child.queue_free()
	for effect in effects:
		var label = Label.new()
		var icon  = _effect_icon(effect["type"])
		label.text = icon if effect["type"] == "stun" else icon + "x" + str(effect["duration"])
		label.add_theme_font_size_override("font_size",  ThemeManager.FONT_SMALL)
		label.add_theme_color_override("font_color",     _effect_color(effect["type"]))
		container.add_child(label)

func _effect_icon(type: String) -> String:
	match type:
		"bleed":  return "🩸"
		"poison": return "☠️"
		"burn":   return "🔥"
		"stun":   return "💫"
		_:        return "❓"

func _effect_color(type: String) -> Color:
	match type:
		"bleed":  return ThemeManager.C_BLEED
		"poison": return ThemeManager.C_POISON
		"burn":   return ThemeManager.C_BURN
		_:        return ThemeManager.C_TEXT_DIM

# ─────────────────────────────────────────
# ARMA UI
# ─────────────────────────────────────────
func _update_weapon_ui() -> void:
	var weapon = player.equipped_weapon
	if weapon == null or weapon.is_empty():
		label_weapon.text = "Sin arma equipada"
	else:
		var effect = weapon.get("effect", "")
		label_weapon.text = weapon.get("name", "???")
		if effect != "":
			label_weapon.text += " " + _effect_icon(effect)

# ─────────────────────────────────────────
# FX VISUALES
# ─────────────────────────────────────────
func _flash(node: Control, color: Color) -> void:
	if not is_instance_valid(node): return
	var original    = node.modulate
	node.modulate   = color
	await get_tree().create_timer(0.1).timeout
	if is_instance_valid(node):
		node.modulate = original

func _death_feedback() -> void:
	if death_overlay == null: return
	death_overlay.visible    = true
	death_overlay.modulate.a = 0.0
	death_overlay.color      = ThemeManager.C_RED
	var tween = create_tween()
	_active_tweens.append(tween)
	tween.tween_property(death_overlay, "modulate:a", 0.65, 0.5)
	await tween.finished

func _shake(node: Control) -> void:
	if not is_instance_valid(node):
		return

	var original_pos := node.position

	var tween := create_tween()
	_active_tweens.append(tween)

	for i in range(4):
		tween.tween_property(
			node,
			"position",
			original_pos + Vector2(
				randi_range(-6, 6),
				randi_range(-6, 6)
			),
			0.03
		)

	tween.tween_property(
		node,
		"position",
		original_pos,
		0.04
	)

	await tween.finished

func _combat_pause(duration: float) -> void:
	await get_tree().create_timer(duration).timeout

func _enemy_intro_animation() -> void:
	if enemy_container == null: return
	var original_position      := enemy_container.position
	enemy_container.modulate.a  = 0.0
	enemy_container.scale       = Vector2(0.85, 0.85)
	enemy_container.position    = original_position + Vector2(0, -40)
	var tween = create_tween()
	_active_tweens.append(tween)
	tween.set_parallel(true)
	tween.tween_property(enemy_container, "modulate:a",  1.0,          0.35)
	tween.tween_property(enemy_container, "scale",       Vector2.ONE,  0.35)
	tween.tween_property(enemy_container, "position",    original_position, 0.35)
	await tween.finished

func _exit_tree() -> void:
	for t in _active_tweens:
		if t and t.is_valid(): t.kill()
	_active_tweens.clear()

# ─────────────────────────────────────────
# DAMAGE NUMBERS
# ─────────────────────────────────────────
func _show_damage_number(target_node: Control, damage: int, is_crit: bool) -> void:
	var label         := Label.new()
	label.text         = "💥 " + str(damage) if is_crit else str(damage)
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size",  32 if is_crit else 24)
	label.add_theme_color_override("font_color",
		ThemeManager.C_CRIT if is_crit else ThemeManager.C_TEXT_BRIGHT)
	target_node.add_child(label)

	await get_tree().process_frame
	await get_tree().process_frame

	var scale_factor  := 1.2 if is_crit else 1.0
	var visual_width  := label.size.x * scale_factor
	var visual_height := label.size.y * scale_factor
	label.scale        = Vector2(scale_factor, scale_factor)
	label.position     = Vector2(
		(target_node.size.x - visual_width)  / 2.0,
		(target_node.size.y - visual_height) / 2.0
	)

	var tween = create_tween()
	_active_tweens.append(tween)
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 80, 1.2)
	tween.tween_property(label, "modulate:a", 0.0,                   1.2)
	tween.tween_property(label, "scale",      Vector2(scale_factor + 0.3, scale_factor + 0.3), 1.2)
	await tween.finished
	if is_instance_valid(label): label.queue_free()

func _show_status_text(target_node: Control, text: String, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.modulate = color
	label.add_theme_font_size_override("font_size", ThemeManager.FONT_BODY)
	target_node.add_child(label)
	await get_tree().process_frame
	label.position = Vector2(
		(target_node.size.x - label.size.x) / 2.0,
		target_node.size.y * 0.25
	)
	var tween = create_tween()
	_active_tweens.append(tween)
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 40, 0.8)
	tween.tween_property(label, "modulate:a", 0.0,                   0.8)
	await tween.finished
	if is_instance_valid(label): label.queue_free()

# ─────────────────────────────────────────
# SAVE FEEDBACK
# ─────────────────────────────────────────
func show_save_feedback() -> void:
	if label_saving == null: return
	label_saving.visible    = true
	label_saving.modulate.a = 0.0
	var tween = create_tween()
	_active_tweens.append(tween)
	tween.tween_property(label_saving, "modulate:a", 1.0, 0.2)
	tween.tween_interval(0.8)
	tween.tween_property(label_saving, "modulate:a", 0.0, 0.4)
	await tween.finished
	if is_instance_valid(label_saving): label_saving.visible = false

# ─────────────────────────────────────────
# HISTORIAL — US-UI-013 con estado visual del botón
# ─────────────────────────────────────────
func _on_history_button_pressed() -> void:
	AudioManager.play_sfx("click")
	var popup = CombatHistoryPopupScene.instantiate()
	add_child(popup)
	popup.top_level = true
	popup.z_index   = 500
	popup.set_log(label_result.text)

# ─────────────────────────────────────────
# GENERACIÓN
# ─────────────────────────────────────────
func _generate_enemy() -> Enemy:
	var zone       = GameManager.get_selected_zone()
	var enemies_ids = zone.get("enemies", [])
	if enemies_ids.is_empty():
		push_error("Zona sin enemigos")
		return Enemy.new()

	var random_id = enemies_ids.pick_random()
	var file      = FileAccess.open("res://data/enemies.json", FileAccess.READ)
	if file == null:
		push_error("No se pudo abrir enemies.json")
		return Enemy.new()

	var data = JSON.parse_string(file.get_as_text())
	for e in data:
		if e.get("id", "") == random_id:
			var new_enemy = Enemy.from_dict(e)
			if new_enemy == null: return Enemy.new()
			_apply_enemy_scaling(new_enemy)
			return new_enemy

	push_error("Enemy ID no encontrado: " + str(random_id))
	return Enemy.new()

func _apply_enemy_scaling(target_enemy: Enemy) -> void:
	var zone        = GameManager.get_selected_zone()
	var level_range = zone.get("level_range", [1, 1])
	var final_level = randi_range(level_range[0], level_range[1])
	target_enemy.max_hp  += final_level * Constants.ENEMY_HP_PER_LEVEL
	target_enemy.hp       = target_enemy.max_hp
	target_enemy.damage  += final_level * Constants.ENEMY_DAMAGE_PER_LEVEL
	target_enemy.xp      += final_level * Constants.XP_PER_ENEMY_LEVEL

func _generate_loot() -> Dictionary:
	var file = FileAccess.open("res://data/items.json", FileAccess.READ)
	if file == null: return {}
	var data = JSON.parse_string(file.get_as_text())
	if data == null or data.is_empty(): return {}

	var rarity          = _roll_rarity()
	var filtered_items: Array = []
	for item in data:
		if item.get("rarity", "common") == rarity:
			filtered_items.append(item)
	if filtered_items.is_empty(): filtered_items = data
	return filtered_items.pick_random()

func _roll_rarity() -> String:
	var total_weight := 0
	for w in Constants.RARITY_WEIGHTS.values(): total_weight += w
	var roll       = randi_range(1, total_weight)
	var cumulative = 0
	for rarity in Constants.RARITY_WEIGHTS.keys():
		cumulative += Constants.RARITY_WEIGHTS[rarity]
		if roll <= cumulative: return rarity
	return "common"

func _roll_drop() -> bool:
	return randi_range(1, 100) <= Constants.LOOT_DROP_CHANCE

func _show_loot_popup(item: Dictionary) -> void:
	var scene  = load("res://scenes/ui/loot_popup.tscn")
	var popup  = scene.instantiate()
	get_tree().current_scene.add_child(popup)
	popup.z_index = 10
	if popup.has_method("show_loot"):
		popup.show_loot(item)