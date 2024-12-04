extends Node
# ref to main scene to send data to pd
@onready var main_scene = self.get_parent()

# make midi controller 'interface'
var numMidiKeys = 16
var midiNoteMap: Array[int]
@export var loadSampleMode: bool = false

var sampleNodes

# array for unique randomisation of midimap
var shuffle_bag = []

func _ready():
	# simplest 0-16 notemap
	for i in numMidiKeys:
		midiNoteMap.append(i)
	# init shufflebag
	randomise_shufflebag()
	
	# store sample nodes references
	sampleNodes = main_scene.get_sample_node_array()
	
	# open midi connections, letting everthing go through, no parsing yet
	OS.open_midi_inputs()
	print(OS.get_connected_midi_inputs())

func _input(input_event):
	# keyboard events to do before checking if midi
	if Input.is_action_pressed("randomMidi"):
		randomise_midimap()
	
	if Input.is_action_pressed("loadSampleModeToggle"):
		loadSampleMode = !loadSampleMode
		main_scene.activate_sample_mode(loadSampleMode)
		print("load sample mode is: ", loadSampleMode)	
	
	
	if input_event is InputEventMIDI:
		# load sample mode
		if loadSampleMode:
			if input_event.message == 9:
				#print("noteOn: ", input_event.pitch, " Vel: ", input_event.velocity)
				load_sample_to_index(input_event.pitch - 1)
		else:	
			# note on event
			if input_event.message == 9:
				#print("noteOn: ", input_event.pitch, " Vel: ", input_event.velocity)
				play_from_midimap(input_event.pitch - 1)
			# note off 
			if input_event.message == 8:
				print("noteOff: ", input_event.pitch, " Vel: ", input_event.velocity)
		

	

# call function from main scene to tell pd to play sample
func play_from_midimap(midiIn:int):
	main_scene.pd_play_wav(midiNoteMap[midiIn])
	sampleNodes[midiNoteMap[midiIn]]._start_playing()


# make a shufflebag from number of samples
func randomise_shufflebag():
	var sna = main_scene.get_sample_node_array()
	for i in sna.size():
		shuffle_bag.append(i)
	shuffle_bag.shuffle()
	print("shuffleBagggg", shuffle_bag)
	
# randomise the midimap using unique index pulled from sample_nodes
func randomise_midimap():
	for i in midiNoteMap.size():
		if shuffle_bag.is_empty():
			randomise_shufflebag()
		midiNoteMap[i] = shuffle_bag.pop_back()
	print(midiNoteMap)
	return

func load_sample_to_index(midiNote:int):
	var sampIndex = main_scene.get_last_played_sample()
	midiNoteMap[midiNote] = sampIndex
	print('load sample mode is on and just entered sample Node id: ', sampIndex)
	return

func _print_midi_info(midi_event):
	print(midi_event)
	print("Channel ", midi_event.channel)
	print("Message ", midi_event.message)
	print("Pitch ", midi_event.pitch)
	print("Velocity ", midi_event.velocity)
	print("Instrument ", midi_event.instrument)
	print("Pressure ", midi_event.pressure)
	print("Controller number: ", midi_event.controller_number)
	print("Controller value: ", midi_event.controller_value)
