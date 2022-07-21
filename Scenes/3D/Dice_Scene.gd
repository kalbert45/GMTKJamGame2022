extends Spatial

signal turn_finished(face_value)

onready var tween = $Tween
onready var cube = $dice/Cube
onready var raycast_node = $dice/Cube/Raycasts

var turning = false


func _ready():
	pass


func turn(direction):
	turning = true
	#print(cube.global_transform)
	match direction:
		Global.DIRECTIONS.NE:
			tween.interpolate_property(cube, "global_transform", cube.global_transform, cube.global_transform.rotated(Vector3(1,0,0), deg2rad(-90)), Bgm.beat_length * 2 / 3,Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
		Global.DIRECTIONS.NW:
			tween.interpolate_property(cube, "global_transform", cube.global_transform, cube.global_transform.rotated(Vector3(0,0,1), deg2rad(90)), Bgm.beat_length * 2 / 3,Tween.TRANS_QUAD, Tween.EASE_IN_OUT)

		Global.DIRECTIONS.SW:
			tween.interpolate_property(cube, "global_transform", cube.global_transform, cube.global_transform.rotated(Vector3(1,0,0), deg2rad(90)), Bgm.beat_length * 2 / 3,Tween.TRANS_QUAD, Tween.EASE_IN_OUT)

		Global.DIRECTIONS.SE:
			tween.interpolate_property(cube, "global_transform", cube.global_transform, cube.global_transform.rotated(Vector3(0,0,1), deg2rad(-90)), Bgm.beat_length * 2 / 3,Tween.TRANS_QUAD, Tween.EASE_IN_OUT)

		
	tween.start()
	yield(tween, "tween_all_completed")
	
	# give player node 'i+1' : face up die number
	var face_value = 0
	for i in raycast_node.get_children().size():
		var raycast = raycast_node.get_children()[i]
		if raycast.is_colliding():
			face_value = i+1
	
	emit_signal("turn_finished", face_value)
	turning = false
	#print(rotation_degrees)

