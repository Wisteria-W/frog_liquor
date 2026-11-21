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
	var highlight := get_node_or_null("HighlightMesh") as MeshInstance3D
	if highlight:
		highlight.visible = is_selected
		return
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
	cube.set_meta("base_offset", offset)
	cube.set_meta("fallback_size", cube_size)
	add_child(cube)
	return cube


## Updates an item visual node from an Ingredient or Potion resource (or null to hide).
## Uses `model_scene` (PackedScene) or `mesh` (Mesh) when assigned on the resource,
## and automatically falls back to the small colored cube when no 3D model is set.
func _apply_item_visual(cube: MeshInstance3D, item: Resource) -> void:
	if cube == null:
		return
	for child in cube.get_children():
		cube.remove_child(child)
		child.queue_free()
	if item == null:
		cube.visible = false
		return

	cube.visible = true
	var base_offset: Vector3 = cube.get_meta("base_offset", cube.position)
	var fallback_size: Vector3 = cube.get_meta("fallback_size", Vector3(0.16, 0.16, 0.16))
	var item_offset: Vector3 = item.get("model_offset") if item.get("model_offset") != null else Vector3.ZERO
	var item_scale: Vector3 = item.get("model_scale") if item.get("model_scale") != null else Vector3.ONE
	cube.position = base_offset + item_offset
	cube.scale = item_scale

	var custom_scene: PackedScene = item.get("model_scene")
	var custom_mesh: Mesh = item.get("mesh")
	var custom_mat: Material = item.get("material_override")

	if custom_scene != null:
		cube.mesh = null
		cube.material_override = null
		var instance := custom_scene.instantiate()
		cube.add_child(instance)
	elif custom_mesh != null:
		cube.mesh = custom_mesh
		cube.material_override = custom_mat
	else:
		var box := cube.mesh as BoxMesh
		if box == null:
			box = BoxMesh.new()
			box.size = fallback_size
			cube.mesh = box
		var mat := cube.material_override as StandardMaterial3D
		if mat == null:
			mat = StandardMaterial3D.new()
			cube.material_override = mat
		var fallback_col: Color = item.get("fallback_color") if item.get("fallback_color") != null else Color(1, 1, 1, 0)
		var item_id: String = item.get("id") if item.get("id") != null else ""
		mat.albedo_color = fallback_col if fallback_col.a > 0.0 else color_for_id(item_id)


static func color_for_id(id: String) -> Color:
	match id:
		"water":
			return Color(0.2, 0.65, 1.0)
		"bug", "frog_heart":
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
