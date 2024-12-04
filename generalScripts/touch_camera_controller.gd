extends Camera2D

# finger bangers are born when touch input happens, but will be used for mouse, or other interation methods.
#however, these rely on collision physics and slow fps to a crawl when there are 2000+ sample nodes.
@export var fingerBanger_scene: PackedScene
# size multiplier for touchpoint scale, and future mouseclick scale
# ideally gui slider to set, or touch interation.
var touch_point_size_mult:float = 1.0

@export var zoom_speed: float = 0.1
@export var pan_speed: float = 1.0
@export var rotation_speed: float = 1.0

@export var can_pan: bool
@export var can_zoom: bool
@export var can_rotate: bool

@export var zoom_min: float = 0.1
@export var zoom_max: float = 50

var touch_points: Dictionary = {}
var touch_bangers: Dictionary = {}
var start_distance
var start_zoom
var start_angle
var current_angle

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_CTRL and !can_pan:
			can_pan = true
			can_zoom = true
			can_rotate = true

		if event.is_released() and event.keycode == KEY_CTRL and can_pan:
			can_pan = false
			can_zoom = false
			can_rotate = false		
		
	if event is InputEventScreenTouch:
		handle_touch(event)
	elif event is InputEventScreenDrag:
		handle_drag(event)
	
func handle_touch(event: InputEventScreenTouch):
	if event.pressed:
		touch_points[event.index] = event.position
		
		if !can_pan || !can_zoom || !can_rotate:
			var bang = fingerBanger_scene.instantiate()
			bang.scale_to_zoom(zoom, touch_point_size_mult)
			# Convert from position from screenspace to world space
			bang.position = make_input_local(event).position
			
			bang.id = event.index
			touch_bangers[event.index] = bang
			add_child(bang)
			
	else:
		touch_points.erase(event.index)
		if !can_pan || !can_zoom || !can_rotate && !touch_bangers.is_empty():
			touch_bangers[event.index].die()
		
	if touch_points.size() == 2:
		var touch_point_positions = touch_points.values()
		start_distance = touch_point_positions[0].distance_to(touch_point_positions[1])
		start_angle = get_angle(touch_point_positions[0], touch_point_positions[1])
		start_zoom = zoom
	
	elif touch_points.size() < 2:
		start_distance = 0
	

func handle_drag(event: InputEventScreenDrag):
	touch_points[event.index] = event.position
	
	if !can_pan || !can_zoom || !can_rotate:
		var touch_point_positions = touch_points.values()
		touch_bangers[event.index].position = make_input_local(event).position
	
	if touch_points.size() == 1:
		if can_pan:
			var pan_vector = event.relative.rotated(rotation) * pan_speed / zoom.x
			offset -= pan_vector
	
	elif touch_points.size() == 2:
		var touch_point_positions = touch_points.values()
		var current_distance = touch_point_positions[0].distance_to(touch_point_positions[1])
		var current_angle = get_angle(touch_point_positions[0], touch_point_positions[1])
		var zoom_factor = start_distance / current_distance
		
		if can_zoom:
			zoom = start_zoom / zoom_factor
			limit_zoom(zoom)
			
		if can_rotate:
			rotation -= (current_angle - start_angle) * rotation_speed
			start_angle = current_angle
			
func limit_zoom(new_zoom):
	if new_zoom.x < zoom_min:
		zoom.x = zoom_min
	if new_zoom.y < zoom_min:
		zoom.y = zoom_min
	if new_zoom.x > zoom_max:
		zoom.x = zoom_max
	if new_zoom.y > zoom_max:
		zoom.y = zoom_max

func get_angle(p1, p2):
	var delta = p2 - p1
	return fmod((atan2(delta.y, delta.x) + PI), (2 * PI))
