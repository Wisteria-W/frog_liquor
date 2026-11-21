class_name Ingredient
extends Resource

@export var id: String = ""
@export var display_name: String = ""

@export_group("3D Visuals")
## Optional 3D mesh (.obj, .mesh) to display instead of the fallback cube.
@export var mesh: Mesh
## Optional material override when using a 3D mesh.
@export var material_override: Material
## Optional 3D scene (.tscn, .glb) to instantiate instead of a mesh or fallback cube.
@export var model_scene: PackedScene
## Optional pool of 3D scenes to pick from when spawning this ingredient (e.g. bug variants).
@export var model_scenes: Array[PackedScene] = []
## Scale applied to the visual node.
@export var model_scale: Vector3 = Vector3.ONE
## Position offset relative to the station/holder slot.
@export var model_offset: Vector3 = Vector3.ZERO
## Custom fallback cube color (leave alpha at 0 to auto-color from id).
@export var fallback_color: Color = Color(1, 1, 1, 0)
