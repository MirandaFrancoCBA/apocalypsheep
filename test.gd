extends Node

func _ready():
    GameManager.set_selected_zone({
        "name": "Test",
        "enemies": ["raider"]
    })

    var combat = CombatSystem.new()
    combat.start_combat()