extends Control

@onready
var game = $Game

@onready
var menu = $menu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_pause()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_pause()
		get_viewport().set_input_as_handled()

func _notification(what):
	if not visible: return
	if what == MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT:
		_pause()

func _pause(show_menu: bool = true) -> void:
	get_tree().paused = true
	if show_menu:
		menu.show()
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _resume() -> void:
	get_tree().paused = false
	menu.hide()
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
