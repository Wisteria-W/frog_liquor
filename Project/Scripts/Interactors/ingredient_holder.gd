class_name IngredientHolder
extends Interactor

## Holds ingredients — e.g. the player's hands, or a basket in the world.
## The chain is: IngredientProvider provides -> IngredientHolder holds
## -> IngredientConsumer consumes.

signal ingredient_held(ingredient: Ingredient, holder: IngredientHolder)
signal ingredient_taken(ingredient: Ingredient, holder: IngredientHolder)

## How many ingredients fit. 1 = carry one at a time.
@export var capacity: int = 1

var held: Array[Ingredient] = []


func is_empty() -> bool:
	return held.is_empty()


func is_full() -> bool:
	return held.size() >= capacity


func can_hold() -> bool:
	return can_interact() and not is_full()


## Puts an ingredient into the holder. Returns false when full or rejected.
func hold(ingredient: Ingredient) -> bool:
	if ingredient == null or not can_hold():
		return false
	held.append(ingredient)
	ingredient_held.emit(ingredient, self)
	return true


## Takes the most recently held ingredient out. Null when empty.
func take() -> Ingredient:
	if held.is_empty():
		return null
	var ingredient := held.pop_back()
	ingredient_taken.emit(ingredient, self)
	return ingredient


## The most recently held ingredient, without removing it. Null when empty.
func peek() -> Ingredient:
	return null if held.is_empty() else held.back()


## Picks up the ingredient from a provider (fires its interaction).
## Returns false when the provider is spent or the holder is full.
func take_from(provider: IngredientProvider) -> bool:
	if provider == null or not provider.can_interact() or not can_hold():
		return false
	provider.interact()
	return hold(provider.provide_ingredient())


## Moves the held ingredient into a consumer (e.g. the mixer).
## Returns false when the holder is empty or the consumer rejects it.
func transfer_to(consumer: IngredientConsumer) -> bool:
	var ingredient := peek()
	if ingredient == null or consumer == null:
		return false
	if consumer.consume_ingredient(ingredient):
		take()
		return true
	return false
