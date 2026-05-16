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
# SAVE
# ─────────────────────────────────────────
const SAVE_PATH = "user://savegame.json"

# ─────────────────────────────────────────
# PLAYER DEFAULTS
# ─────────────────────────────────────────
const PLAYER_DEFAULT_HP      := 100
const PLAYER_DEFAULT_DAMAGE  := 10
const PLAYER_DEFAULT_LEVEL   := 1
const PLAYER_DEFAULT_XP      := 0

# ─────────────────────────────────────────
# LEVELING / XP
# ─────────────────────────────────────────
const XP_BASE      := 50.0
const XP_EXPONENT  := 1.5
const MAX_LEVEL    := 99

# XP base por nivel enemigo
const XP_PER_ENEMY_LEVEL := 20

# ─────────────────────────────────────────
# COMBAT
# ─────────────────────────────────────────
const CRIT_CHANCE := 0.15
const CRIT_MULTIPLIER := 1.75

const DAMAGE_VARIATION_MIN := 0.9
const DAMAGE_VARIATION_MAX := 1.1

# ─────────────────────────────────────────
# DEFENSE
# ─────────────────────────────────────────
const DEFENSE_MULTIPLIER := 0.5

# ─────────────────────────────────────────
# ENEMY SCALING
# ─────────────────────────────────────────
const ENEMY_HP_PER_LEVEL := 5
const ENEMY_DAMAGE_PER_LEVEL := 2

# ─────────────────────────────────────────
# STATUS EFFECTS
# ─────────────────────────────────────────
const BLEED_DAMAGE := 3
const POISON_DAMAGE := 4
const BURN_DAMAGE := 5

const STUN_CHANCE := 0.15

# ─────────────────────────────────────────
# LOOT — rarezas
# ─────────────────────────────────────────
const RARITY_WEIGHTS := {
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
# LOOT
# ─────────────────────────────────────────
const LOOT_DROP_CHANCE := 60
const INVENTORY_MAX_SIZE := 10