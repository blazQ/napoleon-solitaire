extends Control

@export var siblingContainer: Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CRTFilter.text = "CRT Filter: " + str(SettingsManager.crt_enabled)
	$Fullscreen.text = "Fullscreen: " + str(SettingsManager.fullscreen_enabled)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_back_pressed() -> void:
	siblingContainer.show()
	$".".hide()

func _on_crt_filter_pressed() -> void:
	SettingsManager.set_crt_enabled()
	$CRTFilter.text = "CRT Filter: " + str(SettingsManager.crt_enabled)


func _on_fullscreen_pressed() -> void:
	SettingsManager.set_fullscreen()
	$Fullscreen.text = "Fullscreen: " + str(SettingsManager.fullscreen_enabled)
