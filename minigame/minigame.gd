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

const CELL_RADIUS = 50.0
const BETWEEN_CELLS = CELL_RADIUS * sqrt(3) * 0.5

signal complete

@onready
var glyph_scene: PackedScene = preload("res://minigame/glyph.tscn")

@onready
var slot_scene: PackedScene = preload("res://minigame/slot.tscn")

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
var drag_direction := 0
var drag_line: Array[Vector2i] = []
var hover_pos := Vector2i(-999, -999)

class Cell:
	@export
	var q: int = 0
	var r: int = 0
	var type: int = 0

@export_multiline
var grid: String = ""

var target := ""

const GRID_SIZE = 20

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var lines := grid.split("\n", false)
	var config := lines[0].split(" ", false)
	lines.remove_at(0)

	var start_q := int(config[0])
	var start_r := int(config[1])
	target = config[2]

	var half := len(target) / 2

	for y in range(-half, -half + len(target)):
		var slot = slot_scene.instantiate()
		slot.transform.origin = hex_to_pos(Vector2i(GRID_SIZE / 2, GRID_SIZE / 2 + y))
		add_child(slot)

	for x in range(0, GRID_SIZE):
		board.push_back([])
		for y in range(0, GRID_SIZE):
			board[x].push_back(null)

	var center_line := len(lines) / 2
	var width := 0
	for line in lines:
		width = max(width, (len(line) + 1) / 2)

	var center_x := width / 2
	
	var first_stagger := lines[0].begins_with(" ")

	for i in range(len(lines)):
		var line := lines[i]
		if line == "":
			continue

		var stagger := first_stagger
		if i % 2 == 0:
			stagger = not stagger

		var x := -center_x
		for cell in line:
			if cell == " ":
				continue

			var r := i / 2 - center_line / 2
			var q := x

			x += 1

			if cell == "#":
				continue

			if stagger:
				q -= 1
				
				if first_stagger:
					r += 1

			q += x
			r -= x

			var glyph = glyph_scene.instantiate()
			glyph.kind = int(cell)
			add_child(glyph)
			set_cell(Vector2i(q + GRID_SIZE / 2 + start_q, r + GRID_SIZE / 2 + start_r), glyph)

	for x in range(len(board)):
		for y in range(len(board[x])):
			var cell: Sprite2D = board[x][y]
			if cell == null: continue

			cell._warp_to(hex_to_pos(Vector2i(x, y)))


# Called when the node enters the scene tree for the fik#hex-to-pixel
func hex_to_pos(pos: Vector2i) -> Vector2:
	pos = Vector2i(pos.x - GRID_SIZE / 2, pos.y - GRID_SIZE / 2)
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

	return Vector2i(q_int + GRID_SIZE / 2, r_int + GRID_SIZE / 2)

func get_cell(pos: Vector2i) -> Sprite2D:
	if pos.x < 0 or pos.x >= len(board) \
		or pos.y < 0 or pos.y >= len(board[pos.x]):

		return null

	return board[pos.x][pos.y]

func set_cell(pos: Vector2i, cell: Sprite2D) -> void:
	board[pos.x][pos.y] = cell

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse := get_global_mouse_position()
	mouse = to_local(mouse)

	var new_hover_pos := pos_to_hex(mouse)
	if drag_state != DragState.NONE:
		new_hover_pos = Vector2i(-1, -1)
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
		cell._spring_to(hex_to_pos(dragged_cell) + direction * (shift_amt / dir_len))

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
		var direction = direction_pixels[drag_direction]
		var along := direction.dot(mouse - drag_start)

		var skip_index := -1
		var warp_by := Vector2()

		if along < -BETWEEN_CELLS:
			skip_index = len(drag_line) - 1
			drag_start -= direction * BETWEEN_CELLS * 2
			warp_by = direction * BETWEEN_CELLS * 2 * len(drag_line)
			along += BETWEEN_CELLS * 2
			
			var prev := get_cell(drag_line[0])
			for i in range(len(drag_line) - 1, -1, -1):
				var pos := drag_line[i]
				var next := get_cell(pos)
				set_cell(pos, prev)

				prev = next

		if along > BETWEEN_CELLS:
			skip_index = 0
			drag_start += direction * BETWEEN_CELLS * 2
			warp_by = -direction * BETWEEN_CELLS * 2 * len(drag_line)
			along -= BETWEEN_CELLS * 2
			
			var prev := get_cell(drag_line[-1])
			for pos in drag_line:
				var next := get_cell(pos)
				set_cell(pos, prev)

				prev = next

		for i in range(len(drag_line)):
			var pos := drag_line[i]
			var cell := get_cell(pos)
			if i == skip_index:
				cell._warp_by(warp_by)
			cell._warp_to(hex_to_pos(pos) + direction * along)

func drag_initiate(pos: Vector2i):
	var cell := get_cell(pos)
	if cell == null: return

	cell._awaiting_direction()

	dragged_cell = pos
	drag_state = DragState.WAITING_FOR_DIRECTION

func drag_commit():
	if drag_state == DragState.WAITING_FOR_DIRECTION:
		get_cell(dragged_cell)._idle()
		get_cell(dragged_cell)._spring_to(hex_to_pos(dragged_cell))
	elif drag_state == DragState.DRAGGED:
		for cell in drag_line:
			get_cell(cell)._idle()
			get_cell(cell)._spring_to(hex_to_pos(cell))

	var half := len(target) / 2
	
	var i := 0
	var done := true

	for y in range(-half, -half + len(target)):
		var here: int = get_cell(Vector2i(GRID_SIZE / 2, GRID_SIZE / 2 + y)).kind
		if here != int(target[i]):
			done = false
			break
		
		i += 1

	if done:
		complete.emit()

	drag_state = DragState.NONE

func drag_set_direction(direction):
	drag_state = DragState.DRAGGED
	drag_direction = direction

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
