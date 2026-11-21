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
		if waiting_graphic is SpriteBase3D:
			(waiting_graphic as SpriteBase3D).modulate = Color(1, 0.4, 0.4) if is_selected else Color.WHITE
	var area := get_node_or_null("Area3D") as Area3D
	if area:
		area.collision_layer = 4 if is_waiting else 0

func _init() -> void:
	interaction_prompt = "Serve potion"

func _consume(potion: Potion) -> bool:
	if desired_potion != "" and potion.id != desired_potion:
		print("%s refuses %s" % [name, potion.display_name])
		return false
	print("%s drank %s" % [name, potion.display_name])
	served.emit(potion, self)
	return true
