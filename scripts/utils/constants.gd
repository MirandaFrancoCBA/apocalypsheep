# scripts/utils/constants.gd
extends Node
# ─────────────────────────────────────────
# SCENES — rutas a cada escena del juego
# ─────────────────────────────────────────
const SCENE_MAIN_MENU   = "res://scenes/main_menu.tscn"
const SCENE_ZONE_SELECT = "res://scenes/zone_select.tscn"
const SCENE_COMBAT      = "res://scenes/combat_screen.tscn"
const SCENE_RESULT      = "res://scenes/result.tscn"
const SCENE_INVENTORY   = "res://scenes/inventory.tscn"

# ─────────────────────────────────────────
# GAME CONFIG
# ─────────────────────────────────────────
const SAVE_PATH = "user://savegame.json"

# ─────────────────────────────────────────
# PLAYER DEFAULTS (stats iniciales)
# ─────────────────────────────────────────
const PLAYER_DEFAULT_HP      = 100
const PLAYER_DEFAULT_DAMAGE  = 10
const PLAYER_DEFAULT_LEVEL   = 1
const PLAYER_DEFAULT_XP      = 0

# ─────────────────────────────────────────
# LOOT — rarezas
# ─────────────────────────────────────────
const RARITY_WEIGHTS = {
	"common": 70,
	"rare": 25,
	"epic": 5
}