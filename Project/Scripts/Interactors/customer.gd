class_name Customer
extends PotionConsumer

## A customer — the potion consumer in the world. The player never
## consumes potions itself; it brews them, carries only one at a time
## and hands them to customers.

signal served(potion: Potion, customer: Customer)

## When set, the customer only accepts the potion with this id.
@export var desired_potion: String = ""


func _init() -> void:
	interaction_prompt = "Serve potion"


func _consume(potion: Potion) -> bool:
	if desired_potion != "" and potion.id != desired_potion:
		print("%s refuses %s" % [name, potion.display_name])
		return false
	print("%s drank %s" % [name, potion.display_name])
	served.emit(potion, self)
	return true
