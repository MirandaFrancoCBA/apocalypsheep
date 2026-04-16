# scripts/core/player.gd
extends Resource

class_name Player

var hp: int
var damage: int

static func from_game_manager() -> Player:
	var data = GameManager.get_player_data()
	
	var p = Player.new()
	p.hp = data["hp"]

	var base_damage = data["damage"]
	var weapon = GameManager.get_equipped_weapon()

	if weapon != null:
		base_damage += weapon.get("damage", 0)

	p.damage = base_damage
	
	return p