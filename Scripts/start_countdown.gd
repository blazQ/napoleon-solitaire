extends Label

@export var start_timer: Timer

func set_start_timer(timer):
	start_timer = timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	text = "%.1f" % start_timer.time_left


func _on_game_start_timeout() -> void:
	hide()
