extends Node2D

signal attack_finished

var index
var location = Vector2.ZERO
var _grid

onready var _anim_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func attacked():
	_anim_player.play("attacked_one")

func damage_unit():
	var _enemy
	if self in _grid.units.keys():
		var enemy = _grid.units[self]
		enemy.receive_hit()
		yield(enemy, "attacked_finished")
		
	#if is_instance_valid(_enemy):
	#	yield(_enemy, "attacked_finished")
		
	emit_signal("attack_finished")
