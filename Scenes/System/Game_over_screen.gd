extends Control


onready var button = $Button
onready var score_label = $Score

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	button.disabled = true

func show_screen(score):
	score_label.text = score_label.text + str(score)
	score_label.rect_size = score_label.get_font("normal_font").get_string_size(score_label.text)
	score_label.rect_position.x = 960 - (score_label.rect_size.x / 2)
	
	visible = true
	button.disabled = false
	
func disable():
	score_label.text = "Final Score: "
	visible = false
	button.disabled = true

