class_name Mixer
extends IngredientConsumer

## The brewing mixer — an interactor the player uses directly.
## Interact while offering an ingredient to add it to the brewing
## slots; interact with empty hands to brew once both slots are full.

signal brewed(potion: Potion)


func _ready() -> void:
	_update_prompt()


## Interacting with the mixer: offering an ingredient feeds the slots,
## otherwise brew when both slots are full.
func interact(ingredient: Ingredient = null) -> void:
	if not can_interact():
		return
	if ingredient != null:
		consume_ingredient(ingredient)
	elif PotionService.can_brew():
		brewed.emit(PotionService.brew())
		_update_prompt()
	interacted.emit(self)


func _consume(ingredient: Ingredient) -> bool:
	var accepted := PotionService.add_ingredient(ingredient.id)
	_update_prompt()
	return accepted


func _update_prompt() -> void:
	interaction_prompt = "Brew" if PotionService.can_brew() else "Add ingredient"
