extends Node

class_name CombatSystem

var rng = RandomNumberGenerator.new()

func _init():
	rng.randomize()

func player_attack(player: Player, enemy: Enemy) -> int:
	var variation = int(player.damage * 0.2)
	var damage = player.damage + rng.randi_range(-variation, variation)
	damage = max(damage, 1)

	enemy.hp -= damage
	print("Jugador pega:", damage)

	return damage

func enemy_attack(player: Player, enemy: Enemy) -> int:
	var variation = int(enemy.damage * 0.2)
	var damage = enemy.damage + rng.randi_range(-variation, variation)
	damage = max(damage, 1)

	player.hp -= damage
	print("Enemigo pega:", damage)

	return damage