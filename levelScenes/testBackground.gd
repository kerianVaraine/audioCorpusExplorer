extends CanvasLayer

# sample_points[index]["point"] == [x,y]
# sample_points[index]["path"] == PATH
var sample_points = {}

func _load_UMAPjson() -> void:
	var json_as_test = FileAccess.get_file_as_string("res://imports/utt-small-2dUMAP.json")
	sample_points = JSON.parse_string(json_as_test)

func _populate_scene() -> void:
	var point_scene = load("res://assets/points/pointTest.tscn")
	var screen_size = get_viewport().get_visible_rect().size
	
	for i in range(0,10):
		var point = point_scene.instance()
		point.position.x = sample_points[i]["point"][0]
		point.position.y = sample_points[i]["point"][1]
		add_child(point)
		
	return

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	_load_UMAPjson()
	_populate_scene()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
