extends Area2D

signal hit

@export var id: int
@export var sid: String
@export var path: String
@export var x: float
@export var y: float

var playing: bool
var main_scene: Node

# shader info for scale and colour
var shader: ShaderMaterial
var pulse_scale_amount: float = 0.2

var progress = 0.0 # 0-1 progress, when reset physics process ramps it up to 1
var target_color = Color(1, 0, 0) # Example target color
var speed =3 # Interpolation speed


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sid = str("g", id)
	# get ref to main scene for calling functions
	main_scene = self.get_parent()
	shader = $Sprite2D.material
	pass

func _on_area_entered(area: Area2D) -> void:
	main_scene.pd_play_wav(id)
	_start_playing()
	# if later messing with collisions properly, remember
	# Must be deferred as we can't change physics properties on a physics callback.
	#$CollisionShape2D.set_deferred("disabled", true)


func _on_area_exited(area: Area2D) -> void:
	pass
	
func _start_playing():
	#print("playing now")
	playing = true
	playing_animation()

func _done_playing():
	#print("finished now")
	playing = false
	stop_playing_animation()

# trying to use tweens but may be better to use shaders.
func playing_animation():
	shader.set_shader_parameter("amount", pulse_scale_amount)
	# colour changes
	target_color = Color(0, 0.6, 0.047)
	progress = 0
	
func stop_playing_animation():
	shader.set_shader_parameter("amount", 0)
	# colour changes
	# need check here for load sample node, if so, then keep it highlighted as last played sample
	target_color = Color(1,1,1)
	progress = 0



func _process(delta):

# Update progress over time
	if progress < 1.0:
		progress += speed * delta
		progress = min(progress, 1.0) # Clamp to 1.0

	# Set shader uniforms
	shader.set_shader_parameter("interpolation_progress", progress)
	shader.set_shader_parameter("new_colour", target_color)
	queue_redraw()
