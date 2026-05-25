# scripts/ui/settings_popup.gd
# ─────────────────────────────────────────
# SETTINGS POPUP
# US-AUDIO-010 — control de volumen (master, música, sfx, mute)
# Uso: instanciar desde cualquier escena y conectar "closed"
#
#   var popup = SettingsPopupScene.instantiate()
#   add_child(popup)
# ─────────────────────────────────────────
extends Control
class_name SettingsPopup

signal closed

@onready var panel            = $Panel
@onready var label_title      = $Panel/Margin/VBox/LabelTitle
@onready var slider_master    = $Panel/Margin/VBox/RowMaster/SliderMaster
@onready var label_master_val = $Panel/Margin/VBox/RowMaster/LabelMasterVal
@onready var slider_music     = $Panel/Margin/VBox/RowMusic/SliderMusic
@onready var label_music_val  = $Panel/Margin/VBox/RowMusic/LabelMusicVal
@onready var slider_sfx       = $Panel/Margin/VBox/RowSFX/SliderSFX
@onready var label_sfx_val    = $Panel/Margin/VBox/RowSFX/LabelSFXVal
@onready var button_mute      = $Panel/Margin/VBox/ButtonMute
@onready var button_close     = $Panel/Margin/VBox/ButtonClose

func _ready() -> void:
	_apply_theme()
	_load_values()
	_connect_signals()
	_animate_in()

# ─────────────────────────────────────────
# TEMA
# ─────────────────────────────────────────
func _apply_theme() -> void:
	# Fondo semitransparente detrás del panel
	var bg_color = Color(0, 0, 0, 0.55)
	add_theme_color_override("font_color", ThemeManager.C_TEXT)

	if panel:
		panel.add_theme_stylebox_override(
			"panel",
			ThemeManager.make_panel_style(
				ThemeManager.C_SURFACE_2,
				ThemeManager.C_AMBER_DIM,
				2,
				ThemeManager.RADIUS
			)
		)

	ThemeManager.apply_label_title(label_title)
	label_title.text = "⚙️ Ajustes de audio"

	# Labels de valor
	for lbl in [label_master_val, label_music_val, label_sfx_val]:
		ThemeManager.apply_label_dim(lbl)
		lbl.custom_minimum_size = Vector2(40, 0)

	ThemeManager.apply_button_secondary(button_mute)
	button_mute.custom_minimum_size = Vector2(0, 52)

	ThemeManager.apply_button_primary(button_close)
	button_close.custom_minimum_size = Vector2(0, 52)
	button_close.text = "✔ Cerrar"

# ─────────────────────────────────────────
# CARGAR VALORES ACTUALES DEL AudioManager
# ─────────────────────────────────────────
func _load_values() -> void:
	slider_master.value = AudioManager.master_volume * 100.0
	slider_music.value  = AudioManager.music_volume  * 100.0
	slider_sfx.value    = AudioManager.sfx_volume    * 100.0
	_update_labels()
	_update_mute_button()

func _update_labels() -> void:
	label_master_val.text = "%d%%" % int(slider_master.value)
	label_music_val.text  = "%d%%" % int(slider_music.value)
	label_sfx_val.text    = "%d%%" % int(slider_sfx.value)

func _update_mute_button() -> void:
	if AudioManager.muted:
		button_mute.text = "🔇 Sin sonido (activo)"
		button_mute.add_theme_color_override("font_color", ThemeManager.C_RED_BRIGHT)
	else:
		button_mute.text = "🔊 Silenciar todo"
		button_mute.add_theme_color_override("font_color", ThemeManager.C_TEXT)

# ─────────────────────────────────────────
# SEÑALES
# ─────────────────────────────────────────
func _connect_signals() -> void:
	slider_master.value_changed.connect(_on_master_changed)
	slider_music.value_changed.connect(_on_music_changed)
	slider_sfx.value_changed.connect(_on_sfx_changed)
	button_mute.pressed.connect(_on_mute_pressed)
	button_close.pressed.connect(_on_close_pressed)

func _on_master_changed(value: float) -> void:
	AudioManager.set_master_volume(value / 100.0)
	label_master_val.text = "%d%%" % int(value)

func _on_music_changed(value: float) -> void:
	AudioManager.set_music_volume(value / 100.0)
	label_music_val.text = "%d%%" % int(value)

func _on_sfx_changed(value: float) -> void:
	AudioManager.set_sfx_volume(value / 100.0)
	label_sfx_val.text = "%d%%" % int(value)
	# Preview al mover el slider
	AudioManager.play_sfx("click")

func _on_mute_pressed() -> void:
	AudioManager.set_muted(!AudioManager.muted)
	_update_mute_button()
	if not AudioManager.muted:
		AudioManager.play_sfx("click")

func _on_close_pressed() -> void:
	AudioManager.play_sfx("confirm")
	_animate_out()

# ─────────────────────────────────────────
# ANIMACIONES
# ─────────────────────────────────────────
func _animate_in() -> void:
	modulate.a = 0.0
	if panel:
		panel.scale = Vector2(0.88, 0.88)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, 0.2)
	if panel:
		tween.tween_property(panel, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK)

func _animate_out() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.18)
	await tween.finished
	closed.emit()
	queue_free()

# Cerrar con Escape
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			_on_close_pressed()