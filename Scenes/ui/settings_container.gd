extends Control

@export var siblingContainer: Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CRTFilter.text = "CRT Filter: " + ("ON" if SettingsManager.crt_enabled else "OFF")
	$Fullscreen.text = "Fullscreen: " + ("ON" if SettingsManager.fullscreen_enabled else "OFF")
	$"Camera Shake".text = "Camera Shake: " + ("ON" if SettingsManager.camera_shake_enabled else "OFF")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_back_pressed() -> void:
	siblingContainer.show()
	$".".hide()

func _on_crt_filter_pressed() -> void:
	SettingsManager.set_crt_enabled()
	$CRTFilter.text = "CRT Filter: " + ("ON" if SettingsManager.crt_enabled else "OFF")


func _on_fullscreen_pressed() -> void:
	SettingsManager.set_fullscreen()
	$Fullscreen.text = "Fullscreen: " + ("ON" if SettingsManager.fullscreen_enabled else "OFF")

func _on_camera_shake_pressed():
	SettingsManager.set_camera_shake()
	$"Camera Shake".text = "Camera Shake: " + ("ON" if SettingsManager.camera_shake_enabled else "OFF")
