extends Node2D

signal enemy_action_ended

const TILE_SCENE = preload("res://Scenes/Objects/Tile.tscn")
const PLAYER_SCENE = preload("res://Scenes/Objects/Player.tscn")
const ENEMY_SCENE = preload("res://Scenes/Objects/Enemy_Virus.tscn")
const CENTER = Vector2(240, 35)

enum {PLAYER_PHASE, ENEMY_PHASE}
var current_phase = PLAYER_PHASE

var player

var _decisionmaker: Decisionmaker
var _pathfinder: Pathfinder

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
			new_tile._grid = self
			new_tile.position = coords_to_map(Vector2(x,y))
			new_tile.index = to_index(x, y)
			new_tile.location = Vector2(x,y)
			
			tiles_node.add_child(new_tile)
			game_world[x].append(new_tile)
			#yield(get_tree().create_timer(0.03), "timeout")
			
	initialize_player(Vector2(width/2-1, height/2-1))
	spawn_enemy(Vector2(0,0))
	spawn_enemy(Vector2(10,10))
			
func initialize_player(pos):
	player = PLAYER_SCENE.instance()
	player.grid_location = pos
	player._grid = self
	player.tile = game_world[pos.x][pos.y]
	units[player.tile] = player
	player.position = coords_to_map(pos)
	player.connect("player_death", self, "_on_Player_death")
	units_node.add_child(player)
	
func spawn_enemy(pos):
	var new_enemy = ENEMY_SCENE.instance()
	new_enemy.grid = self
	new_enemy.position = coords_to_map(pos)
	new_enemy.connect("death", self, "_on_Death")
	new_enemy.tile = game_world[pos.x][pos.y]
	units[new_enemy.tile] = new_enemy
	units_node.add_child(new_enemy)
	
#to-do
func _on_Player_death():
	pass
	
func _on_Death(tile):
	units.erase(tile)
	
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
#----------------------------------------------------------------------
# phase/combat handlers
	
func end_phase():
	if current_phase == PLAYER_PHASE:
		current_phase = ENEMY_PHASE
		handle_enemy_phase()
	else:
		current_phase = PLAYER_PHASE
		active = true
	
func handle_enemy_phase():
	var _enemy
	for tile in units.keys():
		if !is_instance_valid(tile):
			continue
		if !units[tile].is_in_group("Enemies"):
			continue
		if units[tile].dead:
			continue
			
		_enemy = units[tile]
		var movable_tiles = get_move_mode_tiles(tile)
		movable_tiles.append(tile)
		
		_decisionmaker = Decisionmaker.new(self, tile, movable_tiles)
		var decision = _decisionmaker.make_decision(tile)
		execute_enemy_decision(decision[0], decision[1], decision[2], movable_tiles)
		#yield(self, "enemy_action_ended")
		
	if is_instance_valid(_enemy):
		yield(_enemy, "action_ended")
		
	end_phase()
		
func execute_enemy_decision(action, from_tile, to_tile, movable_tiles):
	match action:
		"Move":
			move_to_tile(from_tile, to_tile, movable_tiles)
		"Attack":
			attack(from_tile, to_tile)
			
func move_to_tile(from_tile, to_tile, movable_tiles):
	var unit = units[from_tile]
	var path = get_tile_path(from_tile, to_tile, movable_tiles)
	unit.tile = to_tile
	unit.walk_along(path)
	
	units.erase(from_tile)
	units[to_tile] = unit
	#emit_signal("enemy_action_ended")

func get_tile_path(start_tile, end_tile, movable_tiles):
	_pathfinder = Pathfinder.new(movable_tiles, start_tile)
	var path = _pathfinder.calculate_point_path(start_tile, end_tile)
	var converted_path = []
	for cell in path:
		converted_path.append(coords_to_map(cell))
	return converted_path
	
func attack(from_tile, target_tile):
	var attacking_unit = units[from_tile]
	attacking_unit.attack(target_tile)
	#emit_signal("enemy_action_ended")

func get_attack_mode_tiles(tile, unit):

	var out = []
	var attack_pattern = unit.attack_pattern
	for attack in attack_pattern:
		for dir in four_dir(attack):
			var cell = dir + Vector2(tile.location.x, tile.location.y)
			if !in_bounds(cell.x, cell.y):
				continue
			out.append(game_world[cell.x][cell.y])
	return out
	
func four_dir(dir: Vector2):
	return [dir, Vector2(-dir.y, dir.x), Vector2(-dir.x, -dir.y), Vector2(dir.y, -dir.x)]
		
func get_move_mode_tiles(tile):
	var unit = units[tile]
	var speed = unit.speed
	var stack = [tile]
	var move_mode_tiles = []
	move_mode_tiles = _flood_fill(tile, move_mode_tiles, stack, speed)
	
	return move_mode_tiles
	
func _flood_fill(start_tile, move_mode_tiles, stack, speed):
	var new_stack = []
	for tile in stack:
		if (tile != start_tile) and (not tile in move_mode_tiles):
			move_mode_tiles.append(tile)
		if speed > 0:
			var stack_tile_indices = [Vector2(tile.location.x-1, tile.location.y),Vector2(tile.location.x+1, tile.location.y),Vector2(tile.location.x, tile.location.y-1),Vector2(tile.location.x, tile.location.y+1)]
			for index in stack_tile_indices:
				if !in_bounds(index.x, index.y):
					continue
				var prospective_tile = game_world[index.x][index.y]
				if is_occupied(prospective_tile):
					continue
				new_stack.append(prospective_tile)
				
	if speed == 0:
		return move_mode_tiles
	else:
		var new_move_tiles = _flood_fill(start_tile, move_mode_tiles, new_stack, speed - 1)
		return new_move_tiles
	
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
	var attack = yield(player, "move_ended")
	process_attack(attack)
	
	
func process_attack(attack):
	var face_value = attack[0]
	var direction = attack[1]
	var attacked_tiles = []
	var attack_pattern = []
	match face_value:
		1:
			attack_pattern = player.ATTACK_PATTERNS.ONE
		2:
			attack_pattern = player.ATTACK_PATTERNS.TWO
		3:
			attack_pattern = player.ATTACK_PATTERNS.THREE
		4:
			attack_pattern = player.ATTACK_PATTERNS.FOUR
		5:
			attack_pattern = player.ATTACK_PATTERNS.FIVE
		6:
			attack_pattern = player.ATTACK_PATTERNS.SIX
			
	var new_pattern = []
	match direction:
		Global.DIRECTIONS.SE:
			for i in attack_pattern.size():
				new_pattern.append(attack_pattern[i])
		Global.DIRECTIONS.SW:
			for i in attack_pattern.size():
				new_pattern.append(Vector2(-attack_pattern[i].y, attack_pattern[i].x))
		Global.DIRECTIONS.NW:
			for i in attack_pattern.size():
				new_pattern.append(Vector2(-attack_pattern[i].x, -attack_pattern[i].y))
		Global.DIRECTIONS.NE:
			for i in attack_pattern.size():
				new_pattern.append(Vector2(attack_pattern[i].y, -attack_pattern[i].x))
			
			
	var _tile
	for v in new_pattern:
		var j = player.grid_location + v
		if !in_bounds(j.x, j.y):
			continue
		_tile = game_world[j.x][j.y]
		_tile.attacked()
		#yield(_tile, "attack_finished")
	
	yield(get_tree().create_timer(0.2), "timeout")
	#if is_instance_valid(_tile):
	#	yield(_tile, "attack_finished")
	end_phase()
	
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
	
	
	
	
