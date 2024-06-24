extends RayCast3D

var hovered: Node = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	hovered = get_collider()
	if hovered and (not hovered.has_method("_interact") or (hovered.has_method("_interactable") and not hovered._interactable())):
		hovered = null


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if hovered != null:
		get_node("/root/UI/Game/crosshair").hide()
		get_node("/root/UI/Game/crosshair_interact").show()
	else:
		get_node("/root/UI/Game/crosshair").show()
		get_node("/root/UI/Game/crosshair_interact").hide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("use") and hovered != null:
		hovered._interact()
		get_viewport().set_input_as_handled()
