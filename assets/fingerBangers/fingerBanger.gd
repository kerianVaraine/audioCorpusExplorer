extends Area2D

@export var id: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func die():
	#print("I'm freeeee!")
	queue_free()
	
func scale_to_zoom(scale:Vector2, mult:float=1):
	var scaled = Vector2(5,5) / scale * mult
	$CollisionShape2D.set_scale(scaled)
	$Sprite2D.set_scale(scaled)
