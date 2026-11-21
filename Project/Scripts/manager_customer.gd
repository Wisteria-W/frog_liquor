extends Node3D

@export var customer_origin : Vector3
@export var customer_offset : Vector3
@export var customer_paths : Array[String]
var customer_resources : Array[PackedScene]

@export var customer_spawn_cooldown : float = 30.0
@export var customer_spawn_timer : Timer

var customers : Array[Node3D]

func _ready():
	customer_spawn_timer.wait_time = customer_spawn_cooldown
	for path in customer_paths:
		var customer_res = load(path)
		customer_resources.append(customer_res)

func _input(event):
	if event.is_action_pressed("AddCutsomer"):
		_create_customer()
	if event.is_action_pressed("RemoveCustomer"):
		if customers.size() > 0:
			_remove_customer(customers[0], false)

func _create_customer():
	var customer_instance = customer_resources.pick_random().instantiate()
	customer_instance.position = customer_origin + customer_offset * customers.size()
	customer_instance.connect("got_potion", _remove_customer)
	customers.append(customer_instance)
	get_tree().current_scene.add_child(customer_instance)

func _remove_customer(customer : Customer, is_right : bool):
	customer.disconnect("got_potion", _remove_customer)
	customers.erase(customer)
	for cust in customers:
		cust.global_position -= customer_offset
	customer.queue_free()
