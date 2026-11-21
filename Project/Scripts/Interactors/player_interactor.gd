class_name  PlayerInteractor
extends Interactor

## The player's two carry slots. The player can carry only ONE thing at a
## time: _ready() links the holders to each other (exclusive_with), so
## while one holds something the other refuses new items.
@onready var ingredient_holder: IngredientHolder = $IngredientHolder
@onready var potion_holder: PotionHolder = $PotionHolder
@onready var tile_detector: Node3D = get_node("../TileDetector")


func _ready() -> void:
	ingredient_holder.exclusive_with = potion_holder
	potion_holder.exclusive_with = ingredient_holder
	ingredient_holder.ingredient_held.connect(_on_ingredient_held)
	potion_holder.potion_held.connect(_on_potion_held)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Interaction"):
		interact()


## True while the player carries anything (an ingredient or a potion).
func is_carrying() -> bool:
	return not ingredient_holder.is_empty() or not potion_holder.is_empty()


## True when the player's hands are free and it can pick something up.
func can_carry() -> bool:
	return ingredient_holder.is_empty() and potion_holder.is_empty()


func _current_interactor() -> Interactor:
	var target: Node = tile_detector.selected_tile
	if target == null:
		return null
	if target is Tile and (target as Tile).interactor != null:
		return (target as Tile).interactor
	if target is Interactor:
		return target
	for child in target.get_children():
		if child is Interactor:
			return child
	return null


## Interacts with whatever the TileDetector raycast is pointing at.
## The interactor itself decides what the interaction means — pick up,
## hand over, brew, ... — via Interactor.interact_with, so the player
## needs no type checks of its own.
func interact() -> void:
	var target := _current_interactor()
	if target != null:
		target.interact_with(self)


func _on_ingredient_held(ingredient: Ingredient, _holder: IngredientHolder) -> void:
	print("Player picked up %s" % ingredient.display_name)


func _on_potion_held(potion: Potion, holder: PotionHolder) -> void:
	print("Player picked up %s" % (potion.display_name if potion else PotionService.SLUDGE_NAME))
