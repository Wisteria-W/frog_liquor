class_name PotionHolder
extends Interactor

## Holds potions — e.g. the player's hands, or a shelf in the world.
## The chain is: PotionCreator creates -> PotionHolder holds
## -> PotionConsumer consumes.

signal potion_held(potion: Potion, holder: PotionHolder)
signal potion_taken(potion: Potion, holder: PotionHolder)

## How many potions fit. 1 = carry only one at a time.
@export var capacity: int = 1

## Optional sibling holder (e.g. the player's ingredient holder): while it
## holds something, this holder refuses new items — one carry at a time.
## Left null for world holders (shelves, ...), which don't exclude.
var exclusive_with = null

var held: Array[Potion] = []


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
	potion_held.emit(potion, self)
	return true


## Takes the most recently held potion out. Null when empty.
func take() -> Potion:
	if held.is_empty():
		return null
	var potion: Potion = held.pop_back()
	potion_taken.emit(potion, self)
	return potion


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
