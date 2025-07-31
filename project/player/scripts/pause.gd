extends Control

var paused := false

func _process(delta):
	if Input.is_action_just_pressed("escape"):
		paused = !paused
	
	visible = paused
	get_tree().paused = paused
	if paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
