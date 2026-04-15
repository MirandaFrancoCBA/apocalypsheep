# scripts/core/player.gd
extends Resource

class_name Player

var hp: int
var damage: int

static func from_game_manager() -> Player:
    var data = GameManager.get_player_data()
    
    var p = Player.new()
    p.hp = data["hp"]
    p.damage = data["damage"]
    
    return p