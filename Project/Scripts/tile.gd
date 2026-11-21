extends Node
class_name Tile

var is_selected : bool = false
@export var mesh : MeshInstance3D

func _process(delta):
	if is_selected:
		mesh.material_override.albedo_color = Color.RED
	else:
		mesh.material_override.albedo_color = Color.WHITE
