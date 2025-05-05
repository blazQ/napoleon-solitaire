extends GPUParticles3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.start(lifetime + 1.0)

func _on_timer_timeout():
	call_deferred("queue_free")
