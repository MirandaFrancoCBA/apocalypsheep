# scripts/managers/audio_manager.gd
# ─────────────────────────────────────────
# AUDIO MANAGER
# Carga lazy — no crashea si faltan archivos.
# Cuando agregues los .wav simplemente existirán
# y se cargarán automáticamente sin tocar este código.
#
# Rutas esperadas (crear carpeta res://audio/sfx/):
#   res://audio/sfx/hit.wav
#   res://audio/sfx/crit.wav
#   res://audio/sfx/loot.wav
#   res://audio/sfx/levelup.wav
#   res://audio/sfx/game_over.wav
#   res://audio/sfx/heal.wav
# ─────────────────────────────────────────
extends Node

# Cache de streams ya cargados
var _cache: Dictionary = {}

# Volumen global (0.0 a 1.0)
var master_volume: float = 1.0

# Rutas de cada efecto
const SFX_PATHS := {
	"hit":       "res://audio/sfx/hit.wav",
	"crit":      "res://audio/sfx/crit.wav",
	"loot":      "res://audio/sfx/loot.wav",
	"levelup":   "res://audio/sfx/levelup.wav",
	"game_over": "res://audio/sfx/game_over.wav",
	"heal":      "res://audio/sfx/heal.wav",
}

# ─────────────────────────────────────────
# API PÚBLICA
# ─────────────────────────────────────────
func play_sfx(sfx_name: String) -> void:
	var stream = _get_stream(sfx_name)
	if stream == null:
		# Sin audio no es un error crítico — el juego sigue
		return

	var player = AudioStreamPlayer.new()
	add_child(player)
	player.stream        = stream
	player.volume_db     = linear_to_db(master_volume)
	player.play()
	player.finished.connect(func(): player.queue_free())

func set_volume(value: float) -> void:
	master_volume = clamp(value, 0.0, 1.0)

# ─────────────────────────────────────────
# CARGA LAZY CON CACHE
# ─────────────────────────────────────────
func _get_stream(sfx_name: String) -> AudioStream:
	# Ya estaba en cache
	if _cache.has(sfx_name):
		return _cache[sfx_name]

	# Buscar la ruta
	if not SFX_PATHS.has(sfx_name):
		push_warning("[AudioManager] SFX desconocido: " + sfx_name)
		return null

	var path = SFX_PATHS[sfx_name]

	# Verificar que existe antes de cargar
	if not ResourceLoader.exists(path):
		# Warning silencioso — normal si aún no tenés los archivos
		return null

	var stream = load(path)
	if stream == null:
		push_warning("[AudioManager] No se pudo cargar: " + path)
		return null

	_cache[sfx_name] = stream
	return stream