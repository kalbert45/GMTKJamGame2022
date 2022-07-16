extends Node2D

signal end_tutorial

const GRID_SCENE = preload("res://Scenes/System/Grid.tscn")

var _grid

func _ready():
	_grid = GRID_SCENE.instance()
	_grid.tutorial = true
	_grid.center = Vector2(240, 70)
	add_child(_grid)
	_grid.initialize_grid(8,8)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_TextureButton_pressed():
	emit_signal("end_tutorial")
