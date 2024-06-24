extends Control

signal complete
signal cancel

const minigame: PackedScene = preload("res://minigame/minigame.tscn")
var game: Node2D = null

@onready
var panel_center = $"Panel/panel center"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()

func _activate(name: String) -> void:
	find_parent("UI")._pause(false)
	if game != null:
		game.queue_free()

	game = minigame.instantiate()
	game.grid = FileAccess.open("res://puzzles/" + name + ".txt", FileAccess.READ).get_as_text(true)
	panel_center.add_child(game)
	
	game.complete.connect(_on_complete)
	show()

func _on_complete() -> void:
	hide()
	game.queue_free()
	find_parent("UI")._resume()
	complete.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if not visible: return

	if event.is_action_pressed("pause"):
		hide()
		game.queue_free()
		find_parent("UI")._resume()

		cancel.emit()
		get_viewport().set_input_as_handled()
		
		if OS.has_feature('web'):
			find_parent("UI")._pause()
