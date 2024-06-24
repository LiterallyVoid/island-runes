extends Control

@onready
var speech := $Speech

@onready
var speaker := $Speaker

@onready
var animator := $AnimationPlayer

var lines := PackedStringArray()
var cursor := 0

const space = " \r\n\t"

@export
var advance_allowed := true

var completed: Dictionary = {}
var current := ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	$"../puzzle container".cancel.connect(cancel)
	$"../puzzle container".complete.connect(advance)

	play("intro")

func cancel() -> void:
	lines = []
	cursor = 0
	current = ""
	advance()

func play(name: String) -> void:
	current = name

	var file := FileAccess.open("res://dialogues/" + name + ".txt", FileAccess.READ)
	lines = file.get_as_text(true).split("\n")
	cursor = 0

	advance()

func speaker_reset() -> void:
	speaker.text = "Unspecified"
	speaker.modulate = Color(1, 1, 1, 1)

func speaker_me() -> void:
	speaker.text = "You"

func speaker_other() -> void:
	speaker.text = "Maya"
	speaker.modulate = Color("#FDAFC7")

func speaker_radio() -> void:
	speaker.text = "XR-65Y1 All-In-One Solo Radio"
	speaker.modulate = Color("#D4E9FF")

func command_radio_up() -> bool:
	$"../player/look_horizontal/look_vertical/viewmodel/sway/communicator_animation".play("raise")
	return false

func command_radio_down() -> bool:
	$"../player/look_horizontal/look_vertical/viewmodel/sway/communicator_animation".play("lower")
	return false

func command_activate(name: String) -> bool:
	var any := false
	for node in $"../world".find_children(name):
		any = true
		node._activate()
	
	if not any:
		printerr("@activate no nodes: ", name)

	return false

func command_puzzle(name: String) -> bool:
	advance_allowed = false
	$"../puzzle container"._activate(name)
	return true

func execute_one() -> bool:
	visible = false

	if cursor == len(lines):
		completed[current] = true
		return true

	var line := lines[cursor].lstrip(space).rstrip(space)
	cursor += 1
	
	if line == "":
		return false

	if line.begins_with("@"):
		var command := line.substr(1)
		if command.contains(" "):
			var split := command.split(" ")
			command = split[0]
			var arg := split[1]
			return call("command_" + command, arg)
		else:
			return call("command_" + command)

	if line.begins_with("["):
		var speaker_end = line.find("]", 1)
		var speaker_id = line.substr(1, speaker_end - 1)
		var text = line.substr(speaker_end + 1).lstrip(space).rstrip(space)

		speaker_reset()
		call("speaker_" + speaker_id)

		speech.text = text
		
		animator.stop()
		animator.play("show")
		animator.queue("tick")

		visible = true

		return true

	print("Could not parse:", line)

	return true

func advance() -> void:
	while not execute_one():
		continue

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if not visible: return

	if event.is_action_pressed("use"):
		if advance_allowed: advance()
		get_viewport().set_input_as_handled()
