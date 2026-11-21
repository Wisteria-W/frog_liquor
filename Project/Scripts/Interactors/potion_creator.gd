class_name PotionCreator
extends Interactor

## An interactor that creates a potion when interacted with
## (a brewing cauldron, a potion shelf, an NPC handing one over, ...).
## The chain is: PotionCreator creates -> PotionHolder holds
## -> PotionConsumer consumes.

signal potion_created(potion: Potion, creator: PotionCreator)

## The potion handed out when create_potion() is not overridden.
@export var potion: Potion
@export var single_use: bool = false

var _used := false
var _created: Potion


func can_interact() -> bool:
	return super.can_interact() and not (single_use and _used)


func interact() -> void:
	if not can_interact():
		return
	super.interact()
	if single_use:
		_used = true
	_created = create_potion()
	potion_created.emit(_created, self)


## The potion this creator produces. Override to create potions
## dynamically (e.g. brew from the PotionService slots); the result is
## cached per interaction so created_potion() never creates twice.
func create_potion() -> Potion:
	return potion


## The potion created by the last interact() call. Null when none.
func created_potion() -> Potion:
	return _created


## The player picks the created potion up into its potion holder.
func interact_with(player: PlayerInteractor) -> void:
	player.potion_holder.take_from(self)
