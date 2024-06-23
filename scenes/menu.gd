extends ColorRect

@onready
var music = $"../music"

@onready
var island_cue = $"../island_cue"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_on_music_volume_changed($VBoxContainer/HSlider.value)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		find_parent("UI")._resume()
		get_viewport().set_input_as_handled()

func _on_music_volume_changed(value: float) -> void:
	music.volume_db = (log(value) - 1) * 10 - 3
	island_cue.volume_db = (log(value) - 1) * 10
	pass # Replace with function body.
