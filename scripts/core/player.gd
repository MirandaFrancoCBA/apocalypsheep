# scripts/core/player.gd
extends Resource
class_name Player

var hp: int
var max_hp: int
var damage: int

var level: int
var xp: int

var equipped_weapon: Dictionary

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

	p.equipped_weapon = data.get("equipped_weapon")

	if p.equipped_weapon != null:
		p.damage += p.equipped_weapon.get("damage", 0)

	return p

func take_damage(amount: int) -> void:
	hp -= amount
	hp = max(hp, 0)

func heal(amount: int) -> void:
	hp += amount
	hp = min(hp, max_hp)

func is_alive() -> bool:
	return hp > 0