extends PotionConsumer
class_name Customer

@export var customer_manager : Node3D
@export var customer_mesh_paths : Array[String]
@export var customer_mesh : MeshInstance3D
@export var waiting_graphic : Node3D

@export var desired_potion: String = ""
var potion_recieved : Potion

var is_waiting : bool = false

signal served(potion: Potion, customer: Customer)

func _ready():
	super._ready()
	if customer_mesh and not customer_mesh_paths.is_empty():
		customer_mesh.mesh = load(customer_mesh_paths.pick_random())

func _process(delta):
	super._process(delta)
	if waiting_graphic:
		waiting_graphic.visible = is_waiting

func _init() -> void:
	interaction_prompt = "Serve potion"

func _consume(potion: Potion) -> bool:
	if desired_potion != "" and potion.id != desired_potion:
		print("%s refuses %s" % [name, potion.display_name])
		return false
	print("%s drank %s" % [name, potion.display_name])
	served.emit(potion, self)
	return true
