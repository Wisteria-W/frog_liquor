extends Node3D

@export var customer_origin : Vector3
@export var customer_offset : Vector3
@export var customer_paths : Array[String]
var customer_resources : Array[PackedScene]

@export var max_customer_count : int = 5

@export var customer_spawn_cooldown : float = 30.0
@export var customer_spawn_timer : Timer

var customers : Array[Node3D]

func _ready():
	customer_spawn_timer.wait_time = customer_spawn_cooldown
	customer_spawn_timer.start()
	customer_spawn_timer.connect("timeout", _create_customer)
	
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
	if customers.size() > max_customer_count || customer_paths.size() <= 0:
		return
	var customer_instance = customer_resources.pick_random().instantiate()
	customer_instance.position = customer_origin + customer_offset * customers.size()
	customer_instance.rotation.y = deg_to_rad(-90)
	customer_instance.connect("got_potion", _remove_customer)
	if customers.size() <= 0:
		customer_instance.is_waiting = true
	customers.append(customer_instance)
	get_tree().current_scene.add_child(customer_instance)

func _remove_customer(customer : Customer, is_right : bool):
	customer.disconnect("got_potion", _remove_customer)
	customers.erase(customer)
	for cust in customers:
		cust.global_position -= customer_offset
	customer.queue_free()
	if customers.size() > 0:
		customers[0].is_waiting = true
