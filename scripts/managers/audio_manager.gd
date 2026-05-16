extends Node

var sfx := {
	"hit": preload("res://audio/sfx/hit.wav"),
	"crit": preload("res://audio/sfx/crit.wav"),
	"loot": preload("res://audio/sfx/loot.wav"),
	"levelup": preload("res://audio/sfx/levelup.wav"),
	"game_over": preload("res://audio/sfx/game_over.wav")
}

func play_sfx(sfx_name: String) -> void:

	if not sfx.has(sfx_name):
		return

	var player = AudioStreamPlayer.new()

	add_child(player)

	player.stream = sfx[sfx_name]
	player.play()

	player.finished.connect(
		func():
			player.queue_free()
	)
