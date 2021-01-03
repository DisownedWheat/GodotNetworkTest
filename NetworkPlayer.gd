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

remotesync func move(key, value):
	movemap[key] = value
	
remote func position_is_fine(value):
	if not get_tree().is_network_server():
		return
	global_transform.origin = value

remote func reset_translation(value):
	print(global_transform.origin.distance_to(value))
	global_transform.origin = value

func _on_Timer_timeout():
	if not get_tree().is_network_server():
		return
	rpc('reset_translation', global_transform.origin)
