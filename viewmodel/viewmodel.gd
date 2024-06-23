extends Node3D

var x_spring_pos := 0.0
var x_spring_vel := 0.0

var y_spring_pos := 0.0
var y_spring_vel := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	x_spring_vel -= x_spring_pos * delta * 300.0
	x_spring_vel *= exp(-delta * 18.0)
	x_spring_pos += x_spring_vel * delta
	
	y_spring_vel -= y_spring_pos * delta * 200.0
	y_spring_vel *= exp(-delta * 24.0)
	y_spring_pos += y_spring_vel * delta
	
	$sway.rotation = Vector3(y_spring_pos * 0.2, x_spring_pos * 0.2, x_spring_pos * 0.1)

func _view_moved(x: float, y: float) -> void:
	x_spring_pos -= x
	y_spring_pos -= y
