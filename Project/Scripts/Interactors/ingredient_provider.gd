class_name IngredientProvider
extends Interactor

## An interactor that provides an ingredient when interacted with
## (a mushroom patch, a crate, an NPC handing something over, ...).

signal ingredient_provided(ingredient: Ingredient, provider: IngredientProvider)

@export var ingredient: Ingredient
@export var single_use: bool = false

var _used := false
var _item_cube: MeshInstance3D


func _ready() -> void:
	_item_cube = _create_item_cube(Vector3(0, 0.55, 0))
	_update_visual()


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
	_item_cube.visible = ingredient != null and can_interact()
	if ingredient != null and _item_cube.material_override is StandardMaterial3D:
		(_item_cube.material_override as StandardMaterial3D).albedo_color = color_for_id(ingredient.id)


## The ingredient this provider hands out. Null when none is assigned.
func provide_ingredient() -> Ingredient:
	return ingredient


## The player picks the provided ingredient up into its ingredient holder.
func interact_with(player: PlayerInteractor) -> void:
	player.ingredient_holder.take_from(self)
