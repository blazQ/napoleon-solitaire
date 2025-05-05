extends Control

signal undo()
signal redo()
signal reshuffle()

func _on_reshuffle_pressed() -> void:
	emit_signal("reshuffle")


func _on_solitaire_ui_update_move_count(move_count: Variant) -> void:
	$MenuPanel/ScoreTime/MoveCount.text = "Moves: " + str(move_count)


func _on_solitaire_ui_update_time(elapsed_time: int) -> void:
	$MenuPanel/ScoreTime/ElapsedTimeLabel.text = Time.get_time_string_from_unix_time(elapsed_time)


func _on_undo_pressed() -> void:
	emit_signal("undo")
