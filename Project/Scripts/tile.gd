extends Node
class_name Tile

@export var interactor : Interactor

var is_selected : bool = false
@export var mesh : MeshInstance3D

func _process(delta):
	if is_selected:
		mesh.visible = true
	else:
		mesh.visible = false

func _input(event):
	if event.is_action_pressed("Interaction") && is_selected:
		#print("Interact!")
		if interactor:
			interactor.interact()
