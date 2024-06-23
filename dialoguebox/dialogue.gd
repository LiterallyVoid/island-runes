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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false

	play("intro")

func play(name: String) -> void:
	var file := FileAccess.open("res://dialogues/" + name + ".txt", FileAccess.READ)
	lines = file.get_as_text().split("\n")
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

func command_radio_up():
	$"../player/look_horizontal/look_vertical/viewmodel/sway/communicator_animation".play("raise")

func command_radio_down():
	$"../player/look_horizontal/look_vertical/viewmodel/sway/communicator_animation".play("lower")

func command_raise():
	$"../world/open-world/island 2"._activate()

func execute_one() -> bool:
	if cursor == len(lines):
		visible = false
		return true

	var line := lines[cursor].lstrip(space).rstrip(space)
	cursor += 1
	
	if line == "":
		return false

	if line.begins_with("@"):
		var command := line.substr(1)
		call("command_" + command)
		return false
	
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
	if event.is_action_pressed("use") and advance_allowed:
		advance()
		get_viewport().set_input_as_handled()
