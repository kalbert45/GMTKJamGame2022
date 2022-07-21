extends AudioStreamPlayer

signal beat(position)
signal combo_break

onready var tween = $Tween

export var bpm := 107

# for manipulating audio
var low_pass_effect
var music_volume

# for rhythm track and speed of game
var beat_length = 60.0 / bpm
var song_position = 0.0
var song_position_beats = 0
var last_reported_beat = 0

# for determining accuracy
var closest_b = 0
var time_off_beat = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("finished", self, "_on_BGM_finished")
	beat_length = 60.0 / bpm
	low_pass_effect = AudioServer.get_bus_effect(1,0)

func muffle():
	tween.interpolate_property(low_pass_effect, "resonance", low_pass_effect.resonance, 0.1, 1, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.interpolate_property(self, "volume_db", volume_db, -26, 1, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.start()
	
func unmuffle():
	tween.interpolate_property(low_pass_effect, "resonance", low_pass_effect.resonance, 0.7, 1, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.interpolate_property(self, "volume_db", volume_db, -20, 1, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.start()

func _physics_process(delta):
	if playing:
		# idk why 5 ms needed
		song_position = get_playback_position() + AudioServer.get_time_since_last_mix()+ 0.05
		song_position -= AudioServer.get_output_latency()
		song_position_beats = int(floor(song_position / beat_length))
		_report_beat()

func _report_beat():
	if last_reported_beat < song_position_beats:
		emit_signal("beat", song_position_beats)
		last_reported_beat = song_position_beats
		#print(last_reported_beat)
		if abs(last_reported_beat - closest_b) > 2:
			emit_signal("combo_break")
		#	print("combo break")
		
func closest_beat():
	closest_b = int(round((song_position / beat_length)))
	#print(closest_b * beat_length - song_position)
	time_off_beat = abs(closest_b * beat_length - song_position)
	return Vector2(closest_b, time_off_beat)
		
func _on_BGM_finished():
	play()
