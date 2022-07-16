extends Node2D


const GRID_SCENE = preload("res://Scenes/System/Grid.tscn")

var _grid



func _ready():
	_grid = GRID_SCENE.instance()
	add_child(_grid)
	_grid.initialize_grid(16,16)


