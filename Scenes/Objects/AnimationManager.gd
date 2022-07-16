extends AnimationPlayer

signal despawn



func _ready():
	connect("animation_finished", self, "_on_Animation_finished")
	
func _on_Animation_finished(animation):
	match animation:
		"Attack":
			play("Idle")
		"Damage_taken":
			play("Idle")
		"End_turn":
			play("Idle")
		"Spawn":
			play("Idle")
		"Despawn":
			emit_signal("despawn")

			
