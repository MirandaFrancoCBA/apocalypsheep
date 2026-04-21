# scripts/core/enemy.gd
extends Resource
class_name Enemy

var id: String
var name: String
var hp: int
var max_hp: int
var damage: int

# 🆕 EFECTOS
var effects: Array[Dictionary] = []

static func from_dict(data: Dictionary) -> Enemy:
	var e = Enemy.new()
	e.id = data.get("id", "")
	e.name = data.get("name", "Enemy")
	e.hp = data.get("hp", 10)
	e.max_hp = e.hp
	e.damage = data.get("damage", 1)
	return e

func take_damage(amount: int) -> void:
	hp -= amount
	hp = max(hp, 0)