class_name Decisionmaker
extends Reference

var _grid
var _current_unit

# contains optimal target if applicable, threat level, enemy threat level, distance weight
var _threat_levels = {}

const DISTANCE_WEIGHT = 0.05
const AGGRESSION_WEIGHT = 1
const SELF_PRESERVATION_WEIGHT = 0

func _init(grid, current_tile, movable_tiles):
	_grid = grid
	_current_unit = _grid.units[current_tile]
	
	# if unit isnt an enemy, push an error, unintended use
	if !_current_unit.is_in_group("Enemies"):
		push_error("Trying to make decision for non-enemy!")
	
	#var movable_tiles = _grid.get_move_mode_tiles(current_tile)
	_assess_threats(movable_tiles)
	
func make_decision(current_tile):
	
	var optimal_tile = null
	var heuristic_value = -99
	
	# temporary, should be stored in enemy unit class
	#var enemy_threshold = 1
	# prioritize escaping deadly threat
#	if _threat_levels[current_tile][2] >= enemy_threshold:
#		for tile in _threat_levels:
#			var value = _threat_levels[tile][1] - _threat_levels[tile][2]
#			if value >= heuristic_value:
#				heuristic_value = value
#				optimal_tile = tile
					
#		if is_instance_valid(optimal_tile):
#			return ["Move", current_tile, optimal_tile]
		
	# second priority, attack enemy in range
	if is_instance_valid(_threat_levels[current_tile][0]):
		return ["Attack", current_tile, _threat_levels[current_tile][0]]
		
	#last priority, simply go to optimal tile, include distance calculation
	heuristic_value = -99
	for tile in _threat_levels:
		var value = _threat_levels[tile][1] - _threat_levels[tile][2] + _threat_levels[tile][3]
		if value >= heuristic_value:
			heuristic_value = value
			optimal_tile = tile
			
			
	if is_instance_valid(optimal_tile):
		#print(heuristic_value)
		return ["Move", current_tile, optimal_tile]
	else:
		push_error("Unable to make a decision for tile at " + str(Vector2(current_tile.x, current_tile.y)))
	

	
func _assess_threats(movable_tiles):
	# dictionary with tiles as keys, array of unit_threat, enemy_threat as values
	for tile in movable_tiles:
		var optimal_target = null
		var unit_threat = 0
		var enemy_threat = 0
		var dist_score = 0
		
		# find unit threat
		var attack_tiles = _grid.get_attack_mode_tiles(tile, _current_unit)
		for attack_tile in attack_tiles:
			if !_grid.is_occupied(attack_tile):
				continue
			var potential_target = _grid.units[attack_tile]
			if !potential_target.is_in_group("Units"):
				continue
	#		var evaluation = _evaluate_target(potential_target)
	#		if evaluation > unit_threat:
	#			unit_threat = evaluation
			optimal_target = attack_tile
			
		# find enemy threat level and distance score
	#	var enemy_tiles = []
		for e_tile in _grid.units:
			if _grid.units[e_tile].is_in_group("Units"):
	#			enemy_tiles.append(e_tile)
				#temp
				dist_score += 1/(Vector2(e_tile.location.x, e_tile.location.y).distance_to(Vector2(tile.location.x, tile.location.y)))
				
				
	#	for enemy_tile in enemy_tiles:
	#		var tiles_in_range = _grid.get_attack_mode_tiles(enemy_tile, _grid.units[enemy_tile])
	#		for tile_in_range in tiles_in_range:
	#			if tile_in_range != tile:
	#				continue
	#			enemy_threat += _evaluate_enemy(_grid.units[enemy_tile])
				
		unit_threat *= AGGRESSION_WEIGHT
		enemy_threat *= SELF_PRESERVATION_WEIGHT
		dist_score *= DISTANCE_WEIGHT
		_threat_levels[tile] = [optimal_target, unit_threat, enemy_threat, dist_score]
		
	#print(_threat_levels)
			
# returns evaluation of threat
#func _evaluate_target(target):
	# power and target hp important
#	return _current_unit.power/(target.health+1)
			
#func _evaluate_enemy(enemy):
#	return enemy.power/(_current_unit.health+1)
	
	# need:
	# directly attackable tiles
	# movable tiles
	# secondary attackable tiles
	# enemy units and stats

	
	# potential actions (ranked):
	# Move to lower enemy threat level
	# Attack a certain enemy
	# Move to increase unit threat
	
	# heuristic values:
	# enemy threat: enemy power, health, within attack/secondary range, ability to reduce threat
	# unit threat: power, enemy health, enemy within attack/secondary range, 
	
	# specific action:
	# check enemies that have unit in attack range. Assess enemy threat, if below threshold move on
		# if threat level is high enough, check if there is a tile that reduces it enough else move on
	# If enemies in attack range, pick best one and attack it.
	# else, move to optimal tile
