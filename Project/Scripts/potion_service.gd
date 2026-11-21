extends Node

## PotionService (autoload) — owns the brewing slots.
## A potion accepts exactly MAX_INGREDIENTS ingredients; brew() matches the
## filled slots against the loaded potion definitions, in either order.

const MAX_INGREDIENTS := 2
const POTIONS_PATH := "res://Data/potions.json"
const SLUDGE_NAME := "Murky Sludge"

signal ingredient_added(id: String, slot_index: int)
signal brewed(potion: Potion) ## emitted with null when no recipe matched (sludge)

var slots: Array[String] = []
var potions: Array[Potion] = []


func _ready() -> void:
	load_potions()


func load_potions() -> void:
	potions.clear()
	if not FileAccess.file_exists(POTIONS_PATH):
		push_warning("PotionService: no potion data found at " + POTIONS_PATH)
		return
	var file := FileAccess.open(POTIONS_PATH, FileAccess.READ)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Array:
		push_error("PotionService: failed to parse " + POTIONS_PATH)
		return
	for entry in parsed:
		var ingredients: Array = entry.get("ingredients", [])
		if ingredients.size() != MAX_INGREDIENTS:
			push_warning("PotionService: skipping potion '%s' — a potion needs exactly %d ingredients, got %d" % [entry.get("id", "?"), MAX_INGREDIENTS, ingredients.size()])
			continue
		var potion := Potion.new()
		potion.id = entry.get("id", "")
		potion.display_name = entry.get("display_name", potion.id)
		potion.ingredient_a = ingredients[0]
		potion.ingredient_b = ingredients[1]
		var mesh_path: String = entry.get("mesh", "")
		if not mesh_path.is_empty() and ResourceLoader.exists(mesh_path):
			potion.mesh = load(mesh_path) as Mesh
		var scene_path: String = entry.get("model_scene", "")
		if not scene_path.is_empty() and ResourceLoader.exists(scene_path):
			potion.model_scene = load(scene_path) as PackedScene
		potions.append(potion)


## Adds an ingredient to the next free slot.
## Returns false when both slots are full (a 3rd ingredient is rejected).
func add_ingredient(id: String) -> bool:
	if slots.size() >= MAX_INGREDIENTS:
		return false
	slots.append(id)
	ingredient_added.emit(id, slots.size() - 1)
	return true


func can_brew() -> bool:
	return slots.size() == MAX_INGREDIENTS


## Returns the potion whose two ingredients match the filled slots, in either
## order. Returns null when the slots are not full or nothing matches.
func match() -> Potion:
	if not can_brew():
		return null
	for potion in potions:
		if (potion.ingredient_a == slots[0] and potion.ingredient_b == slots[1]) \
				or (potion.ingredient_a == slots[1] and potion.ingredient_b == slots[0]):
			return potion
	return null


## Brews with the current slots: returns the matched potion (null = sludge)
## and clears both slots so the service can be reused.
func brew() -> Potion:
	var potion := match()
	slots.clear()
	brewed.emit(potion)
	return potion


## Clears the slots without brewing.
func reset() -> void:
	slots.clear()


## Convenience for UI: brew and return the resulting display name.
func brew_name() -> String:
	var potion := brew()
	return potion.display_name if potion else SLUDGE_NAME
