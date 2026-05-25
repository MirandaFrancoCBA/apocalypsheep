# scripts/managers/audio_manager.gd
# ─────────────────────────────────────────
# AUDIO MANAGER — versión final
# US-AUDIO-011 — manager centralizado
# US-AUDIO-012 — prioridad y limpieza de sonidos
#
# NOVEDADES vs versión anterior:
#   - Límite de instancias SFX simultáneas (anti-saturación)
#   - Cooldown por SFX (evita que el mismo sonido se pise a sí mismo)
#   - Efectos de estado con volumen reducido (no tapan el combate)
# ─────────────────────────────────────────
extends Node

var _cache: Dictionary           = {}
var _music_player: AudioStreamPlayer = null
var _current_music: String       = ""

# US-AUDIO-012 — control de instancias activas
var _active_sfx:       Array     = []   # lista de AudioStreamPlayer activos
const MAX_SFX_SIMULTANEOUS := 6         # máximo global de SFX a la vez

# Cooldown por sfx_key — evita que el mismo sonido suene
# dos veces en < N segundos (diccionario: key → tiempo_epoch)
var _sfx_last_played: Dictionary = {}
const SFX_COOLDOWNS: Dictionary  = {
	# Efectos de estado: se aplican por turno, pueden sonar muy seguido
	"bleed":  0.3,
	"poison": 0.3,
	"burn":   0.3,
	"stun":   0.3,
	# Hit/crit pueden sonar dos veces muy rápido en combos
	"hit":    0.05,
	"crit":   0.05,
	# UI: sin cooldown efectivo
	"click":  0.08,
}

# Volúmenes relativos por categoría — US-AUDIO-012
# Los efectos de estado suenan más suave para no tapar el combate
const SFX_VOLUME_MULTIPLIERS: Dictionary = {
	"bleed":  0.55,
	"poison": 0.55,
	"burn":   0.60,
	"stun":   0.65,
	"click":  0.70,
	"confirm":0.75,
}

# ─────────────────────────────────────────
# VOLUMEN
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
	"combat": "res://audio/music/combate.ogg",
	"menu":   "res://audio/music/menu.ogg",
}

# ─────────────────────────────────────────
# API — SFX
# ─────────────────────────────────────────
func play_sfx(sfx_key: String) -> void:
	if muted:
		return

	# US-AUDIO-012 — cooldown: evitar solapamiento del mismo SFX
	if _sfx_last_played.has(sfx_key):
		var cooldown = SFX_COOLDOWNS.get(sfx_key, 0.0)
		if Time.get_ticks_msec() - _sfx_last_played[sfx_key] < cooldown * 1000:
			return

	# US-AUDIO-012 — límite global de SFX simultáneos
	_clean_finished_sfx()
	if _active_sfx.size() >= MAX_SFX_SIMULTANEOUS:
		# Eliminar el más viejo para hacer lugar
		var oldest = _active_sfx.pop_front()
		if is_instance_valid(oldest):
			oldest.stop()
			oldest.queue_free()

	var stream = _load_resource(sfx_key, SFX_PATHS)
	if stream == null:
		return

	var vol_mult = SFX_VOLUME_MULTIPLIERS.get(sfx_key, 1.0)
	var player   = AudioStreamPlayer.new()
	add_child(player)
	player.stream    = stream
	player.volume_db = linear_to_db(master_volume * sfx_volume * vol_mult)
	player.play()
	player.finished.connect(func():
		_active_sfx.erase(player)
		player.queue_free()
	)
	_active_sfx.append(player)
	_sfx_last_played[sfx_key] = Time.get_ticks_msec()

func _clean_finished_sfx() -> void:
	_active_sfx = _active_sfx.filter(func(p): return is_instance_valid(p) and p.playing)

func play_loot_sfx(rarity: String) -> void:
	play_sfx("loot_epic" if rarity.to_lower() == "epic" else "loot")

func play_effect_sfx(effect_type: String) -> void:
	match effect_type.to_lower():
		"bleed":  play_sfx("bleed")
		"poison": play_sfx("poison")
		"burn":   play_sfx("burn")
		"stun":   play_sfx("stun")

# ─────────────────────────────────────────
# API — MÚSICA
# ─────────────────────────────────────────
func play_music(track_name: String) -> void:
	if _current_music == track_name:
		if _music_player != null and _music_player.playing:
			return
	_stop_music_immediate()
	var stream = _load_resource(track_name, MUSIC_PATHS)
	if stream == null:
		push_warning("[AudioManager] Pista no encontrada: " + track_name)
		return
	_music_player          = AudioStreamPlayer.new()
	add_child(_music_player)
	_music_player.stream    = stream
	_music_player.volume_db = linear_to_db(master_volume * music_volume)
	_music_player.play()
	_current_music          = track_name
	_music_player.finished.connect(_on_music_finished)

func _on_music_finished() -> void:
	if _music_player != null and not _current_music.is_empty():
		_music_player.play()

func stop_music(fade_time: float = 0.5) -> void:
	if _music_player == null or not _music_player.playing:
		_stop_music_immediate()
		return
	var ref   = _music_player
	var tween = create_tween()
	tween.tween_property(ref, "volume_db", -80.0, fade_time)
	await tween.finished
	if is_instance_valid(ref):
		ref.stop()
		ref.queue_free()
	if _music_player == ref:
		_music_player  = null
		_current_music = ""

func _stop_music_immediate() -> void:
	if _music_player != null:
		_music_player.stop()
		_music_player.queue_free()
		_music_player  = null
	_current_music = ""

# ─────────────────────────────────────────
# VOLUMEN
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

func set_volume(value: float) -> void:
	set_master_volume(value)

func _apply_music_volume() -> void:
	if _music_player != null and not muted:
		_music_player.volume_db = linear_to_db(master_volume * music_volume)

# ─────────────────────────────────────────
# CARGA LAZY CON CACHE
# ─────────────────────────────────────────
func _load_resource(sfx_key: String, paths: Dictionary) -> AudioStream:
	var cache_key: String = "%s_%d" % [sfx_key, paths.hash()]
	if _cache.has(cache_key):
		return _cache[cache_key]
	if not paths.has(sfx_key):
		push_warning("[AudioManager] Key desconocida: '%s'" % sfx_key)
		return null
	var path: String = paths[sfx_key]
	if not ResourceLoader.exists(path):
		return null
	var stream = load(path) as AudioStream
	if stream == null:
		push_warning("[AudioManager] Falló carga: %s" % path)
		return null
	_cache[cache_key] = stream
	return stream