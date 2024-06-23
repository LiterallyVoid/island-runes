extends Node2D
class_name MinigameBoard

const CONFIRM_DISTANCE = 50.0

# directions: 0 = up, 1 = up-right, 2 = down-right

const directions: Array[Vector2i] = [
	Vector2i(0, -1),
	Vector2i(1, -1),
	Vector2i(1, 0),
]

const direction_pixels: Array[Vector2] = [
	Vector2(0, -1),
	Vector2(sqrt(3) / 2, -0.5),
	Vector2(sqrt(3) / 2, 0.5),
]

const CELL_RADIUS = 60.0

@onready
var glyph_scene: PackedScene = preload("res://minigame/glyph.tscn")

# Array[Array[Sprite2D]]
var board: Array[Array] = []

enum DragState {
	NONE,
	WAITING_FOR_DIRECTION,
	DRAGGED,
}

var dragged_cell := Vector2i()
var drag_state := DragState.NONE
var drag_start := Vector2()
var drag_line: Array[Vector2i] = []
var hover_pos := Vector2i(-999, -999)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for x in range(0, 10):
		board.push_back([])
		for y in range(0, 10):
			var glyph = glyph_scene.instantiate()
			glyph.transform.origin = hex_to_pos(Vector2i(x, y))
			glyph.kind = randi_range(0, 7)
			board[x].push_back(glyph)
			add_child(glyph)

# https://www.redblobgames.com/grids/hexagons/#hex-to-pixel
func hex_to_pos(pos: Vector2i) -> Vector2:
	return Vector2(
		CELL_RADIUS * (3./2 * pos.x),
		CELL_RADIUS * (sqrt(3)/2 * pos.x + sqrt(3) * pos.y),
	)

# https://www.redblobgames.com/grids/hexagons/#pixel-to-hex
func pos_to_hex(vec: Vector2) -> Vector2i:
	var q := ( 2./3 * vec.x) / CELL_RADIUS
	var r := (-1./3 * vec.x + sqrt(3)/3 * vec.y) / CELL_RADIUS

	var s := -q - r

	var q_int: int = round(q)
	var r_int: int = round(r)
	var s_int: int = round(s)

	var q_diff = abs(q - q_int)
	var r_diff = abs(r - r_int)
	var s_diff = abs(s - s_int)

	if q_diff > r_diff and q_diff > s_diff:
		q_int = -r_int - s_int
	elif r_diff > s_diff:
		r_int = -q_int - s_int
	#else:
		#s_int = -q_int - r_int

	return Vector2i(q_int, r_int)

func get_cell(pos: Vector2i) -> Sprite2D:
	if pos.x < 0 or pos.x >= len(board) \
		or pos.y < 0 or pos.y >= len(board[pos.x]):

		return null

	return board[pos.x][pos.y]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse := get_global_mouse_position()
	mouse = to_local(mouse)

	var new_hover_pos := pos_to_hex(mouse)
	if new_hover_pos != hover_pos:
		var cell := get_cell(hover_pos)
		if cell != null:
			cell._set_hovered(false)

		cell = get_cell(new_hover_pos)
		if cell != null:
			cell._set_hovered(true)

		hover_pos = new_hover_pos

	if drag_state == DragState.WAITING_FOR_DIRECTION:
		var direction := mouse - drag_start
		var dir_len := direction.length() + 0.01
		var shift_amt := pow(dir_len / CONFIRM_DISTANCE, 0.5) * CONFIRM_DISTANCE * 0.5

		var cell := get_cell(dragged_cell)
		cell.position = hex_to_pos(dragged_cell) + direction * (shift_amt / dir_len)

		if dir_len > CONFIRM_DISTANCE:
			var dot_0: float = abs(direction.dot(direction_pixels[0]))
			var dot_1: float = abs(direction.dot(direction_pixels[1]))
			var dot_2: float = abs(direction.dot(direction_pixels[2]))

			if dot_0 > dot_1 and dot_0 > dot_2:
				drag_set_direction(0)
			elif dot_1 > dot_2:
				drag_set_direction(1)
			else:
				drag_set_direction(2)
	elif drag_state == DragState.DRAGGED:
		for pos in drag_line:
			var cell := get_cell(pos)
			cell.position = hex_to_pos(pos)

func drag_initiate(pos: Vector2i):
	var cell := get_cell(pos)
	if cell == null: return

	cell._awaiting_direction()

	dragged_cell = pos
	drag_state = DragState.WAITING_FOR_DIRECTION

func drag_commit():
	if drag_state == DragState.WAITING_FOR_DIRECTION:
		get_cell(dragged_cell)._idle()
		get_cell(dragged_cell).position = hex_to_pos(dragged_cell)
	elif drag_state == DragState.DRAGGED:
		for cell in drag_line:
			get_cell(cell)._idle()
			get_cell(cell).position = hex_to_pos(cell)

	drag_state = DragState.NONE

func drag_set_direction(direction):
	drag_state = DragState.DRAGGED

	drag_line = []

	for i in range(1, 10):
		var pos := dragged_cell - directions[direction] * i
		if get_cell(pos) == null:
			break

		drag_line.push_front(pos)

	drag_line.push_back(dragged_cell)

	for i in range(1, 10):
		var pos := dragged_cell + directions[direction] * i
		if get_cell(pos) == null:
			break
		
		drag_line.push_back(pos)
	
	for pos in drag_line:
		get_cell(pos)._in_line()

func _unhandled_input(event: InputEvent) -> void:
	event = make_input_local(event)

	if event is InputEventMouseButton \
		and event.button_index == MOUSE_BUTTON_LEFT:

		if event.is_pressed() and drag_state == DragState.NONE:
			get_viewport().set_input_as_handled()
			drag_start = event.position
			drag_initiate(pos_to_hex(event.position))

		else:
			drag_commit()
