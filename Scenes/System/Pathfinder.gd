class_name Pathfinder
extends Reference

const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]


var _astar := AStar2D.new()

func _init(walkable_tiles: Array, current_tile):

	
	var cell_mappings = {}
	for tile in walkable_tiles:
		cell_mappings[Vector2(tile.location.x, tile.location.y)] = tile.index
	
	if is_instance_valid(current_tile):
		cell_mappings[Vector2(current_tile.location.x, current_tile.location.y)] = current_tile.index
		
	_add_and_connect_points(cell_mappings)
	
func calculate_point_path(start_tile, end_tile):
	if start_tile == end_tile:
		return PoolVector2Array()
	
	var start_index = start_tile.index
	var end_index = end_tile.index
	
	if _astar.has_point(start_index) and _astar.has_point(end_index):
		return _astar.get_point_path(start_index, end_index)
	else:
		return PoolVector2Array()
	
func _add_and_connect_points(cell_mappings: Dictionary):
	for point in cell_mappings.keys():
		_astar.add_point(cell_mappings[point], point)
		
	for point in cell_mappings.keys():
		for neighbor_index in _find_neighbor_indices(point, cell_mappings):
			_astar.connect_points(cell_mappings[point], neighbor_index)
			
func _find_neighbor_indices(cell: Vector2, cell_mappings: Dictionary):
	var out = []
	for direction in DIRECTIONS:
		var neighbor = cell + direction
		if not cell_mappings.has(neighbor):
			continue
			
		if not _astar.are_points_connected(cell_mappings[cell], cell_mappings[neighbor]):
			out.push_back(cell_mappings[neighbor])
	return out
