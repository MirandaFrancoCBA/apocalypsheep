# scripts/core/enemy.gd
extends Resource
class_name Enemy

var id: String
var name: String
var hp: int
var max_hp: int
var damage: int
var xp: int = 10


# 🆕 EFECTOS
var effects: Array[Dictionary] = []
var is_defending: bool = false
static func from_dict(data: Dictionary) -> Enemy:
	var new_enemy = Enemy.new()

	new_enemy.id = data.get("id", "")
	new_enemy.name = data.get("name", "Enemigo")

	new_enemy.hp = data.get("hp", 10)
	new_enemy.max_hp = data.get("max_hp", new_enemy.hp)
	new_enemy.damage = data.get("damage", 2)
	new_enemy.xp = data.get("xp", 10)


	return new_enemy

func take_damage(amount: int) -> void:
	hp -= amount
	hp = max(hp, 0)
