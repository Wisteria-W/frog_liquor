class_name IngredientProvider
extends Interactor

## An interactor that provides an ingredient when interacted with
## (a mushroom patch, a crate, an NPC handing something over, ...).

signal ingredient_provided(ingredient: Ingredient, provider: IngredientProvider)

@export var ingredient: Ingredient
@export var single_use: bool = false

var _used := false


func can_interact() -> bool:
	return super.can_interact() and not (single_use and _used)


func interact() -> void:
	if not can_interact():
		return
	super.interact()
	if single_use:
		_used = true
	ingredient_provided.emit(ingredient, self)


## The ingredient this provider hands out. Null when none is assigned.
func provide_ingredient() -> Ingredient:
	return ingredient
