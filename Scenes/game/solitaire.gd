extends Node3D

const CardScene = preload(Strings.CARD_SCENE)
const CardConstants = preload(Strings.CARD_CONSTANTS)

# Game Logic Variables
@export var game_started: bool = false
@export var move_count: int = 0
@export var game_time: float = 0
@export var paused: bool = false
var piles_filled : int = 0

# Game Logic Members
@onready var selector: CardSelector = $CardSelector
@onready var field: Field = $Field
@onready var deck_handler = $DeckHandler
@onready var pause_menu = $PauseMenu
@onready var game_ui = $GameUI
@onready var win_scene = $WinSceneUI
@onready var audio_manager = $AudioManager
@onready var input_blocker = $InputBlocker
@onready var camera = $Camera3D

# Command History
var command_history: Array[MoveCardCommand] = []
const COMMAND_HISTORY_DEPTH: int = 3

signal game_over()

signal shuffling_end()
signal shuffling()

signal central_pile_move(suit: CardConstants.Suit)
signal play_audio_pile_filled(piles_filled: int)
signal undo_done()

signal ui_update_time(elapsed_time)
signal ui_update_move_count(move_count)

# TODO: UI should have sound when you press buttons

# TODO: UI should have a more interesting theme

# TODO: Difficulty setting for shuffling

# ------------------------------- Scene Instancing
func _ready():
	for pile in get_tree().get_nodes_in_group("special_piles"):
		pile.pile_filled.connect(_on_pile_filled)
	for pile in get_tree().get_nodes_in_group("piles"):
		pile.shake.connect(_on_shake_request)
	pause_menu.unpause.connect(_handle_pause)
	selector.move_card.connect(_on_move)
	game_ui.undo.connect(_on_undo)
	game_ui.reshuffle.connect(_on_reshuffle)

func _process(delta: float) -> void:
	if game_started:
		if !paused:
			game_time += delta
			emit_signal("ui_update_time", int(game_time))
		if Input.is_action_just_pressed("pause"):
			_handle_pause()
	
# ------------ Game Logic Functions 

func _on_game_start_timeout():
	# Building, shuffling and placing deck based on field rules.
	input_blocker.show()
	emit_signal("shuffling")
	
	var deck : Array[Card] = deck_handler.build_deck()
	deck = deck_handler.shuffle_deck(deck)
	field.place_deck_on_field(deck)
	
	# Building and placing foundations based on field rules.
	var foundations_to_piles = deck_handler.build_foundations(field.suits_piles)
	field.place_foundation_on_field(foundations_to_piles)

	# Distributing cards to playing zones.
	await field.distribute_deck_to_piles()
	
	game_started = true
	
	emit_signal("shuffling_end")
	input_blocker.hide()

func _on_pile_filled():
	piles_filled += 1
	emit_signal("play_audio_pile_filled", piles_filled)
	if piles_filled == 4:
		emit_signal("game_over")

func check_brick():
	return false

func _on_move(command: MoveCardCommand):
	if game_started:
		move_count += 1
		command.execute()
		if !command.card.is_finalized:
			command_history.push_front(command)
		else:
			emit_signal("central_pile_move", command.card.suit)
			_clean_command_history(command.card)
			
		emit_signal("ui_update_move_count", move_count)
		if check_brick():
			pass # Send to game over scene game is bricked

func _on_undo():
	if game_started:
		if !command_history.is_empty():
			move_count += 1
			var undone_command = command_history.pop_front()
			undone_command.undo()
			emit_signal("ui_update_move_count", move_count)
			emit_signal("undo_done")

func _on_reshuffle():
	input_blocker.show()
	emit_signal("shuffling")
	
	game_started = false
	game_time = 0
	
	field.field_cleanup()
	# Building, shuffling and placing deck based on field rules.
	var deck : Array[Card] = deck_handler.build_deck()
	deck_handler.shuffle_deck(deck)
	await field.place_deck_on_field(deck)
	
	# Building and placing foundations based on field rules.
	var foundations_to_piles = deck_handler.build_foundations(field.suits_piles)
	await field.place_foundation_on_field(foundations_to_piles)

	# Distributing cards to playing zones.
	await field.distribute_deck_to_piles()
	
	game_started = true
	emit_signal("shuffling_end")
	input_blocker.hide()

func _on_game_over():
	win_scene.show()

func _handle_pause():
	if paused:
		pause_menu.hide()
		get_tree().paused = false
	else:
		pause_menu.show()
		get_tree().paused = true
	paused = !paused

func _clean_command_history(card: Card):
	var index := 0
	for command in command_history:
		if command.card == card:
			command_history.remove_at(index)
		index+=1

func _on_shake_request(intensity, duration):
	if SettingsManager.camera_shake_enabled:
		if game_started:
			camera.shake(intensity, duration)
		else:
			camera.shake(0.09, 0.1)
