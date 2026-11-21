class_name Mixer
extends IngredientConsumer

## The brewing mixer — an interactor the player uses directly.
## 1. Interact while holding an ingredient to add it to the brewing slots (1/2, 2/2).
## 2. Interact empty-handed once both slots are full to start brewing (`brew_duration` seconds).
## 3. Once brewing finishes, interact empty-handed again to pick up the finished potion.

signal brewed(potion: Potion)

@export var mesh_filling: MeshInstance3D
@export var brew_duration: float = 2.0

var _slot_cubes: Array[MeshInstance3D] = []
var _ready_cube: MeshInstance3D
var _slot_ingredients: Array[Ingredient] = []
var _is_brewing: bool = false
var _brew_timer: float = 0.0
var _pending_potion: Potion = null
var _ready_potion: Potion = null


func _ready() -> void:
	_slot_cubes = [
		_create_item_cube(Vector3(-0.12, 0.55, 0), Vector3(0.14, 0.14, 0.14)),
		_create_item_cube(Vector3(0.12, 0.55, 0), Vector3(0.14, 0.14, 0.14)),
	]
	_ready_cube = _create_item_cube(Vector3(0, 0.55, 0), Vector3(0.18, 0.22, 0.18))
	_update_prompt()
	_update_slot_cubes()


func _process(delta: float) -> void:
	super._process(delta)
	if not _is_brewing:
		return
	_brew_timer += delta
	if _brew_timer >= brew_duration:
		_finish_brewing()


## True while the mixer is actively blending ingredients.
func is_brewing() -> bool:
	return _is_brewing


## True once brewing has completed and a finished potion is waiting in the mixer.
func has_ready_potion() -> bool:
	return _ready_potion != null


## Interacting with the mixer: offering an ingredient feeds the slots,
## otherwise starts brewing when both slots are full.
func interact(ingredient: Ingredient = null) -> void:
	if not can_interact():
		return
	if ingredient != null:
		consume_ingredient(ingredient)
	elif PotionService.can_brew() and not _is_brewing and _ready_potion == null:
		start_brewing()
	interacted.emit(self)


## Player interaction with the mixer:
## - Holding an ingredient (when not brewing/holding a finished drink) -> adds ingredient to slots.
## - Empty-handed when both slots are full -> starts brewing (does not give drink immediately).
## - While brewing -> waits until `brew_duration` finishes.
## - Empty-handed when finished drink is ready -> picks up the brewed potion.
func interact_with(player: PlayerInteractor) -> void:
	if _is_brewing:
		print("Mixer is still brewing...")
		return
	if _ready_potion != null:
		if player.potion_holder.hold(_ready_potion):
			_ready_potion = null
			_update_prompt()
			_update_slot_cubes()
			interacted.emit(self)
		else:
			push_warning("Player hands are not free to pick up the brewed potion")
		return
	if not player.ingredient_holder.is_empty():
		player.ingredient_holder.transfer_to(self)
	elif PotionService.can_brew():
		start_brewing()
		interacted.emit(self)
	else:
		interact()


## Starts the timed brewing process (`brew_duration` seconds).
func start_brewing() -> void:
	_pending_potion = PotionService.brew()
	_slot_ingredients.clear()
	_is_brewing = true
	_brew_timer = 0.0
	print("Mixer started brewing...")
	_update_prompt()
	_update_slot_cubes()


func _finish_brewing() -> void:
	_is_brewing = false
	_brew_timer = 0.0
	_ready_potion = _pending_potion
	_pending_potion = null
	if _ready_potion == null:
		print("Brewing failed — %s" % PotionService.SLUDGE_NAME)
	else:
		print("Mixer finished brewing %s — ready to pick up!" % _ready_potion.display_name)
	_update_prompt()
	_update_slot_cubes()
	brewed.emit(_ready_potion)


## Immediate brew helper for programmatic callers.
func brew() -> Potion:
	start_brewing()
	_finish_brewing()
	return _ready_potion


func _consume(ingredient: Ingredient) -> bool:
	if _is_brewing or _ready_potion != null:
		return false
	var accepted := PotionService.add_ingredient(ingredient.id)
	if accepted:
		_slot_ingredients.append(ingredient)
		print("Added %s to mixer (%d/%d)" % [ingredient.display_name, PotionService.slots.size(), PotionService.MAX_INGREDIENTS])
	_update_prompt()
	_update_slot_cubes()
	return accepted


func _update_prompt() -> void:
	if _is_brewing:
		interaction_prompt = "Brewing..."
	elif _ready_potion != null:
		interaction_prompt = "Take potion"
	elif PotionService.can_brew():
		interaction_prompt = "Brew"
	else:
		interaction_prompt = "Add ingredient"


func _update_slot_cubes() -> void:
	if mesh_filling != null:
		mesh_filling.visible = _is_brewing
	if _ready_cube != null:
		_apply_item_visual(_ready_cube, _ready_potion if not _is_brewing else null)
	for i in range(_slot_cubes.size()):
		var cube := _slot_cubes[i]
		if _is_brewing or _ready_potion != null:
			_apply_item_visual(cube, null)
		elif i < _slot_ingredients.size():
			_apply_item_visual(cube, _slot_ingredients[i])
		elif i < PotionService.slots.size():
			var temp := Ingredient.new()
			temp.id = PotionService.slots[i]
			_apply_item_visual(cube, temp)
		else:
			_apply_item_visual(cube, null)
