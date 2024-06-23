extends Sprite2D

@export
var kind := 0

@onready
var board = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	region_rect.position = Vector2((kind % 4) * 256, int(kind / 4.0) * 256)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
