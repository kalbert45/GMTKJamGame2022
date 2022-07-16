extends Node2D

signal move_ended(number, direction)

onready var dice_scene = $Viewport/Dice_Scene
onready var player_sprite = $Player_Sprite
onready var _tween = $Tween

const ATTACK_PATTERNS = {
	ONE = [],
	TWO = [],
	THREE = [],
	FOUR = [],
	FIVE = [],
	SIX = []
}

var _grid
var tile
var grid_location
var walking = false

# Called when the node enters the scene tree for the first time.
func _ready():
	_tween.connect("tween_all_completed", self, "_on_walk_end")

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
	print(face_value)
	print(grid_location)
	attack(face_value, direction)
	emit_signal("move_ended", face_value, direction)
	
func attack(face_value, direction):
	
	
	yield()

func _on_walk_end():
	pass


# temp

