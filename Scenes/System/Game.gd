extends Node2D


const GRID_SCENE = preload("res://Scenes/System/Grid.tscn")

var _grid

onready var hud = $HUD
onready var game_over_screen = $Game_over_screen
onready var image_node = $Image_node
onready var tween = $Tween
onready var _anim_player = $AnimationPlayer
onready var click_sfx = $Click_SFX

func _ready():
	$Game_over_screen/Button.connect("pressed", self, "reset")
	hud.connect("game_over", self, "_on_Game_over")
	
	_grid = GRID_SCENE.instance()
	add_child(_grid)
	_grid.initialize_grid(16,16)
	yield(_grid, "grid_initialized")
	_grid.player.connect("lose_life", self, "_on_Lose_life")
	_grid.connect("surrounded_game_over", self, "_on_Game_over")
	_grid.connect("update_score", self, "_on_Update_score")
	
func _on_Lose_life():
	hud.lose_life()

func _on_Update_score():
	hud.update_score()

func _on_Game_over():
	Bgm.stop()
	yield(get_tree().create_timer(0.5), "timeout")
	hud.visible = false
	#image_node.global_position = _grid.player.global_position
	var player = _grid.player
	player.get_parent().remove_child(player)
	image_node.add_child(player)
	_grid.call_deferred("free")
	tween.interpolate_property(image_node, "position", image_node.position, 4*(Vector2(240,150) - player.position), 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_all_completed")
	game_over_screen.show_screen(hud.score)
	
	
func reset():
	Bgm.play()
	click_sfx.play()
	for node in image_node.get_children():
		node.queue_free()
	image_node.position = Vector2.ZERO
	game_over_screen.disable()
	hud.reset()
	
	_grid = GRID_SCENE.instance()
	add_child(_grid)
	_grid.initialize_grid(16,16)
	yield(_grid, "grid_initialized")
	_grid.player.connect("lose_life", self, "_on_Lose_life")
	_grid.connect("surrounded_game_over", self, "_on_Game_over")
	_grid.connect("update_score", self, "_on_Update_score")
