class_name Interactor
extends Node3D

## Base class for everything the player can interact with in the world.
## Subclasses decide what an interaction does (provide an ingredient,
## consume an ingredient, ...) — both for plain interact() calls and for
## player interactions via interact_with(player).

signal interacted(interactor: Interactor)

@export var interaction_prompt: String = "Interact"
@export var enabled: bool = true

var is_selected: bool = false


func _process(_delta: float) -> void:
	var mesh := get_node_or_null("MeshInstance3D") as MeshInstance3D
	if mesh and mesh.material_override:
		mesh.material_override.albedo_color = Color.RED if is_selected else Color.WHITE


func _create_item_cube(offset: Vector3 = Vector3(0, 0.55, 0), cube_size: Vector3 = Vector3(0.16, 0.16, 0.16)) -> MeshInstance3D:
	var cube := MeshInstance3D.new()
	cube.name = "ItemCube"
	var box := BoxMesh.new()
	box.size = cube_size
	cube.mesh = box
	var mat := StandardMaterial3D.new()
	cube.material_override = mat
	cube.position = offset
	add_child(cube)
	return cube


static func color_for_id(id: String) -> Color:
	match id:
		"water":
			return Color(0.2, 0.65, 1.0)
		"frog_heart":
			return Color(0.2, 0.85, 0.35)
		"potion_red":
			return Color(0.9, 0.15, 0.45)
		_:
			if id.is_empty():
				return Color.WHITE
			return Color.from_hsv(abs(id.hash() % 360) / 360.0, 0.75, 0.95)


## True when this interactor can be interacted with right now.
func can_interact() -> bool:
	return enabled and is_inside_tree()


## Called by whatever triggers interactions (raycast detector, input, ...).
func interact() -> void:
	if can_interact():
		interacted.emit(self)


## What happens when the player interacts with this. The player passes
## itself so subclasses can move items between its holders and themselves.
## The default is a plain interaction; each interactor type overrides this,
## so the player needs no type checks of its own.
func interact_with(player: PlayerInteractor) -> void:
	interact()
