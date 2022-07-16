extends Node2D

signal player_death
signal attacked_finished
signal move_ended(number, direction)

onready var _anim_player = $AnimationPlayer
onready var dice_scene = $Viewport/Dice_Scene
onready var player_sprite = $Player_Sprite
onready var _tween = $Tween
onready var hit_sfx = $Hit_SFX
onready var spawn_sfx = $Spawn_SFX
onready var despawn_sfx = $Despawn_SFX

const ATTACK_PATTERNS = {
	ONE = [Vector2(1,0), Vector2(2,0), Vector2(0,1), Vector2(0,2), Vector2(-1,0), Vector2(-2,0), Vector2(0,-1), Vector2(0,-2)],
	TWO = [Vector2(1,0), Vector2(1,1), Vector2(2,2), Vector2(2,0), Vector2(1,-1), Vector2(2,-2), Vector2(2,-1), Vector2(2,1)],
	THREE = [Vector2(0,1), Vector2(0,2), Vector2(0,3), Vector2(0,4), Vector2(0,-1), Vector2(0,-2), Vector2(0,-3), Vector2(0,-4)],
	FOUR = [Vector2(1,1), Vector2(2,2), Vector2(1,-1), Vector2(2,-2), Vector2(-1,1), Vector2(-2,2), Vector2(-1,-1), Vector2(-2,-2)],
	FIVE = [Vector2(2,1), Vector2(1,2), Vector2(-1,2), Vector2(-2,1), Vector2(-2,-1), Vector2(-1,-2), Vector2(1,-2), Vector2(2,-1)],
	SIX = [Vector2(-1,0), Vector2(-2,0), Vector2(0,1), Vector2(-1,1), Vector2(-2,1), Vector2(0,-1), Vector2(-1,-1), Vector2(-2,-1)]
}

var lives = 3
var _grid
var tile
var grid_location
var walking = false

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_sfx.play()
	_tween.connect("tween_all_completed", self, "_on_walk_end")

func receive_hit(_enemy, _power):
	hit_sfx.play()
	_anim_player.play("Take_damage")
	lives -= 1
	if lives <= 0:
		die()
	
func die():
	emit_signal("player_death")

# whether the tile is available or not is the grids job
func walk_to(direction, target_tile):
	walking = true
	_tween.interpolate_property(self, "position", position, target_tile.position, 0.75, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	_tween.start()
	
	match direction:
		Global.DIRECTIONS.NE:
			player_sprite.play("sw_walk")
		Global.DIRECTIONS.NW:
			player_sprite.play("se_walk")
		Global.DIRECTIONS.SW:
			player_sprite.play("ne_walk")
		Global.DIRECTIONS.SE:
			player_sprite.play("nw_walk")
	
	dice_scene.turn(direction)
	
	_grid.units.erase(tile)
	_grid.units[target_tile] = self
	tile = target_tile
	grid_location = tile.location
	
	var face_value = yield(dice_scene, "turn_finished")

	#attack(face_value, direction)
	emit_signal("move_ended", face_value, direction)
	
#func attack(face_value, direction):
	
	
#	yield()

func _on_walk_end():
	pass


# temp

