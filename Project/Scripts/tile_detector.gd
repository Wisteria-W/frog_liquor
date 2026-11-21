extends Node3D

@export var raycast : RayCast3D
var selected_tile : Node3D

func _physics_process(delta):
	#var input_dir : Vector3
	var input_dir = Input.get_vector("Left", "Right", "Up", "Down").rotated(deg_to_rad(45))
	#if Input.is_action_pressed("Left"):
		#input_dir = Vector3.LEFT
	#elif Input.is_action_pressed("Right"):
		#input_dir = Vector3.RIGHT
	#elif Input.is_action_pressed("Up"):
		#input_dir = Vector3.UP
	#elif Input.is_action_pressed("Down"):
		#input_dir = Vector3.DOWN
	if global_position != global_position -Vector3(input_dir.x, 0, input_dir.y):
		look_at(global_position -Vector3(input_dir.x, 0, input_dir.y), Vector3.UP)
	
	raycast.force_raycast_update()
	if raycast.is_colliding():
		print("Collided")
		if raycast.get_collider().get_parent() != selected_tile && selected_tile:
			selected_tile.is_selected = false
		selected_tile = raycast.get_collider().get_parent()
		selected_tile.is_selected = true
	elif selected_tile:
		selected_tile.is_selected = false
