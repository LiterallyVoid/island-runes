extends Sprite2D

@export
var kind := 0

@onready
var board = get_parent()

var hovered := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	region_rect.position = Vector2((kind % 4) * 256, int(kind / 4.0) * 256)

	_set_hovered(false)
	_idle()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _set_hovered(new_hovered: bool) -> void:
	hovered = new_hovered
	self_modulate.a = 1.0 if hovered else 0.5

func _idle() -> void:
	modulate = Color("#888888")

func _awaiting_direction() -> void:
	modulate = Color("#FFFFFF")

func _in_line() -> void:
	modulate = Color("#FF0000")
