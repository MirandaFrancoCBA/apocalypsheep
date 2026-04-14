extends Node

func _ready():
    print(GameManager.get_player_data())
    print(Constants.SCENE_MAIN_MENU)
    print("[OK] Managers cargados correctamente")