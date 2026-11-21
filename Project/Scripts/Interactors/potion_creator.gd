class_name PotionCreator
extends Interactor

## An interactor that creates a potion when interacted with
## (a brewing cauldron, a potion shelf, an NPC handing one over, ...).
## The chain is: PotionCreator creates -> PotionHolder holds
## -> PotionConsumer consumes.

signal potion_created(potion: Potion, creator: PotionCreator)

## The potion handed out when create_potion() is not overridden.
@export var potion: Potion
@export var single_use: bool = false

var _used := false
var _created: Potion
var _item_cube: MeshInstance3D


func _ready() -> void:
	_item_cube = _create_item_cube(Vector3(0, 0.55, 0), Vector3(0.18, 0.22, 0.18))
	_update_visual()


func can_interact() -> bool:
	return super.can_interact() and not (single_use and _used)


func interact() -> void:
	if not can_interact():
		return
	super.interact()
	if single_use:
		_used = true
	_created = create_potion()
	_update_visual()
	potion_created.emit(_created, self)


func _update_visual() -> void:
	if _item_cube == null:
		return
	_item_cube.visible = potion != null and can_interact()
	if potion != null and _item_cube.material_override is StandardMaterial3D:
		(_item_cube.material_override as StandardMaterial3D).albedo_color = color_for_id(potion.id)


## The potion this creator produces. Override to create potions
## dynamically (e.g. brew from the PotionService slots); the result is
## cached per interaction so created_potion() never creates twice.
func create_potion() -> Potion:
	return potion


## The potion created by the last interact() call. Null when none.
func created_potion() -> Potion:
	return _created


## The player picks the created potion up into its potion holder.
func interact_with(player: PlayerInteractor) -> void:
	player.potion_holder.take_from(self)
