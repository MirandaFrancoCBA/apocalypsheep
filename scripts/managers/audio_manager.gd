extends Node

var sfx := {
	"hit": preload("res://audio/sfx/hit.wav"),
	"crit": preload("res://audio/sfx/crit.wav"),
	"loot": preload("res://audio/sfx/loot.wav"),
	"levelup": preload("res://audio/sfx/levelup.wav")
}

func play_sfx(name: String) -> void:

	if not sfx.has(name):
		return

	var player = AudioStreamPlayer.new()

	add_child(player)

	player.stream = sfx[name]
	player.play()

	player.finished.connect(
		func():
			player.queue_free()
	)
