class_name Mixer
extends IngredientConsumer

## The brewing mixer — an interactor the player uses directly.
## Interact while offering an ingredient to add it to the brewing
## slots; interact with empty hands to brew once both slots are full.
## Brewing creates a potion that a PotionHolder can pick up.

signal brewed(potion: Potion)

var _slot_cubes: Array[MeshInstance3D] = []
var _slot_ingredients: Array[Ingredient] = []


func _ready() -> void:
	_slot_cubes = [
		_create_item_cube(Vector3(-0.12, 0.55, 0), Vector3(0.14, 0.14, 0.14)),
		_create_item_cube(Vector3(0.12, 0.55, 0), Vector3(0.14, 0.14, 0.14)),
	]
	_update_prompt()
	_update_slot_cubes()


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
	_slot_ingredients.clear()
	_update_prompt()
	_update_slot_cubes()
	brewed.emit(potion)
	return potion


func _consume(ingredient: Ingredient) -> bool:
	var accepted := PotionService.add_ingredient(ingredient.id)
	if accepted:
		_slot_ingredients.append(ingredient)
		print("Added %s to mixer (%d/%d)" % [ingredient.display_name, PotionService.slots.size(), PotionService.MAX_INGREDIENTS])
	_update_prompt()
	_update_slot_cubes()
	return accepted


func _update_prompt() -> void:
	interaction_prompt = "Brew" if PotionService.can_brew() else "Add ingredient"


func _update_slot_cubes() -> void:
	for i in range(_slot_cubes.size()):
		var cube := _slot_cubes[i]
		if i < _slot_ingredients.size():
			_apply_item_visual(cube, _slot_ingredients[i])
		elif i < PotionService.slots.size():
			var temp := Ingredient.new()
			temp.id = PotionService.slots[i]
			_apply_item_visual(cube, temp)
		else:
			_apply_item_visual(cube, null)
