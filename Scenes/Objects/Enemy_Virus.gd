extends Path2D

signal action_ended
signal attacked_finished
signal death(tile)

#export var max_health = 100.0
#export var health = 100.0
export var power = 50
export var speed = 2
export var move_speed = 150

var dead = false

var grid
var tile
var target_tile
var attack_pattern
var _is_walking := false setget _set_is_walking
#var active := false setget _set_active
#var combat = false

const SPAWN_SFX1 = preload("res://Assets/Sounds/SFX/tp_sfx.wav")
const SPAWN_SFX2 = preload("res://Assets/Sounds/SFX/tp_sfx2.wav")
const SPAWN_SFX3 = preload("res://Assets/Sounds/SFX/tp_sfx3.wav")

const DESPAWN_SFX1 = preload("res://Assets/Sounds/SFX/tp_out_sfx.wav")
const DESPAWN_SFX2 = preload("res://Assets/Sounds/SFX/tp_out_sfx2.wav")
const DESPAWN_SFX3 = preload("res://Assets/Sounds/SFX/tp_out_sfx3.wav")


onready var attack_sfx = $Attack_SFX
onready var hit_sfx = $Hit_SFX
onready var spawn_sfx = $Spawn_SFX
onready var despawn_sfx = $Despawn_SFX

onready var _sprite = $PathFollow2D/Sprite
onready var _anim_player = $PathFollow2D/Sprite/AnimationPlayer
onready var _path_follow = $PathFollow2D
onready var _tween = $Tween

func _ready():
	var rand = randi() % 3
	match rand:
		0:
			spawn_sfx.stream = SPAWN_SFX1
		1:
			spawn_sfx.stream = SPAWN_SFX2
		2:
			spawn_sfx.stream = SPAWN_SFX3
	
	spawn_sfx.play()
	# should be adjustable
	attack_pattern = [Vector2(1,0)]
	
	set_process(false)
	_anim_player.connect("despawn", self, "_on_Despawn")
	_tween.connect("tween_all_completed", self, "_on_walk_end")
	if not Engine.editor_hint:
		curve = Curve2D.new()

#func _set_active(value):
#	if active == value:
#		return
#	active = value
#	if !is_instance_valid(_anim_player): return
#	if !value: _anim_player.play("End_turn")
#	else: _anim_player.play_backwards("End_turn")

# combat functions
#-------------------------------------------------------
func attack(target):
	#set_process(true)
	if _path_follow.global_position.y < grid.player.global_position.y:
		z_index = -1
	else:
		z_index = 1
	
	target_tile = target
	var direction = find_direction()
	match direction:
		Global.DIRECTIONS.NE:
			_anim_player.play("ne_attack")
		Global.DIRECTIONS.NW:
			_anim_player.play("nw_attack")
		Global.DIRECTIONS.SW:
			_anim_player.play("sw_attack")
		Global.DIRECTIONS.SE:
			_anim_player.play("se_attack")
			
	_anim_player.queue("Idle")
	# play an animation
	attack_sfx.play()
	#_anim_player.play("Attack")
	
	# attack continues later
	
func find_direction():
	var v = target_tile.location - tile.location
	match v:
		Vector2(1,0):
			return Global.DIRECTIONS.SE
		Vector2(-1,0):
			return Global.DIRECTIONS.NW
		Vector2(0,1):
			return Global.DIRECTIONS.SW
		Vector2(0,-1):
			return Global.DIRECTIONS.NE
	
func attack_hit():

	if grid.is_occupied(target_tile):
		var target = grid.units[target_tile]
		target.receive_hit(self, power)
		#yield(target, "attacked_finished")
	
	#set_process(false)
	emit_signal("action_ended")
	
#take damage
func receive_hit():
	hit_sfx.play()
	
	die()
	
	# if not, play damage taken animation
	#_anim_player.play("Damage_taken")
	
	# check if damage would kill
	#if damage >= health:
	#	health = 0
	#	$PathFollow2D/Sprite/HP_Bar.tint_progress = Color(1.0,float(health/max_health),float(health/max_health))
	#	$PathFollow2D/Sprite/HP_Bar.value = health
	#	yield(_anim_player, "animation_finished")
	#	die()
	#	return
	
	# take damage
	#health -= damage
	#$PathFollow2D/Sprite/HP_Bar.tint_progress = Color(1.0,float(health/max_health),float(health/max_health))
	#$PathFollow2D/Sprite/HP_Bar.value = health
	# wait for animation to finish
	#yield(_anim_player, "animation_finished")
	


	emit_signal("attacked_finished")
	
func die():
	dead = true
	yield(get_tree(), "idle_frame")
	
	#emit_signal("death", tile)
	despawn()
	#queue_free()
	# play animation
	# wait until end of animation, then emit death signal
	# free unit

func despawn():
	var rand = randi() % 3
	match rand:
		0:
			despawn_sfx.stream = DESPAWN_SFX1
		1:
			despawn_sfx.stream = DESPAWN_SFX2
		2:
			despawn_sfx.stream = DESPAWN_SFX3
	
	despawn_sfx.play()
	_path_follow.rotation_degrees = 0
	_sprite.rotation_degrees = 0
	#grid.units.erase(tile)
	_anim_player.play("Despawn")
	#print(str(self) + " despawned")
	
func _on_Despawn():
	emit_signal("attacked_finished")
	emit_signal("death", tile)
	queue_free()

#---------------------------------------------------

func _set_is_walking(value):
	set_process(value)
	_is_walking = value
	if _is_walking: _begin_walk()
	else: _sprite.set_idle()
	
func _begin_walk():
	var time = (0.25 * (curve.get_point_count()-1)) + 0.05
	_tween.interpolate_property(_path_follow, "unit_offset", 0, 1, time, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	_tween.start()
	
func _on_walk_end():
	self._is_walking = false
	yield(get_tree(), "idle_frame")
	position = tile.position
	_path_follow.unit_offset = 0.0
	_sprite.rotation_degrees = -_path_follow.rotation_degrees

	curve.clear_points()
	
#	self.active = false
	emit_signal("action_ended")
	
func walk_along(path: PoolVector2Array):
	#if path.empty():
	#	return
		
	curve.add_point(Vector2.ZERO)
	for point in path:
		curve.add_point(point - position)
	self._is_walking = true
	
func _process(_delta):
	#hack in ysort
	if _path_follow.global_position.y < grid.player.global_position.y:
		z_index = -1
	else:
		z_index = 1
		
	_sprite.rotation_degrees = -_path_follow.rotation_degrees
	_sprite.set_tex_direction()
