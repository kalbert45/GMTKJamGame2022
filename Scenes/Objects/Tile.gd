extends Node2D

signal attack_finished

var enemy_spawn = false

var index
var location = Vector2.ZERO
var _grid

onready var _anim_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	if enemy_spawn:
		$Sprite.texture = load("res://Assets/Sprites/enemy_spawn_tile.png")


func attacked(face_value):
	if position.y > _grid.player.position.y:
		z_index = 2
	else:
		z_index = 0
	match face_value:
		1:
			_anim_player.play("attacked_one")
		2:
			_anim_player.play("attacked_two")
		3:
			_anim_player.play("attacked_three")
		4:
			_anim_player.play("attacked_four")
		5:
			_anim_player.play("attacked_five")
		6:
			_anim_player.play("attacked_six")
	yield(_anim_player, "animation_finished")
	z_index = -1

func damage_unit():
	var _enemy
	if self in _grid.units.keys():
		var enemy = _grid.units[self]
		enemy.receive_hit()
		yield(enemy, "attacked_finished")
		
	#if is_instance_valid(_enemy):
	#	yield(_enemy, "attacked_finished")
	#z_index = 0
	emit_signal("attack_finished")
