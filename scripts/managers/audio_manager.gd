# scripts/managers/audio_manager.gd
# ─────────────────────────────────────────
# AUDIO MANAGER — Godot 4 / GDScript
# US-AUDIO-011 — manager centralizado con lazy cache
#
# ⚠️  POR QUÉ NO SUENA LA MÚSICA — FIX INCLUIDO:
#
#   En Godot 4, AudioStreamOggVorbis NO tiene una propiedad .loop
#   que se pueda setear en runtime desde GDScript.
#   El loop hay que activarlo ANTES de importar, en el panel
#   de Import del editor:
#
#     1. Seleccioná el archivo .ogg en el FileSystem
#     2. Panel Import → tildá "Loop"
#     3. Click "Reimport"
#
#   Si querés evitar todo eso, convertí la música a .wav con loop
#   seteado directamente — funciona sin configuración extra.
#
#   Este archivo incluye un fallback manual: si el OGG no tiene
#   loop configurado, _on_music_finished() lo reinicia solo.
#
# Rutas esperadas:
#   res://audio/sfx/hit.wav
#   res://audio/sfx/crit.wav
#   res://audio/sfx/defend.wav
#   res://audio/sfx/loot.wav
#   res://audio/sfx/loot_epic.wav
#   res://audio/sfx/levelup.wav
#   res://audio/sfx/game_over.wav
#   res://audio/sfx/heal.wav
#   res://audio/sfx/click.wav
#   res://audio/sfx/confirm.wav
#   res://audio/sfx/bleed.wav
#   res://audio/sfx/poison.wav
#   res://audio/sfx/burn.wav
#   res://audio/sfx/stun.wav
#   res://audio/music/combat.ogg   ← loop activado en Import
#   res://audio/music/menu.ogg     ← loop activado en Import
# ─────────────────────────────────────────
extends Node

# ─────────────────────────────────────────
# ESTADO INTERNO
# ─────────────────────────────────────────
var _cache: Dictionary = {}
var _music_player: AudioStreamPlayer = null
var _current_music: String = ""

# ─────────────────────────────────────────
# VOLUMEN — US-AUDIO-010
# ─────────────────────────────────────────
var master_volume: float = 1.0
var music_volume:  float = 0.7
var sfx_volume:    float = 1.0
var muted:         bool  = false

# ─────────────────────────────────────────
# PATHS
# ─────────────────────────────────────────
const SFX_PATHS: Dictionary = {
	"hit":       "res://audio/sfx/hit.wav",
	"crit":      "res://audio/sfx/crit.wav",
	"defend":    "res://audio/sfx/defend.wav",
	"bleed":     "res://audio/sfx/bleed.wav",
	"poison":    "res://audio/sfx/poison.wav",
	"burn":      "res://audio/sfx/burn.wav",
	"stun":      "res://audio/sfx/stun.wav",
	"loot":      "res://audio/sfx/loot.wav",
	"loot_epic": "res://audio/sfx/loot_epic.wav",
	"levelup":   "res://audio/sfx/levelup.wav",
	"heal":      "res://audio/sfx/heal.wav",
	"game_over": "res://audio/sfx/game_over.wav",
	"click":     "res://audio/sfx/click.wav",
	"confirm":   "res://audio/sfx/confirm.wav",
}

const MUSIC_PATHS: Dictionary = {
	"combat": "res://audio/music/combat.ogg",
	"menu":   "res://audio/music/menu.ogg",
}

# ─────────────────────────────────────────
# API — SFX
# ─────────────────────────────────────────
func play_sfx(sfx_name: String) -> void:
	if muted:
		return
	var stream = _load_resource(sfx_name, SFX_PATHS)
	if stream == null:
		return
	var player := AudioStreamPlayer.new()
	add_child(player)
	player.stream    = stream
	player.volume_db = linear_to_db(master_volume * sfx_volume)
	player.play()
	player.finished.connect(player.queue_free)

## Loot con distinción por rareza — US-AUDIO-005
func play_loot_sfx(rarity: String) -> void:
	if rarity.to_lower() == "epic":
		play_sfx("loot_epic")
	else:
		play_sfx("loot")

## SFX de efecto de estado — US-AUDIO-004
func play_effect_sfx(effect_type: String) -> void:
	match effect_type.to_lower():
		"bleed":  play_sfx("bleed")
		"poison": play_sfx("poison")
		"burn":   play_sfx("burn")
		"stun":   play_sfx("stun")

# ─────────────────────────────────────────
# API — MÚSICA — US-AUDIO-007 / 008
# ─────────────────────────────────────────

## Reproduce música. Si ya está sonando la misma pista, no hace nada.
## IMPORTANTE: el loop se configura en el panel Import del editor Godot,
## NO en runtime. Ver cabecera del archivo.
func play_music(track_name: String) -> void:
	if _current_music == track_name:
		if _music_player != null and _music_player.playing:
			return

	_stop_music_immediate()

	var stream = _load_resource(track_name, MUSIC_PATHS)
	if stream == null:
		push_warning("[AudioManager] No se encontró la pista: " + track_name
			+ "\nVerificá que el archivo exista en res://audio/music/")
		return

	_music_player = AudioStreamPlayer.new()
	add_child(_music_player)
	_music_player.stream    = stream
	_music_player.volume_db = linear_to_db(master_volume * music_volume)

	# NO seteamos stream.loop acá — es readonly en Godot 4.
	# Activarlo desde el editor: FileSystem → Import → Loop → Reimport

	_music_player.play()
	_current_music = track_name

	# Fallback manual por si el OGG no tiene loop en el Import
	_music_player.finished.connect(_on_music_finished)

func _on_music_finished() -> void:
	# Si el OGG no tiene loop activado en Import, lo repetimos acá
	if _music_player != null and not _current_music.is_empty():
		_music_player.play()

## Fade out suave + detiene la música.
func stop_music(fade_time: float = 0.5) -> void:
	if _music_player == null or not _music_player.playing:
		_stop_music_immediate()
		return
	var player_ref = _music_player
	var tween = create_tween()
	tween.tween_property(player_ref, "volume_db", -80.0, fade_time)
	await tween.finished
	if is_instance_valid(player_ref):
		player_ref.stop()
		player_ref.queue_free()
	if _music_player == player_ref:
		_music_player  = null
		_current_music = ""

func _stop_music_immediate() -> void:
	if _music_player != null:
		_music_player.stop()
		_music_player.queue_free()
		_music_player  = null
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
		_music_player.volume_db = -80.0 if muted else linear_to_db(master_volume * music_volume)

## Alias legacy
func set_volume(value: float) -> void:
	set_master_volume(value)

func _apply_music_volume() -> void:
	if _music_player != null and not muted:
		_music_player.volume_db = linear_to_db(master_volume * music_volume)

# ─────────────────────────────────────────
# CARGA LAZY CON CACHE — US-AUDIO-011
# ─────────────────────────────────────────
func _load_resource(sfx_key: String, paths: Dictionary) -> AudioStream:
	var cache_key: String = "%s_%d" % [sfx_key, paths.hash()]

	if _cache.has(cache_key):
		return _cache[cache_key]

	if not paths.has(sfx_key):
		push_warning("[AudioManager] Nombre desconocido: '%s'" % sfx_key)
		return null

	var path: String = paths[sfx_key]

	if not ResourceLoader.exists(path):
		return null  # Silencioso — normal si el archivo no existe todavía

	var stream = load(path) as AudioStream
	if stream == null:
		push_warning("[AudioManager] Falló la carga: %s" % path)
		return null

	_cache[cache_key] = stream
	return stream