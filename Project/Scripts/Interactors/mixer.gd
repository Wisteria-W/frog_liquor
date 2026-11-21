class_name Mixer
extends IngredientConsumer

## The brewing mixer — an interactor the player uses directly.
## Interact while offering an ingredient to add it to the brewing
## slots; interact with empty hands to brew once both slots are full.
## Brewing creates a potion that a PotionHolder can pick up.

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
		brew()
		_update_prompt()
	interacted.emit(self)


## Player interaction with the mixer: offering an ingredient feeds the
## brewing slots; empty-handed brews once both slots are full and picks
## the brewed potion up into the player's potion holder.
func interact_with(player: PlayerInteractor) -> void:
	if not player.ingredient_holder.is_empty():
		player.ingredient_holder.transfer_to(self)
	elif PotionService.can_brew():
		var potion := brew()
		if potion == null:
			print("Brewing failed — %s" % PotionService.SLUDGE_NAME)
		elif not player.potion_holder.hold(potion):
			push_warning("Player already carries a potion — the brewed one is lost")
	else:
		interact()


## Brews the filled slots into a potion and returns it (null = no recipe
## matched, i.e. murky sludge) so a PotionHolder can pick it up.
func brew() -> Potion:
	var potion := PotionService.brew()
	brewed.emit(potion)
	return potion


func _consume(ingredient: Ingredient) -> bool:
	var accepted := PotionService.add_ingredient(ingredient.id)
	_update_prompt()
	return accepted


func _update_prompt() -> void:
	interaction_prompt = "Brew" if PotionService.can_brew() else "Add ingredient"
