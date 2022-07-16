extends Node2D



const TILE_SCENE = preload("res://Scenes/Objects/Tile.tscn")
const PLAYER_SCENE = preload("res://Scenes/Objects/Player.tscn")
const CENTER = Vector2(240, 35)

enum {PLAYER_PHASE, ENEMY_PHASE}

var player

var game_world := []
var grid_width = 8
var grid_height = 8
var units = {}

var active := true setget _active_setter

onready var tiles_node = $Tiles
onready var units_node = $Units

func _ready():
	initialize_grid(16,16)

func _active_setter(value):
	active = value
	
func initialize_grid(width, height):
	grid_width = width
	grid_height = height
	
	for x in grid_width:
		game_world.append([])
		for y in grid_height:
			var new_tile = TILE_SCENE.instance()
			new_tile.position = coords_to_map(Vector2(x,y))
			new_tile.location = Vector2(x,y)
			
			tiles_node.add_child(new_tile)
			game_world[x].append(new_tile)
			#yield(get_tree().create_timer(0.03), "timeout")
			
	initialize_player(Vector2(width/2-1, height/2-1))
			
func initialize_player(pos):
	player = PLAYER_SCENE.instance()
	player.grid_location = pos
	player._grid = self
	player.tile = game_world[pos.x][pos.y]
	units[player.tile] = player
	player.position = coords_to_map(pos)
	units_node.add_child(player)
# QOL grid functions
#------------------------------------------------------------------
func in_bounds(x, y):
	if (x >= 0) and (x < grid_width) and (y >= 0) and (y < grid_height):
		if is_instance_valid(game_world[x][y]):
			return true
	return false
	
func to_index(x, y):
	return ((grid_height*x) + y)
	
func to_coords(index):
	return Vector2(index / grid_height, index % grid_height)
	
func coords_to_map(v: Vector2):
	return (14 * Vector2(v.x - v.y, (v.x+v.y)/2.0) +CENTER)
	
func map_to_coords(v: Vector2):
	var _v = (v - CENTER) / 14
	return Vector2((_v.x/2) + _v.y, _v.y - (_v.x/2))
	
func is_occupied(tile):
	return tile in units.keys()
	
# implement later for dist score
func get_dist(from_tile, to_tile):
	pass
	
func snap_to_map(v: Vector2):
	var _v = map_to_coords(v)
	_v = Vector2(round(_v.x), round(_v.y))
	_v = coords_to_map(_v)
	return _v
	
func nearest_tile(v: Vector2):
	var _v = map_to_coords(v)
	_v = Vector2(int(round(_v.x)), int(round(_v.y)))
	#_v = coords_to_map(_v)
	return game_world[_v.x][_v.y]
	
#---------------------------------------------------------------------

# on button press, check if player can move to that location, then move and calculate attack
# wait for everything to be over, then initiate enemy phase
func _unhandled_input(event):
	if !active:
		return
		
	if event.is_action_pressed("move_ne"):
		if check_available_tile(player.tile, Global.DIRECTIONS.NE):
			active = false
			move_player(Global.DIRECTIONS.NE)
	elif event.is_action_pressed("move_nw"):
		if check_available_tile(player.tile, Global.DIRECTIONS.NW):
			active = false
			move_player(Global.DIRECTIONS.NW)
	elif event.is_action_pressed("move_sw"):
		if check_available_tile(player.tile, Global.DIRECTIONS.SW):
			active = false
			move_player(Global.DIRECTIONS.SW)
	elif event.is_action_pressed("move_se"):
		if check_available_tile(player.tile, Global.DIRECTIONS.SE):
			active = false
			move_player(Global.DIRECTIONS.SE)

func move_player(direction):
	var target_tile_location = player.tile.location
	match direction:
		Global.DIRECTIONS.NW:
			target_tile_location += Vector2(-1,0)
		Global.DIRECTIONS.NE:
			target_tile_location += Vector2(0,-1)
		Global.DIRECTIONS.SE:
			target_tile_location += Vector2(1,0)
		Global.DIRECTIONS.SW:
			target_tile_location += Vector2(0,1)
	player.walk_to(direction, game_world[target_tile_location.x][target_tile_location.y])
	yield(player, "move_ended")
	active = true
	
func process_attack():
	pass
	
func check_available_tile(current_tile, direction):
	var v = current_tile.location
	match direction:
		Global.DIRECTIONS.NW:
			v += Vector2(-1,0)
		Global.DIRECTIONS.NE:
			v += Vector2(0,-1)
		Global.DIRECTIONS.SE:
			v += Vector2(1,0)
		Global.DIRECTIONS.SW:
			v += Vector2(0,1)
			
	if !in_bounds(v.x, v.y):
		return false
		
	if is_occupied(game_world[v.x][v.y]):
		return false
		
	return true
	
	
	
	
