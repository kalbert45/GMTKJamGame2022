extends AnimatedSprite





# Called when the node enters the scene tree for the first time.
func _ready():
	connect("animation_finished", self, "_on_Animation_finished")


func _on_Animation_finished():
	frame = 0
	stop()
