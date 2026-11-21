class_name PotionConsumer
extends Interactor

## An interactor that consumes a potion handed to it
## (the player drinking, a customer, a composter, ...).

signal potion_consumed(potion: Potion, consumer: PotionConsumer)

## -1 = accepts unlimited potions.
@export var max_potions: int = -1

var consumed: Array[Potion] = []
var _item_cube: MeshInstance3D


func _ready() -> void:
	_item_cube = _create_item_cube(Vector3(0, 0.55, 0), Vector3(0.18, 0.22, 0.18))
	_item_cube.visible = false


func can_interact() -> bool:
	return super.can_interact() and (max_potions < 0 or consumed.size() < max_potions)


## Feeds one potion into this consumer.
## Returns false (and consumes nothing) when the potion is rejected.
func consume_potion(potion: Potion) -> bool:
	if potion == null or not can_interact():
		return false
	if not _consume(potion):
		return false
	consumed.append(potion)
	_apply_item_visual(_item_cube, potion)
	potion_consumed.emit(potion, self)
	return true


## Override to define what consuming means (drink, pour, store, ...).
## Return false to reject the potion (nothing is recorded or emitted).
func _consume(potion: Potion) -> bool:
	return true


## The player hands over the held potion; with empty hands the consumer
## gets a plain interaction instead.
func interact_with(player: PlayerInteractor) -> void:
	if player.potion_holder.is_empty():
		interact()
	else:
		player.potion_holder.transfer_to(self)
