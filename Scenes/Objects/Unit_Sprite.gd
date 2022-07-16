extends Sprite


#var northeast_tex = preload("res://Assets/Sprites/temp_ne.png")
#var northwest_tex = preload("res://Assets/Sprites/temp_nw.png")
#var southwest_tex = preload("res://Assets/Sprites/temp_sw.png")
#var southeast_tex = preload("res://Assets/Sprites/temp_se.png")

onready var _anim_player = $AnimationPlayer

func set_tex_direction():
	if (rotation_degrees >= (0)) and (rotation_degrees <= (90)):
		if !_anim_player.current_animation == "ne_walk":
			_anim_player.play("ne_walk")
			_anim_player.seek(_anim_player.get_current_animation_position())
	elif (rotation_degrees >= (90)) and (rotation_degrees <= (180)):
		if !_anim_player.current_animation == "nw_walk":
			_anim_player.play("nw_walk")
			_anim_player.seek(_anim_player.get_current_animation_position())
	elif (rotation_degrees >= (-180)) and (rotation_degrees <= (-90)):
		if !_anim_player.current_animation == "ne_walk":
			_anim_player.play("ne_walk")
			_anim_player.seek(_anim_player.get_current_animation_position())
	else:
		if !_anim_player.current_animation == "nw_walk":
			_anim_player.play("nw_walk")
			_anim_player.seek(_anim_player.get_current_animation_position())
			
func set_idle():
	_anim_player.play("Idle")
