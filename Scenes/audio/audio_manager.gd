extends Node

const CardConstants = preload(Strings.CARD_CONSTANTS)

@onready var central_pile_sounds: Array[AudioStreamPlayer] = [$ClubsDrop, $SpadesDrop, $HeartsDrop, $DiamondsDrop]

var last_played_pile_index = 0

func _ready() -> void:
	for manager in get_tree().get_nodes_in_group("manager"):
		manager.central_pile_move.connect(_on_central_pile_move)
		manager.play_audio_pile_filled.connect(_on_pile_filled)
		manager.undo_done.connect(_on_undo)

func _on_central_pile_move(suit):
	var random_sound_index = randi_range(0, central_pile_sounds.size()-1) 
	while random_sound_index == last_played_pile_index:
		random_sound_index = randi_range(0, central_pile_sounds.size()-1) 
	central_pile_sounds[random_sound_index].play()
	last_played_pile_index = random_sound_index

func _on_pile_filled(piles_filled):
	if piles_filled == 1:
		$FirstPileFilled.play()
	elif piles_filled == 2:
		$SecondPileFilled.play()
	elif piles_filled == 3:
		$ThirdPileFilled.play()

func _on_undo():
	$Undo.play()
