extends AudioStreamPlayer

onready var tween = $Tween

var low_pass_effect
var music_volume

# Called when the node enters the scene tree for the first time.
func _ready():
	low_pass_effect = AudioServer.get_bus_effect(1,0)



func muffle():
	tween.interpolate_property(low_pass_effect, "resonance", low_pass_effect.resonance, 0.1, 1, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.interpolate_property(self, "volume_db", volume_db, -26, 1, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.start()
	
func unmuffle():
	tween.interpolate_property(low_pass_effect, "resonance", low_pass_effect.resonance, 0.7, 1, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.interpolate_property(self, "volume_db", volume_db, -20, 1, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.start()
