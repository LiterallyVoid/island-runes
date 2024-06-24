extends Sprite2D

@export
var kind := 0

@onready
var board = get_parent()

var hovered := false

@onready
var target_position := position
var velocity := Vector2()

var target_scale := 0.3
var current_scale := 0.3
var scale_velocity := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	region_rect.position = Vector2((kind % 4) * 256, int(kind / 4.0) * 256)

	_set_hovered(false)
	_idle()

func _warp_to(pos: Vector2) -> void:
	position = pos
	target_position = pos
	velocity = Vector2()

func _warp_by(offset: Vector2) -> void:
	position += offset
	target_position += offset

func _spring_to(pos: Vector2) -> void:
	target_position = pos

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	velocity += (target_position - position) * delta * 350.0
	velocity *= exp(-delta * 35.0)

	position += velocity * delta

	scale_velocity += (target_scale - current_scale) * delta * 600.0
	scale_velocity *= exp(-delta * 40.0)
	current_scale += scale_velocity * delta
	scale = Vector2(current_scale, current_scale)

func _set_hovered(new_hovered: bool) -> void:
	hovered = new_hovered
	target_scale = 0.35 if hovered else 0.3
	modulate.a = 1.0 if hovered else 0.9

func _idle() -> void:
	modulate = Color("#FFFFFF")

func _awaiting_direction() -> void:
	modulate = Color("#FE941E")

func _in_line() -> void:
	modulate = Color("#FE941E")
