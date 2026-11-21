extends CharacterBody3D
class_name Customer

@export var customer_manager : Node3D

var potion_chosen : Potion
var potion_recieved : Potion

var is_waiting : bool

signal got_potion(customer : Customer, is_right : bool)
func _process(delta):
	if is_waiting:
		pass

func recieve_potion(potion_got : Potion):
	potion_recieved = potion_got
	if potion_recieved == potion_chosen:
		got_potion.emit(true)
	else:
		got_potion.emit(false)
