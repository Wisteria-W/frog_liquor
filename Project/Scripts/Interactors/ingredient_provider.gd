class_name IngredientProvider
extends Interactor

## An interactor that provides an ingredient when interacted with
## (a mushroom patch, a crate, an NPC handing something over, ...).

signal ingredient_provided(ingredient: Ingredient, provider: IngredientProvider)

@export var ingredient: Ingredient
@export var single_use: bool = false

const DEFAULT_BUG_SCENES: Array[String] = [
	"res://Prefabs/Ingridients/Ingridient_01.tscn",
	"res://Prefabs/Ingridients/Ingridient_02.tscn",
]

var _used := false
var _item_cube: MeshInstance3D


func _ready() -> void:
	_ensure_bug_scenes()
	_pick_next_model_scene()
	_item_cube = _create_item_cube(Vector3(0, 0.5, 0))
	_update_visual()


func can_interact() -> bool:
	return super.can_interact() and not (single_use and _used)


func interact() -> void:
	if not can_interact():
		return
	super.interact()
	if single_use:
		_used = true
	var provided := provide_ingredient()
	_pick_next_model_scene()
	_update_visual()
	ingredient_provided.emit(provided, self)


func _update_visual() -> void:
	if _item_cube == null:
		return
	_apply_item_visual(_item_cube, ingredient if can_interact() else null)


## The ingredient this provider hands out. Null when none is assigned.
func provide_ingredient() -> Ingredient:
	if ingredient == null:
		return null
	var copy := ingredient.duplicate() as Ingredient
	copy.model_scene = ingredient.model_scene
	return copy


func _ensure_bug_scenes() -> void:
	if ingredient == null:
		return
	if ingredient.id in ["bug", "frog_heart"] and ingredient.model_scenes.is_empty() and ingredient.model_scene == null:
		for path in DEFAULT_BUG_SCENES:
			if ResourceLoader.exists(path):
				var packed := load(path) as PackedScene
				if packed != null:
					ingredient.model_scenes.append(packed)


func _pick_next_model_scene() -> void:
	if ingredient != null and not ingredient.model_scenes.is_empty():
		ingredient.model_scene = ingredient.model_scenes.pick_random()


## The player picks the provided ingredient up into its ingredient holder.
func interact_with(player: PlayerInteractor) -> void:
	player.ingredient_holder.take_from(self)
