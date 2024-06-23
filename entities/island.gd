extends MeshInstance3D

@onready
var origin = transform.origin

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	transform.origin = origin - Vector3(0, 35, 0)


var _dbg_time := -1.0
var time := -1.0

func _process(delta: float) -> void:
	if _dbg_time > -0.5:
		_dbg_time += delta
		if _dbg_time > 10:
			_dbg_time = -99999999999.0
			_activate()
	
	if time < -0.5:
		return

	time += delta
	if time > 5:
		transform.origin = origin
		time = -1.0
	else:
		var down := remap(time, 0, 5, 1, 0)
		down = pow(down, 1.5)
		down *= 35.0

		transform.origin = origin - Vector3(0, down, 0)

func _activate() -> void:
	time = 0.0
	$"/root/UI/island_cue".play()
	print("ISLAND POP!")
