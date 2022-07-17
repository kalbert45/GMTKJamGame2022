extends Control

signal game_over

onready var score_text = $RichTextLabel

var score = 0 setget set_score
var lives = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	$Life_Container/Life1/AnimationPlayer.connect("animation_finished", self, "_on_Animation_ended")
	$Life_Container/Life2/AnimationPlayer.connect("animation_finished", self, "_on_Animation_ended")
	$Life_Container/Life3/AnimationPlayer.connect("animation_finished", self, "_on_Animation_ended")
	
	set_score_text(score)

func set_score(value):
	score = value
	set_score_text(score)

func set_score_text(num):
	score_text.text = str(num)
	score_text.rect_size = score_text.get_font("normal_font").get_string_size(score_text.text)
	
func update_score():
	self.score = score + 1
	
func lose_life():
	match lives:
		3:
			$Life_Container/Life3.lose_life()
		2:
			$Life_Container/Life2.lose_life()
		1:
			$Life_Container/Life1.lose_life()
	
func _on_Animation_ended(animation):
	if animation == "Reset":
		return
	lives -= 1
	if lives <= 0:
		emit_signal("game_over")
		
func reset():
	visible = true
	self.score = 0
	lives = 3
	$Life_Container/Life1/AnimationPlayer.play_backwards("Reset")
	$Life_Container/Life2/AnimationPlayer.play_backwards("Reset")
	$Life_Container/Life3/AnimationPlayer.play_backwards("Reset")
