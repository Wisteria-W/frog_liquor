class_name PotionHolder
extends Interactor

## Holds potions — e.g. the player's hands, or a shelf in the world.
## The chain is: PotionCreator creates -> PotionHolder holds
## -> PotionConsumer consumes.

signal potion_held(potion: Potion, holder: PotionHolder)
signal potion_taken(potion: Potion, holder: PotionHolder)

## How many potions fit. 1 = carry only one at a time.
@export var capacity: int = 1
@export var item_offset: Vector3 = Vector3(0, 0.6, 0)
## When true on a world holder (e.g. a bar counter), a waiting customer will
## take a potion placed on this counter after `serve_delay` seconds.
@export var serves_waiting_customers: bool = false
@export var serve_delay: float = 1.0

## Optional sibling holder (e.g. the player's ingredient holder): while it
## holds something, this holder refuses new items — one carry at a time.
## Left null for world holders (shelves, ...), which don't exclude.
var exclusive_with = null

var held: Array[Potion] = []
var _item_cube: MeshInstance3D
var _serve_timer: float = 0.0


func _ready() -> void:
	_item_cube = _create_item_cube(item_offset, Vector3(0.18, 0.22, 0.18))
	_update_visual()


func _process(delta: float) -> void:
	super._process(delta)
	if not serves_waiting_customers or is_empty():
		_serve_timer = 0.0
		return
	var customer := _find_waiting_customer()
	if customer == null:
		_serve_timer = 0.0
		return
	_serve_timer += delta
	if _serve_timer >= serve_delay:
		_serve_timer = 0.0
		transfer_to(customer)


func is_empty() -> bool:
	return held.is_empty()


func is_full() -> bool:
	return held.size() >= capacity


func can_hold() -> bool:
	return can_interact() and not is_full() \
		and (exclusive_with == null or exclusive_with.is_empty())


## Puts a potion into the holder. Returns false when full or rejected.
func hold(potion: Potion) -> bool:
	if potion == null or not can_hold():
		return false
	held.append(potion)
	_update_visual()
	potion_held.emit(potion, self)
	return true


## Takes the most recently held potion out. Null when empty.
func take() -> Potion:
	if held.is_empty():
		return null
	var potion: Potion = held.pop_back()
	_update_visual()
	potion_taken.emit(potion, self)
	return potion


func _update_visual() -> void:
	if _item_cube == null:
		return
	_apply_item_visual(_item_cube, peek())


## The most recently held potion, without removing it. Null when empty.
func peek() -> Potion:
	if held.is_empty():
		return null
	return held.back()


## Picks up the created potion from a creator (fires its interaction).
## Returns false when the creator is spent or the holder is full.
func take_from(creator: PotionCreator) -> bool:
	if creator == null or not creator.can_interact() or not can_hold():
		return false
	creator.interact()
	return hold(creator.created_potion())


## Moves the held potion into a consumer (e.g. drinking it).
## Returns false when the holder is empty or the consumer rejects it.
func transfer_to(consumer: PotionConsumer) -> bool:
	var potion := peek()
	if potion == null or consumer == null:
		return false
	if consumer.consume_potion(potion):
		take()
		return true
	return false


## Player interaction with a world PotionHolder (such as a bar counter):
## - Holding a potion -> places the potion onto the counter.
## - Empty-handed -> picks the potion up from the counter.
func interact_with(player: PlayerInteractor) -> void:
	if player == null or player.potion_holder == self:
		return
	if not player.potion_holder.is_empty() and can_hold():
		var potion := player.potion_holder.peek()
		if hold(potion):
			player.potion_holder.take()
			_serve_timer = 0.0
			print("Placed %s on %s" % [potion.display_name, name])
			interacted.emit(self)
	elif not is_empty() and player.potion_holder.can_hold():
		var potion := peek()
		if player.potion_holder.hold(potion):
			take()
			_serve_timer = 0.0
			interacted.emit(self)


func _find_waiting_customer() -> Customer:
	if not is_inside_tree():
		return null
	var root_node: Node = owner if owner != null else get_tree().current_scene
	if root_node == null:
		return null
	var mgr := root_node.get_node_or_null("CustomerManager")
	if mgr == null and get_tree().current_scene != null:
		mgr = get_tree().current_scene.get_node_or_null("CustomerManager")
	if mgr and "customers" in mgr:
		for c in mgr.customers:
			if is_instance_valid(c) and c is Customer and (c as Customer).is_waiting:
				return c as Customer
	return null
