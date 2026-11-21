class_name IngredientHolder
extends Interactor

## Holds ingredients — e.g. the player's hands, or a basket in the world.
## The chain is: IngredientProvider provides -> IngredientHolder holds
## -> IngredientConsumer consumes.

signal ingredient_held(ingredient: Ingredient, holder: IngredientHolder)
signal ingredient_taken(ingredient: Ingredient, holder: IngredientHolder)

## How many ingredients fit. 1 = carry one at a time.
@export var capacity: int = 1

## Optional sibling holder (e.g. the player's potion holder): while it
## holds something, this holder refuses new items — one carry at a time.
## Left null for world holders (baskets, shelves), which don't exclude.
var exclusive_with = null

var held: Array[Ingredient] = []
var _item_cube: MeshInstance3D


func _ready() -> void:
	_item_cube = _create_item_cube(Vector3(0, 0.6, 0))
	_update_visual()


func is_empty() -> bool:
	return held.is_empty()


func is_full() -> bool:
	return held.size() >= capacity


func can_hold() -> bool:
	return can_interact() and not is_full() \
		and (exclusive_with == null or exclusive_with.is_empty())


## Puts an ingredient into the holder. Returns false when full or rejected.
func hold(ingredient: Ingredient) -> bool:
	if ingredient == null or not can_hold():
		return false
	held.append(ingredient)
	_update_visual()
	ingredient_held.emit(ingredient, self)
	return true


## Takes the most recently held ingredient out. Null when empty.
func take() -> Ingredient:
	if held.is_empty():
		return null
	var ingredient: Ingredient = held.pop_back()
	_update_visual()
	ingredient_taken.emit(ingredient, self)
	return ingredient


func _update_visual() -> void:
	if _item_cube == null:
		return
	_apply_item_visual(_item_cube, peek())


## The most recently held ingredient, without removing it. Null when empty.
func peek() -> Ingredient:
	if held.is_empty():
		return null
	return held.back()


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


## Player interaction with a world IngredientHolder (e.g. a counter or basket):
## - Holding an ingredient -> places it onto this holder.
## - Empty-handed -> picks the held ingredient up.
func interact_with(player: PlayerInteractor) -> void:
	if player == null or player.ingredient_holder == self:
		return
	if not player.ingredient_holder.is_empty() and can_hold():
		var ingredient := player.ingredient_holder.peek()
		if hold(ingredient):
			player.ingredient_holder.take()
			interacted.emit(self)
	elif not is_empty() and player.ingredient_holder.can_hold():
		var ingredient := peek()
		if player.ingredient_holder.hold(ingredient):
			take()
			interacted.emit(self)
