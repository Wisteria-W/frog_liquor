class_name Interactor
extends Node3D

## Base class for everything the player can interact with in the world.
## Subclasses decide what an interaction does (provide an ingredient,
## consume an ingredient, ...) — both for plain interact() calls and for
## player interactions via interact_with(player).

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


## What happens when the player interacts with this. The player passes
## itself so subclasses can move items between its holders and themselves.
## The default is a plain interaction; each interactor type overrides this,
## so the player needs no type checks of its own.
func interact_with(player: PlayerInteractor) -> void:
	interact()
