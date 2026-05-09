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
const RARITY_COLORS := {
	"common": Color.WHITE,
	"rare": Color(0.4, 0.6, 1.0),
	"epic": Color(0.7, 0.4, 1.0)
}
const RARITY_ICONS := {
	"common": "⚪",
	"rare": "🔵",
	"epic": "🟣"
}
# ─────────────────────────────────────────
# LOOT — drop chance
# ─────────────────────────────────────────
const LOOT_DROP_CHANCE = 60 # %
const INVENTORY_MAX_SIZE = 10