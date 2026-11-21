class_name Interactor
extends Node3D

## Base class for everything the player can interact with in the world.
## Subclasses decide what an interaction does (provide an ingredient,
## consume an ingredient, ...).

signal interacted(interactor: Interactor)

@export var interaction_prompt: String = "Interact"
@export var enabled: bool = true


## True when this interactor can be interacted with right now.
func can_interact() -> bool:
	return enabled and is_inside_tree()


## Called by whatever triggers interactions (raycast detector, input, ...).
func interact() -> void:
	if can_interact():
		interacted.emit(self)
