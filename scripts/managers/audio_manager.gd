# scripts/managers/audio_manager.gd
# ─────────────────────────────────────────
# AUDIO MANAGER
# Carga lazy — no crashea si faltan archivos.
#
# Rutas esperadas (crear carpeta res://audio/sfx/ y res://audio/music/):
#
# SFX:
#   res://audio/sfx/hit.wav
#   res://audio/sfx/crit.wav
#   res://audio/sfx/defend.wav       ← US-AUDIO-003
#   res://audio/sfx/loot.wav
#   res://audio/sfx/loot_epic.wav    ← US-AUDIO-005 rareza alta
#   res://audio/sfx/levelup.wav
#   res://audio/sfx/game_over.wav
#   res://audio/sfx/heal.wav
#   res://audio/sfx/click.wav        ← US-AUDIO-009 feedback UI
#   res://audio/sfx/confirm.wav      ← US-AUDIO-009 confirmaciones
#   res://audio/sfx/bleed.wav        ← US-AUDIO-004 efectos
#   res://audio/sfx/poison.wav       ← US-AUDIO-004 efectos
#   res://audio/sfx/burn.wav         ← US-AUDIO-004 efectos
#   res://audio/sfx/stun.wav         ← US-AUDIO-004 efectos
#
# MÚSICA:
#   res://audio/music/combat.ogg     ← US-AUDIO-007
#   res://audio/music/menu.ogg       ← US-AUDIO-008
# ─────────────────────────────────────────
extends Node

# Cache de streams ya cargados
var _cache: Dictionary = {}

# Jugador de música actual
var _music_player: AudioStreamPlayer = null
var _current_music: String = ""

# ─────────────────────────────────────────
# VOLUMEN — US-AUDIO-010
# ─────────────────────────────────────────
var master_volume: float  = 1.0
var music_volume: float   = 0.7
var sfx_volume: float     = 1.0
var muted: bool           = false

# ─────────────────────────────────────────
# RUTAS SFX
# ─────────────────────────────────────────
const SFX_PATHS := {
	# Combate
	"hit":        "res://audio/sfx/hit.wav",
	"crit":       "res://audio/sfx/crit.wav",
	"defend":     "res://audio/sfx/defend.wav",
	# Efectos de estado
	"bleed":      "res://audio/sfx/bleed.wav",
	"poison":     "res://audio/sfx/poison.wav",
	"burn":       "res://audio/sfx/burn.wav",
	"stun":       "res://audio/sfx/stun.wav",
	# Progresión
	"loot":       "res://audio/sfx/loot.wav",
	"loot_epic":  "res://audio/sfx/loot_epic.wav",
	"levelup":    "res://audio/sfx/levelup.wav",
	"heal":       "res://audio/sfx/heal.wav",
	"game_over":  "res://audio/sfx/game_over.wav",
	# UI — US-AUDIO-009
	"click":      "res://audio/sfx/click.wav",
	"confirm":    "res://audio/sfx/confirm.wav",
}

const MUSIC_PATHS := {
	"combat": "res://audio/music/combat.ogg",
	"menu":   "res://audio/music/menu.ogg",
}

# ─────────────────────────────────────────
# API PÚBLICA — SFX
# ─────────────────────────────────────────

## Reproduce un SFX por nombre. Falla silenciosamente si el archivo no existe.
func play_sfx(sfx_name: String) -> void:
	if muted:
		return
	var stream = _get_stream(sfx_name, SFX_PATHS)
	if stream == null:
		return

	var player = AudioStreamPlayer.new()
	add_child(player)
	player.stream    = stream
	player.volume_db = linear_to_db(master_volume * sfx_volume)
	player.play()
	player.finished.connect(func(): player.queue_free())

## Versión conveniente: reproduce loot con distinción de rareza.
## US-AUDIO-005
func play_loot_sfx(rarity: String) -> void:
	if rarity == "epic":
		play_sfx("loot_epic")
	else:
		play_sfx("loot")

## Reproduce SFX de efecto de estado.
## US-AUDIO-004
func play_effect_sfx(effect_type: String) -> void:
	match effect_type:
		"bleed":  play_sfx("bleed")
		"poison": play_sfx("poison")
		"burn":   play_sfx("burn")
		"stun":   play_sfx("stun")

# ─────────────────────────────────────────
# API PÚBLICA — MÚSICA — US-AUDIO-007 / 008
# ─────────────────────────────────────────

## Reproduce música en loop. Si ya está sonando la misma, no hace nada.
func play_music(track_name: String) -> void:
	if _current_music == track_name and _music_player != null and _music_player.playing:
		return
	_stop_music_immediate()

	var stream = _get_stream(track_name, MUSIC_PATHS)
	if stream == null:
		return

	_music_player = AudioStreamPlayer.new()
	add_child(_music_player)
	_music_player.stream    = stream
	_music_player.volume_db = linear_to_db(master_volume * music_volume)

	# Loop nativo de Godot 4
	if stream is AudioStreamOggVorbis:
		stream.loop = true
	elif stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD

	_music_player.play()
	_current_music = track_name

## Fade out suave de la música actual.
func stop_music(fade_time: float = 0.5) -> void:
	if _music_player == null or not _music_player.playing:
		return
	var tween = create_tween()
	tween.tween_property(_music_player, "volume_db", -80.0, fade_time)
	await tween.finished
	_stop_music_immediate()

func _stop_music_immediate() -> void:
	if _music_player != null:
		_music_player.stop()
		_music_player.queue_free()
		_music_player = null
	_current_music = ""

# ─────────────────────────────────────────
# VOLUMEN — US-AUDIO-010
# ─────────────────────────────────────────

func set_master_volume(value: float) -> void:
	master_volume = clamp(value, 0.0, 1.0)
	_apply_music_volume()

func set_music_volume(value: float) -> void:
	music_volume = clamp(value, 0.0, 1.0)
	_apply_music_volume()

func set_sfx_volume(value: float) -> void:
	sfx_volume = clamp(value, 0.0, 1.0)

func set_muted(value: bool) -> void:
	muted = value
	if _music_player != null:
		_music_player.volume_db = linear_to_db(0.0001) if muted else linear_to_db(master_volume * music_volume)

# Alias legacy para compatibilidad con código anterior
func set_volume(value: float) -> void:
	set_master_volume(value)

func _apply_music_volume() -> void:
	if _music_player != null:
		_music_player.volume_db = linear_to_db(master_volume * music_volume)

# ─────────────────────────────────────────
# CARGA LAZY CON CACHE — US-AUDIO-011
# ─────────────────────────────────────────
func _get_stream(name: String, paths: Dictionary) -> AudioStream:
	var cache_key = name + "_" + str(paths.hash())

	if _cache.has(cache_key):
		return _cache[cache_key]

	if not paths.has(name):
		push_warning("[AudioManager] Audio desconocido: " + name)
		return null

	var path = paths[name]
	if not ResourceLoader.exists(path):
		# Normal si aún no tenés los archivos — no es error crítico
		return null

	var stream = load(path)
	if stream == null:
		push_warning("[AudioManager] No se pudo cargar: " + path)
		return null

	_cache[cache_key] = stream
	return stream