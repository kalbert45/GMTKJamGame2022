extends Node2D

onready var tween = $Tween
onready var title = $Title

var tutorial
var game

const TUTORIAL_SCENE = preload("res://Scenes/System/Tutorial.tscn")
const GAME_SCENE = preload("res://Scenes/System/Game.tscn")

func _ready():
	$Title/Play_Button.connect("pressed", self, "_on_Play_button_pressed")

func _on_Play_button_pressed():
	tween.interpolate_property(title, "rect_position", title.rect_position, title.rect_position - Vector2(1920, 0), 0.75, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_all_completed")
	title.queue_free()
	tutorial = TUTORIAL_SCENE.instance()
	tutorial.connect("end_tutorial", self, "_on_Tutorial_end")
	add_child(tutorial)
	
func _on_Tutorial_end():
	tween.interpolate_property(tutorial, "position", tutorial.position, tutorial.position - Vector2(1920, 0), 0.75, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_all_completed")
	tutorial.queue_free()
	game = GAME_SCENE.instance()
	add_child(game)
	

