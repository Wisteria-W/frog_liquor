extends Node3D

@export var raycast : RayCast3D
var selected_tile : Node3D
enum VerticalDirections {
	UP,
	DOWN
}
var curent_vertical_dir : VerticalDirections = VerticalDirections.UP

func _physics_process(delta):
	var input_dir : Vector3
	#var input_dir = Input.get_vector("Left", "Right", "Up", "Down").rotated(deg_to_rad(45))
	if Input.is_action_pressed("Up"):
		curent_vertical_dir = VerticalDirections.UP
	elif Input.is_action_pressed("Down"):
		curent_vertical_dir = VerticalDirections.DOWN
	
	if Input.is_action_pressed("Left"):
		if curent_vertical_dir == VerticalDirections.UP:
			input_dir = Vector3(0, 0, -1)
		else:
			input_dir = Vector3(-1, 0, 0)
	elif Input.is_action_pressed("Right"):
		if curent_vertical_dir == VerticalDirections.UP:
			input_dir = Vector3(1, 0, 0)
		else:
			input_dir = Vector3(0, 0, 1)

	if global_position != global_position -input_dir:
		look_at(global_position -input_dir, Vector3.UP)
	
	raycast.force_raycast_update()
	if raycast.is_colliding():
		print("Collided")
		if raycast.get_collider().get_parent() != selected_tile && selected_tile:
			selected_tile.is_selected = false
		selected_tile = raycast.get_collider().get_parent()
		selected_tile.is_selected = true
	elif selected_tile:
		selected_tile.is_selected = false
