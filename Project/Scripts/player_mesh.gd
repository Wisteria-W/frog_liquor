extends Node3D

@export var player_mesh : Node3D

enum VerticalDirections {
	UP,
	DOWN
}
var curent_vertical_dir : VerticalDirections = VerticalDirections.UP

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var input_dir
	
	if Input.is_action_pressed("Up"):
		curent_vertical_dir = VerticalDirections.UP
	elif Input.is_action_pressed("Down"):
		curent_vertical_dir = VerticalDirections.DOWN
	
	if Input.is_action_pressed("Left"):
		if curent_vertical_dir == VerticalDirections.UP:
			player_mesh.rotation.y = deg_to_rad(-180)
		else:
			player_mesh.rotation.y = deg_to_rad(-90)
	elif Input.is_action_pressed("Right"):
		if curent_vertical_dir == VerticalDirections.UP:
			player_mesh.rotation.y = deg_to_rad(90)
		else:
			player_mesh.rotation.y = deg_to_rad(0)
	pass
