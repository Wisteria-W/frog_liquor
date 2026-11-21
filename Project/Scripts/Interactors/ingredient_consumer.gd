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
	consumed.append(ingredient)
	_consume(ingredient)
	ingredient_consumed.emit(ingredient, self)
	return true


## Override to define what consuming means (brew, eat, store, ...).
func _consume(ingredient: Ingredient) -> void:
	pass
