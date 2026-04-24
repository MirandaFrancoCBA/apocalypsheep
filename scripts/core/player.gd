# scripts/core/player.gd
extends Resource
class_name Player

var hp: int
var max_hp: int
var damage: int

var level: int
var xp: int

# 🔥 IMPORTANTE → valor por defecto
var equipped_weapon: Dictionary = {}

# 🆕 EFECTOS
var effects: Array[Dictionary] = []

static func from_game_manager() -> Player:
	var data = GameManager.get_player_data()

	var p = Player.new()

	p.hp      = data.get("hp", 1)
	p.max_hp  = data.get("max_hp", p.hp)
	p.damage  = data.get("damage", 1)

	p.level   = data.get("level", 1)
	p.xp      = data.get("xp", 0)

	# 🔥 FIX REAL
	var weapon = data.get("equipped_weapon", {})

	if weapon != null and not weapon.is_empty():
		p.equipped_weapon = weapon
		p.damage += weapon.get("damage", 0)
	else:
		p.equipped_weapon = {}

	return p

func take_damage(amount: int) -> void:
	hp -= amount
	hp = max(hp, 0)

func heal(amount: int) -> void:
	hp += amount
	hp = min(hp, max_hp)

func is_alive() -> bool:
	return hp > 0

# 🆕 DEFENSA
var is_defending: bool = false
var defense_multiplier: float = 0.5  # 50% daño

func start_defense():
	is_defending = true

func stop_defense():
	is_defending = false
