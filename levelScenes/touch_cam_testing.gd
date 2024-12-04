extends Node

# pd audio
@onready var pd_player: AudioStreamPlayer = $AudioStreamPlayerPD

var pd_playback: AudioStreamPlaybackPD
var pd_playing = false



@export var sample_point_scene : PackedScene

# sample_points[index]["point"] == [x,y]
# sample_points[index]["path"] == PATH
var sample_points = {}
var sample_nodes = [] # array of object instance references

# load sample mode changed from midi script
var loadSampleMode: bool = false
var last_sample_node_id: int = 0

func _load_UMAPjson() -> void:
	var json_as_test = FileAccess.get_file_as_string("res://imports/utt-2dUMAP.json")
	sample_points = JSON.parse_string(json_as_test)

func _populate_scene() -> void:
	var screen_size = get_viewport().get_visible_rect().size
	
	for i in 2000:#range(0,sample_points.size()):
		var point = sample_point_scene.instantiate()
		point.id = i
		point.sid = str("g", i)
		# save normalised position to instance
		point.x = sample_points[i]["point"][0]
		point.y = sample_points[i]["point"][1]
		# move to position on screen, center is origin.
		point.position.x = (point.x * screen_size[0]) - (screen_size[0]/2)
		point.position.y = (point.y * screen_size[1]) - (screen_size[1]/2)
		
		point.path = sample_points[i]["path"]
		
		sample_nodes.append(point)
		
		add_child(point)
		pd_init_samples(point.id, point.path)
		if (i%100 ==0) : print("loading sample: ", i)
		
	
func begin_playback():
	# setup pure data
	pd_player.play()
	pd_playback = pd_player.get_stream_playback()
	pd_playback.open_patch("./pdPAtches/main.pd")
	
	# listen to pure data |send sampler| object
	# this is the destination for all sampler sends, then send to instanced sample_node s
	pd_playback.subscribe("sampler")
	# call function on receiving sampler
	pd_playback.receive_symbol.connect(_on_receive_sampler_sid)


func pd_init_samples(id: int =0, path: String =""):
	
	var ids = str("g", id)
	#sends an array of strings to be parsed by pure data
	pd_playback.send_list("gd-initSamp", [ids, path])
	
# send initial bang to all samplers in PD due to weird bug.
# this means that all the samples play at once on start. not ok.
func pd_init_bang():
	pd_playback.send_bang("initSoundFiler")

func pd_bang(id: int = 0):
	# test send bang to pd |r gd-bang|
	pd_playback.send_bang("gd-bang")
	print(id)
	
# send an index of type float to pd for selecting from samplebank
# if in load sample mode, send sample node id to midi script for adding to array
func pd_play_wav(id: int = 0):
	var sid = str("g", id)
	pd_playback.send_bang(sid)
	if loadSampleMode:
		load_sample_to_midi(id)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Start PD and listen for sends
	begin_playback()

	# load sample node info
	_load_UMAPjson()
	# instantiate sample nodes in scene
	_populate_scene()
	
	# init pd bang
	pd_bang()
	pd_init_bang()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
# recieve from pd sid from sid to signal end of playback.
func _on_receive_sampler_sid(dest: String,sid:String):
	# print("recieved sid from: ", sid)
	
	# call function on sampler id when done playing sound file.
	var id = int(sid.right(-1)) #strip 'g' and convert from string to int.
	# call done_playing on sample_node object from array of references to object
	sample_nodes[id]._done_playing()

func get_sample_node_array():
	return sample_nodes

# loads last played sample into variable	
func load_sample_to_midi(id:int):
	last_sample_node_id = id

# called from midi script to load last played sample ID into midiNoteMap array
func get_last_played_sample() -> int:
	return last_sample_node_id

func activate_sample_mode(modeState:bool):
	loadSampleMode = modeState
	print('Main scene loadSampleMode is: ', loadSampleMode)
