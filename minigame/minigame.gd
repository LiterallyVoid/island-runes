extends Node2D
class_name MinigameBoard

@onready
var glyph_scene = preload("res://minigame/glyph.tscn")

# Array[Array[Sprite2D]]
var board: Array[Array] = []

enum DragState {
	NONE,
	WAITING_FOR_DIRECTION,
	DRAGGED,
}

var dragged_glyph: Sprite2D = null
var drag_state: DragState = DragState.NONE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for x in range(0, 10):
		board.push_back([])
		for y in range(0, 10):
			var glyph = glyph_scene.instantiate()
			glyph.transform.origin = Vector2(x * 128, y * 128)
			glyph.kind = randi_range(0, 7)
			board[x].push_back(glyph)
			add_child(glyph)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func drag_commit():
	dragged_glyph = null
	drag_state = DragState.NONE

func _initiate_drag(glyph: Sprite2D):
	dragged_glyph = glyph
	drag_state = DragState.NONE

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and \
		event.button_index == MOUSE_BUTTON_LEFT and \
		event.is_released():

		drag_commit()
