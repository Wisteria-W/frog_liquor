extends Node3D
class_name Tile

@export var interactor : Interactor

var is_selected : bool = false
@export var mesh : MeshInstance3D

func _process(delta):
	if not mesh or not mesh.material_override:
		return
	if is_selected:
		mesh.material_override.albedo_color = Color.RED
	else:
		mesh.material_override.albedo_color = Color.WHITE
