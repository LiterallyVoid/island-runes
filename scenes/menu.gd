extends ColorRect

@onready
var music = $"../music"

@onready
var island_cue = $"../island_cue"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_on_music_volume_changed($VBoxContainer/HSlider.value)
	_on_sensitivity_changed($VBoxContainer/HSlider2.value)


func _input(event: InputEvent) -> void:
	if not visible: return
	if event.is_action_pressed("pause") and not OS.has_feature('web'):
		find_parent("UI")._resume()
		get_viewport().set_input_as_handled()

func _on_music_volume_changed(value: float) -> void:
	music.volume_db = (log(value) - 1) * 10 - 3
	island_cue.volume_db = (log(value) - 1) * 10
	pass # Replace with function body.


func _on_sensitivity_changed(value: float) -> void:
	get_node("../Game/player").sensitivity = pow(value, 2.0) * 0.03
	pass # Replace with function body.
