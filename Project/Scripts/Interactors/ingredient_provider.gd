class_name IngredientProvider
extends Interactor

## An interactor that provides an ingredient when interacted with
## (a mushroom patch, a crate, an NPC handing something over, ...).

signal ingredient_provided(ingredient: Ingredient, provider: IngredientProvider)

## Quick setup directly on the provider (no nested sub-resource required):
@export var ingredient_id: String = ""
@export var ingredient_name: String = ""
@export var ingredient_model: PackedScene

## Optional Ingredient resource (automatically created/synced from the fields above if set).
@export var ingredient: Ingredient
@export var single_use: bool = false

var _used := false
var _item_cube: MeshInstance3D


func _ready() -> void:
	_sync_ingredient()
	_item_cube = _create_item_cube(Vector3(0, 0.5, 0))
	_update_visual()


func _sync_ingredient() -> void:
	if ingredient == null and (not ingredient_id.is_empty() or ingredient_model != null):
		ingredient = Ingredient.new()
	if ingredient != null:
		if not ingredient_id.is_empty():
			ingredient.id = ingredient_id
		if not ingredient_name.is_empty():
			ingredient.display_name = ingredient_name
		elif ingredient.display_name.is_empty() and not ingredient.id.is_empty():
			ingredient.display_name = ingredient.id.to_upper()
		if ingredient_model != null:
			ingredient.model_scene = ingredient_model


func can_interact() -> bool:
	return super.can_interact() and not (single_use and _used)


func interact() -> void:
	if not can_interact():
		return
	super.interact()
	if single_use:
		_used = true
	_update_visual()
	ingredient_provided.emit(ingredient, self)


func _update_visual() -> void:
	if _item_cube == null:
		return
	_apply_item_visual(_item_cube, ingredient if can_interact() else null)


## The ingredient this provider hands out. Null when none is assigned.
func provide_ingredient() -> Ingredient:
	_sync_ingredient()
	return ingredient


## The player picks the provided ingredient up into its ingredient holder.
func interact_with(player: PlayerInteractor) -> void:
	player.ingredient_holder.take_from(self)
