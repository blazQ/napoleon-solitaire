extends Label

@export var move_count = 0

func _ready() -> void:
	text = "Moves: %d" % (move_count)


func _process(delta: float) -> void:
	pass

func _on_move():
	if get_parent().get_parent().game_started:
		move_count += 1
	text = "Moves: %d" % (move_count)
	


func _on_game_start_timeout() -> void:
	for card in get_tree().get_nodes_in_group("cards"):
		card.move.connect(_on_move)
