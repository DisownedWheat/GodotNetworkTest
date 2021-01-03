extends KinematicBody

var movemap = {
	'left': false,
	'right': false,
	'up': false,
	'down': false
}

func _physics_process(delta):
	var velocity = Vector3()
	if not is_on_floor():
		velocity.y -= 100
	if movemap.left:
		velocity.x -= 100
	if movemap.right:
		velocity.x += 100
	if movemap.up:
		velocity.z -= 100
	if movemap.down:
		velocity.z += 100
	move_and_slide(velocity * delta, Vector3.UP)

func _input(event):
	if event.is_action_pressed("ui_left"):
		rpc("move", 'left', true)
	if event.is_action_pressed("ui_right"):
		rpc("move", "right", true)
	if event.is_action_pressed("ui_up"):
		rpc("move", 'up', true)
	if event.is_action_pressed("ui_down"):
		rpc("move", "down", true)
	
	if event.is_action_released("ui_left"):
		rpc("move", 'left', false)
	if event.is_action_released("ui_right"):
		rpc("move", "right", false)
	if event.is_action_released("ui_up"):
		rpc("move", 'up', false)
	if event.is_action_released("ui_down"):
		rpc("move", "down", false)

remotesync func move(key, value):
	movemap[key] = value

remote func position_is_fine(value):
	if not get_tree().is_network_server():
		return
	global_transform.origin = value

remote func reset_translation(value):
	print(global_transform.origin.distance_to(value))
	if global_transform.origin.distance_to(value) < 0.5:
		rpc("position_is_fine", value)
		return
	global_transform.origin = value

func _on_Timer_timeout():
	if not get_tree().is_network_server():
		return
	rpc("reset_translation", global_transform.origin)
