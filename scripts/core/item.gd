# scripts/core/item.gd
extends Resource

class_name Item

var id: String
var name: String
var type: String
var rarity: String

var damage: int = 0
var heal: int = 0


static func from_dict(data: Dictionary) -> Item:
    var i = Item.new()
    
    i.id = data.get("id", "")
    i.name = data.get("name", "Item")
    i.type = data.get("type", "misc")
    i.rarity = data.get("rarity", "common")
    
    i.damage = data.get("damage", 0)
    i.heal = data.get("heal", 0)
    
    return i