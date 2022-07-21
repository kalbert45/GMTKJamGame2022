extends Control

onready var _anim_player = $AnimationPlayer
# Called when the node enters the scene tree for the first time.
func _ready():
	Bgm.connect("beat", self, "_on_Beat")


#spawn a beat thing on every other beat
func _on_Beat(position):
	_anim_player.play("Beat")
