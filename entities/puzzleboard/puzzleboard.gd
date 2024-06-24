extends StaticBody3D

@export
var dialogue := ""

@export
var active := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if active: _activate()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _activate():
	$"board/inactive".hide()
	active = true							

func solved():
	return (dialogue in get_node("/root/UI/Game/Dialogue").completed)

func _interactable():
	return active and not solved()

func _interact():
	if solved(): return
	get_node("/root/UI/Game/Dialogue").play(dialogue)
