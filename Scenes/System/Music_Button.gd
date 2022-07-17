extends TextureButton




# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.




func _on_Music_Button_toggled(button_pressed):
	if button_pressed:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), -99)
	else:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), 0)
