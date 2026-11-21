class_name IngredientConsumer
extends Interactor

## An interactor that consumes an ingredient handed to it
## (the mixer, a cauldron, a composter, ...).

signal ingredient_consumed(ingredient: Ingredient, consumer: IngredientConsumer)

## -1 = accepts unlimited ingredients.
@export var max_ingredients: int = -1

var consumed: Array[Ingredient] = []


func can_interact() -> bool:
	return super.can_interact() and (max_ingredients < 0 or consumed.size() < max_ingredients)


## Feeds one ingredient into this consumer.
## Returns false (and consumes nothing) when the ingredient is rejected.
func consume_ingredient(ingredient: Ingredient) -> bool:
	if ingredient == null or not can_interact():
		return false
	if not _consume(ingredient):
		return false
	consumed.append(ingredient)
	ingredient_consumed.emit(ingredient, self)
	return true


## Override to define what consuming means (brew, eat, store, ...).
## Return false to reject the ingredient (nothing is recorded or emitted).
func _consume(ingredient: Ingredient) -> bool:
	return true


## The player hands over the held ingredient; with empty hands the
## consumer gets a plain interaction instead.
func interact_with(player: PlayerInteractor) -> void:
	if player.ingredient_holder.is_empty():
		interact()
	else:
		player.ingredient_holder.transfer_to(self)
