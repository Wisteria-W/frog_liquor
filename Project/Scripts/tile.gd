extends Node
class_name Tile

@export var interactor : Interactor

var is_selected : bool = false
@export var mesh : MeshInstance3D

func _process(delta):
	if is_selected:
		mesh.material_override.albedo_color = Color.RED
		if Input.is_action_just_pressed("Interaction") && interactor:
			interactor.interact()
	else:
		mesh.material_override.albedo_color = Color.WHITE
