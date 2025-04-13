extends Control

@export var start_time: float
@export var game_over: bool = false
@export var game_started: bool = false
@export var move_count: int = 0
@export var elapsed_time: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MenuPanel/ScoreTime/ElapsedTimeLabel.text = Time.get_time_string_from_unix_time(0)
	$MenuPanel/ScoreTime/MoveCount.text = "Moves: 0"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !game_over and game_started:
		elapsed_time = Time.get_unix_time_from_system() - start_time
		$MenuPanel/ScoreTime/ElapsedTimeLabel.text = Time.get_time_string_from_unix_time(elapsed_time)


func _on_reshuffle_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/table.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_game_start_timeout() -> void:
	game_started = true
	start_time = Time.get_unix_time_from_system()
	for card in get_tree().get_nodes_in_group("cards"):
		card.move.connect(_on_move)

func _on_move():
	move_count += 1
	$MenuPanel/ScoreTime/MoveCount.text = "Moves: %d" % (move_count)

func _on_solitaire_game_over() -> void:
	game_over = true
